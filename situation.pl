%%:- module(situation, [ajoutLutin/3]).
%% etat(ListeLutin, ListePont, OrdreJeu)
:- use_module(jeu, [ajoutLutin/3, deplaceLutin/4, suppLutin/3 , deplacePont/4, suppPont/3]).

eliminationJoueur((ListeLutin, ListePont, OrdreJeu), (Couleur, _, _), (NewListeLutin, ListePont, NewOrdreJeu)):-
    findall((Couleur, _, _), member((Couleur, _, _), ListeLutin), ListeLutinCouleur), 
    verifLutin(ListeLutinCouleur, ListePont),
    suppAllLutin((Couleur, _, _), ListeLutin, NewListeLutin),
    suppLutinOrdrejeu((Couleur, _, _),OrdreJeu, NewOrdreJeu).


/**
 * On vérifie que chaque lutin de meme couleur ne possède plus aucun pont sur sa case 
 * donc aucune possibilité pour les lutins de se déplacer sur une autre case actuellement
*/
verifLutin([], _).
verifLutin(((_, X, Y)|Reste), ListePont):-
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
suppAllLutin((_, _, _), [], []):- !.

suppAllLutin((Couleur, _, _), [(Couleur, _, _)|Reste], NewListeLutin):-
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


/* ################################################################################################################## */
/* ################################################################################################################## */
/* ###################################### partie MinMAx ( pas alpha beta )########################################### */
/* ################################################################################################################## */
/* ################################################################################################################## */

infini(100000000000).
negative_infini(100000000000).

/*
    Prédicat pour le tour de jeu après la phase de placement
    à utiliser dans le prédicat IA
*/
min_max((ListeLutin, ListePont, OrdreJeu), 0, BooleanMaxTurn, Score, (NewListeLutin, NewListePont, NewOrdreJeu)):-
    heuristique((ListeLutin, ListePont, OrdreJeu), Score).
    


/**
 * Calcul maximum between current value and MinMax with a depth - 1
*/
fct_max(Value, (ListeLutin, ListePont, OrdreJeu), Depth, BooleanMaxTurn, (NewListeLutin, NewListePont, NewOrdreJeu), Result ):-
    ReduceDepth is Depth - 1,
    min_max((ListeLutin, ListePont, OrdreJeu), ReduceDepth, BooleanMaxTurn, ValueMinMax, (NewListeLutin, NewListePont, NewOrdreJeu)),
    ( Value =< ValueMinMax -> Result is ValueMinMax ; Result is Value).

/**
 * Calcul minimum between current value and MinMax with a depth - 1
*/
fct_min(Value, (ListeLutin, ListePont, OrdreJeu), Depth, BooleanMaxTurn, (NewListeLutin, NewListePont, NewOrdreJeu), Result ):-
    ReduceDepth is Depth - 1,
    min_max((ListeLutin, ListePont, OrdreJeu), ReduceDepth, BooleanMaxTurn, ValueMinMax, (NewListeLutin, NewListePont, NewOrdreJeu)),
    ( Value =< ValueMinMax -> Result is Value ; Result is ValueMinMax).



heuristique((ListeLutin, ListePont, [Couleur|Reste]), Scores).



/*
 compte les ponts d'une proximité de maximum 2 de la case ####
*/
pontAProximite((_,X,Y), [], Compte, Compte).
pontAProximite((_,X,Y), [(X1, Y1)-(X2,Y2)|RestePont], Compte, CompteRecursif):-

    ((
        ((X1 is X+1; X1 = X; X1 is X-1), (Y1 is Y+1; Y1 = Y; Y1 is Y-1)); /* Tous les ponts autour de la case centrale */
        ((X1 is X - 2, Y1 = Y),(X2 is X - 1, Y2 = Y)); /* pont 2 cases vers le gauche */
        ((X1 is X + 1, Y1 = Y),(X2 is X + 2, Y2 = Y)); /* pont 2 cases vers le droite */ 
        ((X1 = X , Y1 is Y - 2),(X2 = X, Y2 is Y - 1)) /* pont 2 cases vers le bas */
    ) -> Newcompte is Compte + 1
    ; 
        Newcompte is Compte
    ),
    pontAProximite((_,X,Y), RestePont, Newcompte, CompteRecursif).

