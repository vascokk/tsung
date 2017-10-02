%%%-------------------------------------------------------------------
%%% @author vasco
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Oct 2017 2:45 PM
%%%-------------------------------------------------------------------
-module(ts_buscheduler).
-author("vasco").

-behavior(ts_plugin).

-include("ts_profile.hrl").
-include("ts_buscheduler.hrl").
-include("bbmsg.hrl").

-include_lib("eunit/include/eunit.hrl").

%% API
-export([add_dynparams/4,
         get_message/2,
         session_defaults/0,
         subst/2,
         parse/2,
         parse_bidi/2,
         dump/2,
         parse_config/2,
         decode_buffer/2,
         new_session/0]).

%%----------------------------------------------------------------------
session_defaults() ->
  {ok,true}.

decode_buffer(Buffer,#buschedule_session{}) ->
  Buffer.

new_session() ->
  #buschedule_session{seq = 0}.

get_message(#buscheduler_request{type=raw},#state_rcv{session=State})->
  {Data, NewState} = get_data(State),
  {bbmsg:encode(Data), NewState};
get_message(#buscheduler_request{type=avro},#state_rcv{session=State})->
  {avro_notsupported, State};
get_message(#buscheduler_request{type=gpb},#state_rcv{session=State})->
  {gpb_notsupported, State};
get_message(#buscheduler_request{data=Data},#state_rcv{session=State})-> %% We can put some data in the config xml 'data' attribute
  {list_to_binary(Data),State}.

parse(_Data, State) ->
  State.

parse_bidi(Data, State) ->
  ts_plugin:parse_bidi(Data,State).

dump(A,B) ->
  ts_plugin:dump(A,B).

%%
parse_config(Element, Conf) ->
  ts_config_buscheduler:parse_config(Element, Conf).


add_dynparams(_,[], Param, _Host) ->
  Param;
add_dynparams(true, {DynVars, _Session}, OldReq, _Host) ->
  subst(OldReq, DynVars);
add_dynparams(_Subst, _DynData, Param, _Host) ->
  Param.

subst(Req=#buscheduler_request{data=Value}, DynData) ->
  Req#buscheduler_request{data=ts_search:subst(Value, DynData)}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
get_data(State) ->
  {Ts, Hour} = get_timestamp(),
  {_, CellLoad, CellLoadIdx} = element(Hour, ?CELL_LOAD),
  {Header, NewState}  = get_header(Ts, CellLoad, State),
  Connections = [get_connection(N, CellLoadIdx) || N<-lists:seq(1, State#buschedule_session.users_count)],
  Data = #msg{
      header = Header,
      connections = Connections
    },
  {Data, NewState}.

get_header(Ts, CellLoad, State) ->
  Header = #header{
    version = 1,
    cell_id = 123456789, %% TODO put something more clever here
    seq = State#buschedule_session.seq + 1,
    timestamp = Ts,
    conn_count = State#buschedule_session.users_count,
    sch_load = CellLoad * 100,
    padding = 0
  },
  {Header, State}.

get_connection(N, CellLoadIdx) ->
  RSRQIdx = rand:uniform(26),
  Tp = list_to_integer(float_to_list(element(CellLoadIdx, element(RSRQIdx, ?RSRQ2TP))*1000000,[{decimals,0}])),
  {_,_,Rsrq} = element(RSRQIdx, ?RSRQ_DIST),
%%  ?assertEqual(blah,Tp),
%%  ?assertEqual(blah,Rsrq),
  UL = #ul_data{
    throughput = Tp,
    latency = 5,
    rsrp = 58,
    rsrq = Rsrq
  },
  DL = #dl_data{
    throughput = Tp,
    latency = 5,
    rsrp = 58,
    rsrq = Rsrq
  },
  #connection{
    id = N,
    ul_data = UL,
    dl_data = DL
  }.

%% For testing only, obviously...
get_test_data() ->
  Ts = 1506602694051,
  Header = #header{
    version = 1,          %% <<1>>
    cell_id = 123456789,  %% <<0,0,0,117,188,209,5:4>>
    seq = 987654321,      %% <<0,0,0,0,58,222,104,177>>
    timestamp = Ts,       %% <<0,0,1,94,200,132,181,163>>
    conn_count = 3,       %% <<0,3>>
    sch_load = 75,        %% <<75:8>>  in percentage
    padding = 0           %% <<0:44>>
  },
  UL = #ul_data{
    throughput = 12345,  %%<<0,0,48,57>>
    latency = 5,         %%<<0,5>>
    rsrp = 58,           %%<<58:8>>
    rsrq = 67            %%<<67:8>>
  },
  DL = #dl_data{
    throughput = 12345,  %%<<0,0,48,57>>
    latency = 5,         %%<<0,5>>
    rsrp = 58,           %%<<58:8>>
    rsrq = 67            %%<<67:8>>
  },
  Connection1 = #connection{
    id = 111111,         %% <<0,0,0,0,0,1,178,7>>
    ul_data = UL,
    dl_data = DL
  },
  Connection2 = #connection{
    id = 222222,         %% <<0,0,0,0,0,3,100,14>>
    ul_data = UL,
    dl_data = DL
  },
  Connection3 = #connection{
    id = 333333,         %% <<0,0,0,0,0,5,22,21>>
    ul_data = UL,
    dl_data = DL
  },
  #msg{
    header = Header,
    connections = [Connection1,Connection2,Connection3]
  }.

get_timestamp() ->
  {Mega, Sec, Micro} = os:timestamp(),
  {_, {Hour,_,_}} = calendar:local_time(),
  {(Mega*1000000 + Sec)*1000 + round(Micro/1000), Hour}.



