%%%-------------------------------------------------------------------
%%% @author vasco
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. Sep 2017 4:54 PM
%%%-------------------------------------------------------------------
-module(ts_config_buscheduler).
-vc('$Id$ ').
-author("vasco").

%% API
-export([parse_config/2]).

-include("ts_profile.hrl").
-include("ts_config.hrl").
-include("ts_buscheduler.hrl").

-include_lib("xmerl/include/xmerl.hrl").


%%----------------------------------------------------------------------
%% Function: parse_config/2
%% Purpose:  parse a request defined in the XML config file
%% Args:     Element, Config
%% Returns:  List
%%----------------------------------------------------------------------
%% Parsing other elements
parse_config(Element = #xmlElement{name=dyn_variable}, Conf = #config{}) ->
  ts_config:parse(Element,Conf);

parse_config(Element = #xmlElement{name=buscheduler, attributes=Attrs},
    Config=#config{curid = Id, session_tab = Tab,
      sessions = [CurS | _], dynvar=DynVar,
      subst    = SubstFlag, match=MatchRegExp}) ->

  Ack  = ts_config:getAttr(atom,Attrs, ack, local),
%%  DstIp = ts_config:getAttr(string, Element#xmlElement.attributes, dst_ip, "127.0.0.1"),
%%  DstPort = ts_config:getAttr(integer_or_string, Element#xmlElement.attributes, dst_port, 7777),
  Type = ts_config:getAttr(atom, Element#xmlElement.attributes, type),
  Connections = ts_config:getAttr(integer_or_string, Attrs, connections, 250),

  Request = #buscheduler_request{type = Type, users_count = Connections},


  %% No data element in the config xml as the data will be produced solely from within the plug in, with no external dependencies
  %% Might reconsider this later...

  ts_config:mark_prev_req(Id-1, Tab, CurS),
  Msg=#ts_request{ack = Ack,
                  subst   = SubstFlag,
                  match   = MatchRegExp,
                  param   = Request},
  ets:insert(Tab,{{CurS#session.id, Id},Msg#ts_request{endpage=true,
                   dynvar_specs=DynVar}}),
  lists:foldl( fun(A,B)->ts_config:parse(A,B) end,
                Config#config{dynvar=[]},
                Element#xmlElement.content);
%% Parsing other elements
parse_config(Element = #xmlElement{}, Conf = #config{}) ->
  ts_config:parse(Element,Conf);

%% Parsing non #xmlElement elements
parse_config(_, Conf = #config{}) ->
  Conf.