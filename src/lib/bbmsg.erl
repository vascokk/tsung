-module(bbmsg).

-include("bbmsg.hrl").

-export([encode/1, decode/1,
         encode_header/1, decode_header/1,
         encode_uldata/1, decode_uldata/1,
         encode_dldata/1, decode_dldata/1,
         encode_connection/1, decode_connection/1,
         encode_connections/1, decode_connections/1]).

-define(PADDING, 44).

encode(#msg{header = Header, connections = Connections}) ->
  HeaderData = encode_header(Header),
  ConnectionsData = encode_connections(Connections),
  <<HeaderData/binary, ConnectionsData/binary>>.

encode_header(#header{version=Ver, cell_id=CellId, seq=Seq, timestamp=Ts, conn_count=ConnCount, sch_load=SchLoad}) ->
  <<Ver:8, CellId:52, Seq:64, Ts:64, ConnCount:16, SchLoad:8, 0:?PADDING>>.

encode_uldata(#ul_data{throughput=Tp, latency=Latency, rsrp=RSRP, rsrq=RSRQ}) ->
  <<Tp:32, Latency:16, RSRP:8, RSRQ:8>>.

encode_dldata(#dl_data{throughput=Tp, latency=Latency, rsrp=RSRP, rsrq=RSRQ}) ->
  <<Tp:32, Latency:16, RSRP:8, RSRQ:8>>.

encode_connection(#connection{id=Id, ul_data=UL, dl_data=DL}) ->
  ULData = encode_uldata(UL),
  DLData = encode_dldata(DL),
  <<Id:64, ULData/binary, DLData/binary>>.

encode_connections(Connections) -> encode_connections(Connections, <<>>).
encode_connections([], Acc) -> Acc;
encode_connections([Connection|Rest], Acc) ->
  ConnectionData = encode_connection(Connection),
  encode_connections(Rest, <<Acc/binary,ConnectionData/binary>>).


decode(<<HeaderData:256, ConnectionsData/bitstring>>) ->
  Header = decode_header(<<HeaderData:256>>),
  Connections = decode_connections(ConnectionsData),
  #msg{
    header = Header,
    connections = Connections
  }.
decode_header(<<Ver:8, CellId:52, Seq:64, Ts:64, ConnCount:16, SchLoad:8, 0:?PADDING>>) ->
  #header{
    version = Ver,
    cell_id = CellId,
    seq = Seq,
    timestamp = Ts,
    conn_count = ConnCount,
    sch_load = SchLoad
  }.
decode_connections(ConnectionsData) -> decode_connections(ConnectionsData, []).

decode_connections(<<>>, Acc) -> Acc;
decode_connections(<<ConnectionData:192, Rest/binary>>, Acc) ->
  Connection = decode_connection(<<ConnectionData:192>>),
  decode_connections(Rest, Acc++[Connection]).

decode_connection(<<Id:64, ULData:64, DLData:64>>) ->
  UL = decode_uldata(<<ULData:64>>),
  DL = decode_dldata(<<DLData:64>>),
  #connection{
    id = Id,
    ul_data = UL,
    dl_data = DL
  }.

decode_dldata(<<Tp:32, Latency:16, RSRP:8, RSRQ:8>>) ->
  #dl_data{
    throughput = Tp,
    latency = Latency,
    rsrp = RSRP,
    rsrq = RSRQ
  }.

decode_uldata(<<Tp:32, Latency:16, RSRP:8, RSRQ:8>>) ->
  #ul_data{
    throughput = Tp,
    latency = Latency,
    rsrp = RSRP,
    rsrq = RSRQ
  }.

%% pad to 8 octets
%%pad(Dec) when is_integer(Dec)->
%%  Binary = binary:encode_unsigned(Dec),
%%  case (8 - size(Binary) rem 8) rem 8 of
%%    0 -> Dec;
%%    N -> binary:decode_unsigned(<<Binary/binary, 0:(N*8)>>)
%%  end;
%%pad(Binary) when is_binary(Binary)->
%%  case (8 - size(Binary) rem 8) rem 8 of
%%    0 -> Binary;
%%    N -> <<Binary/binary, 0:(N*8)>>
%%  end.
