:- module(ia, [ia/0]).
:- use_module(jeu, [ajoutLutin/3]).

ia:-
    %% les lutins de couleur bleu et rouge seront 
    %% d´eplac´es par une intelligence artificielle
    ajoutLutin((bleu, 2,3),[], X),
    writeln(X).
