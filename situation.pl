%%:- module(situation, [ajoutLutin/3]).
%% etat(ListeLutin, ListePont, OrdreJeu)
:- use_module(jeu, [ajoutLutin/3, deplaceLutin/4, suppLutin/3 , deplacePont/4, suppPont/3]).

eliminationJoueur((ListeLutin, ListePont, OrdreJeu), (Couleur, _, _), (NewListeLutin, ListePont, NewOrdreJeu)):-
    findall((Couleur, PositionX, PositionY), member((Couleur, _, _), ListeLutin), ListeLutinCouleur), 
    verifLutin(ListeLutinCouleur, ListePont),
    suppAllLutin((Couleur, _, _), ListeLutin, NewListeLutin),
    suppLutinOrdrejeu((Couleur, _, _),OrdreJeu, NewOrdreJeu).


/**
 * On vérifie que chaque lutin de meme couleur ne possède plus aucun pont sur sa case 
 * donc aucune possibilité pour les lutins de se déplacer sur une autre case actuellement
*/
verifLutin([], ListePont).
verifLutin(((Couleur, X, Y)|Reste), ListePont):-
    Xplus is X + 1,
    Yplus is Y + 1,
    Xmoins is X - 1,
    Ymoins is Y - 1,
    
    not(member((X,Y)-(Xplus,Y), ListePont)),
    not(member((X,Y)-(Xmoins,Y), ListePont)),
    not(member((X,Y)-(X,Yplus), ListePont)),
    not(member((X,Y)-(X,Ymoins), ListePont)),
    verifLutin(Reste, ListeLutin).

/**
 * On supprimer tous les lutins de la couleur du joueur qui a perdu
*/
suppAllLutin((Couleur, _, _), [], []):- !.

suppAllLutin((Couleur, _, _), [(Couleur, X, Y)|Reste], NewListeLutin):-
    suppAllLutin((Couleur, _, _), Reste, NewListeLutin), !.

suppAllLutin((Couleur, _, _), [(CouleurLutin, X, Y)|Reste], [(CouleurLutin, X, Y)|NewListeLutin]):-
    Couleur \= CouleurLutin,
    suppAllLutin((Couleur, _, _), Reste, NewListeLutin), !.

/**
 * Enlève la possibilité au joeur donc plus aucun ne sont disponible de jouer 
 * en enlevant la couleur dans les tours de jeux
*/
suppLutinOrdrejeu((Couleur, _, _), OrdreJeu, NewOrdreJeu):-
    delete(Couleur, OrdreJeu, NewOrdreJeu).

infini(100000000000).
negative_infini(100000000000).

/*
    Prédicat pour le tour de jeu après la phase de placement
    à utiliser dans le prédicat IA
*/
min_max((ListeLutin, ListePont, OrdreJeu), 0, BooleanMaxTurn, ValueMinMax, (NewListeLutin, NewListePont, NewOrdreJeu)).


/**
 * Reste aucun lutins adverses
*/
%%min_max((ListeLutin, ListePont, OrdreJeu), Depth, BooleanMaxTurn, (NewListeLutin, NewListePont, NewOrdreJeu)):-


fct_max(Value, (ListeLutin, ListePont, OrdreJeu), Depth, BooleanMaxTurn, (NewListeLutin, NewListePont, NewOrdreJeu), Result ):-
    ReduceDepth is Depth - 1,
    min_max((ListeLutin, ListePont, OrdreJeu), ReduceDepth, BooleanMaxTurn, ValueMinMax, (NewListeLutin, NewListePont, NewOrdreJeu)),
    ( Value =< ValueMinMax -> Result is ValueMinMax ; Result is Value).

fct_min(Value, (ListeLutin, ListePont, OrdreJeu), Depth, BooleanMaxTurn, (NewListeLutin, NewListePont, NewOrdreJeu), Result ):-
    ReduceDepth is Depth - 1,
    min_max((ListeLutin, ListePont, OrdreJeu), ReduceDepth, BooleanMaxTurn, ValueMinMax, (NewListeLutin, NewListePont, NewOrdreJeu)),
    ( Value =< ValueMinMax -> Result is Value ; Result is ValueMinMax).

