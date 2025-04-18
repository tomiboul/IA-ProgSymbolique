% INSTRUCTIONS
% =swipl echo-server.pl=
% =:- start_server.=
%
% Then navigate to http://localhost:3000 in your browser


:- module(echo_server,
  [ start_server/0,
    stop_server/0
  ]
).


:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_files)).
:- use_module(library(http/websocket)).
:- use_module('../chat', [reponse/2]).

%reponse(Query, 'reponse'). %code test pour envoyer au serveur la reponse

% http_handler docs: http://www.swi-prolog.org/pldoc/man?predicate=http_handler/3
% =http_handler(+Path, :Closure, +Options)=
%
% * root(.) indicates we're matching the root URL
% * We create a closure using =http_reply_from_files= to serve up files
%   in the local directory
% * The option =spawn= is used to spawn a thread to handle each new
%   request (not strictly necessary, but otherwise we can only handle one
%   client at a time since echo will block the thread)
:- http_handler(root(.),
                http_reply_from_files('.', []),
                [prefix]).

% * root(echo) indicates we're matching the echo path on the URL e.g.
%   localhost:3000/echo of the server
% * We create a closure using =http_upgrade_to_websocket=
% * The option =spawn= is used to spawn a thread to handle each new
%   request (not strictly necessary, but otherwise we can only handle one
%   client at a time since echo will block the thread)
:- http_handler(root(echo),
                http_upgrade_to_websocket(echo, []),
                [spawn([])]).

start_server :-
    default_port(Port),
    start_server(Port).
start_server(Port) :-
    http_server(http_dispatch, [port(Port)]).

stop_server() :-
    default_port(Port),
    stop_server(Port).
stop_server(Port) :-
    http_stop_server(Port, []).

default_port(3000).

%gpt 
query_prolog(QueryString, Response) :-
    term_to_atom(Term, QueryString), % On convertit la requête en terme Prolog
    (   call(Term)   % On exécute la requête Prolog
    ->  Response = "Requête réussie"
    ;   Response = "Requête échouée"
    ).

%! echo(+WebSocket) is nondet.
% This predicate is used to read in a message via websockets and echo it
% back to the client
echo(WebSocket) :-
    ws_receive(WebSocket, Message, [format(json)]),
    writeln(received(Message)),
    ( Message.opcode == close
    -> true
    ; Message.data = Dict,
      Dict.get(message) = UserMessage,
      reponse(UserMessage, Response),
      write("Response: "), writeln(Response),
      ws_send(WebSocket, json(Response)),
      echo(WebSocket)
    ).


%! get_response(+Message, -Response) is det.
% Pull the message content out of the JSON converted to a prolog dict
% then add the current time, then pass it back up to be sent to the
% client
get_response(Message, Response) :-
  reponse(Message.message, Response), 
  Response = _{message: Message.message, reponse: Response}.

