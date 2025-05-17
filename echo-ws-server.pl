% INSTRUCTIONS
% =swipl echo-ws-server.pl=
% =:- start_server.=
%
% Then navigate to http://localhost:3000 in your browser

:- set_prolog_flag(encoding, utf8).


:- module(echo_server,
  [ start_server/0,
    stop_server/0
  ]
).


:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_files)).
:- use_module(library(http/websocket)).
%:- use_module('../chat', [reponse/2]).
:- use_module('ChatBot/chat', [reponse/2]).
:- use_module('./situation', [ia/2]).


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


convert_elf([Color,X,Y], (Color,X,Y)).

convert_all_elves([], []).
convert_all_elves([H|T], [(C,X,Y)|Rest]) :-
    convert_elf(H, (C,X,Y)),
    convert_all_elves(T, Rest).
  

convert_elves([], []).
convert_elves([(ColorStr, X, Y) | T], [(ColorAtom, X, Y) | T2]) :-
    atom_string(ColorAtom, ColorStr),
    convert_elves(T, T2).



%! echo(+WebSocket) is nondet.
% This predicate is used to read in a message via websockets and echo it
% back to the client
echo(WebSocket) :-
    ws_receive(WebSocket, Message, [format(json)]),
    writeln(received(Message)),
    ( Message.opcode == close
    -> true
    ; Message.data = Dict,
      ( _{message: MsgData} :< Dict
      -> (

            ( string(MsgData)
            -> 
               reponse(MsgData, Response),
               write("Response: "), writeln(Response),
               ws_send(WebSocket, json(Response))
            ; 
              MsgData = _{elves: ElvesJson, bridges: Bridges, turnorder: TurnOrder},
              convert_all_elves(ElvesJson, Elves),
              write("Received state update:"), nl,
              write("Elves: "), writeln(Elves),
              write("Bridges: "), writeln(Bridges),
              write("Turn Order: "), writeln(TurnOrder),
              write('TYPE BRIDGES: '), write_term(Bridges, [quoted(true), portray(true)]), nl,
              string_to_atom(Bridges, BridgesAtom),
              read_term_from_atom(BridgesAtom, BridgesList, []), 
              read_term_from_atom(TurnOrder, TurnOrderList, []),
              convert_elves(Elves, ElvesList),
              writeln(TurnOrderList),
              

              writeln('Appel ia/2...'),
              ia((ElvesList, BridgesList, TurnOrderList), Result),
              writeln('Après ia/2'),
              writeln(Result),
              ws_send(WebSocket, json(Result))

              
            )
         )
      ; writeln("Malformed message received.")
      ),
      echo(WebSocket)
    ).


%! get_response(+Message, -Response) is det.
% Pull the message content out of the JSON converted to a prolog dict
% then add the current time, then pass it back up to be sent to the
% client
get_response(Message, Response) :-
  reponse(Message.message, Response), 
  Response = _{message: Message.message, reponse: Response}.

