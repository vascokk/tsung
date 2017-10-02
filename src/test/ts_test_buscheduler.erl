%%%-------------------------------------------------------------------
%%% @author vasco
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Oct 2017 16:30
%%%-------------------------------------------------------------------
-module(ts_test_buscheduler).
-author("vasco").

-include_lib("eunit/include/eunit.hrl").

get_data_test()->
  State = ts_buscheduler:new_session(),
  Data = ts_buscheduler:get_data(State),
  ?assertEqual(blah, Data).
