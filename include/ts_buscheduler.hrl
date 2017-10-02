%%%-------------------------------------------------------------------
%%% @author vasco
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. Sep 2017 5:07 PM
%%%-------------------------------------------------------------------
-author("vasco").
-vc('$Id$ ').

% A representation of a <buscheduler/> tag, a single BU Scheduler message request
% being sent to the server (BU application). Send requests can have a ack="no_ack"
% property, which makes them not wait for a response frame from the
% server.
%
% type (atom)
%   either connect, send, ping or close
%
% url (string)
%   the URL to issue the initial GET request to, only used if type is connect, defaults to "/"
%
% origin (string | undefined)
%   optional contents of the Origin for the initial GET request, only
%   used if type is connect, not sent if undefined
%
% data (binary)
%   the payload to be sent, ignored in connect requests
-record(buscheduler_request, {
  type = raw,
  data
}).

-record(buschedule_session, {
  state
}).