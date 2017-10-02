%%%-------------------------------------------------------------------
%%% @author vasco
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. Sep 2017 11:47
%%%-------------------------------------------------------------------
-author("vasco").

-record(msg, {
  header,
  connections = []
}).

-record(header, {
  version = 1,       %%  8 bits
  cell_id,           %% 52 bits
  seq,               %% 64 bits
  timestamp,         %% 64 bits
  conn_count,        %% 16 bits
  sch_load,          %%  8 bits
  padding = 0        %% 44 bits  (I know, it should be calculated, but to save few cycles, we can use hardcoded padding)
}).

-record(connection, {
  id,          %% 64 bits
  ul_data,     %% 64 bits
  dl_data      %% 64 bits
}).


-record(ul_data, {
  throughput,  %% 32 bits
  latency,     %% 16 bits
  rsrp,        %% 8 bits
  rsrq         %% 8 bits
}).

-record(dl_data, {
  throughput,  %% 32 bits
  latency,     %% 16 bits
  rsrp,        %% 8 bits
  rsrq         %% 8 bits
}).