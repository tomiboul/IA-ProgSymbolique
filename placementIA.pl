:- module(placementIA, []).
:- use_module(situation, [rotation/2]).

/*
listes des ponts 
[(1,1)-(1,2), (1,2)-(1,3), (1,3)-(1,4), (1,4)-(1,5), (1,5)-(1,6), (2,1)-(2,2), (2,2)-(2,3), (2,3)-(2,4), (2,4)-(2,5), (2,5)-(2,6), (3,1)-(3,2), (3,2)-(3,3), (3,3)-(3,4), (3,4)-(3,5), (3,5)-(3,6), (4,1)-(4,2), (4,2)-(4,3), (4,3)-(4,4), (4,4)-(4,5), (4,5)-(4,6), (5,1)-(5,2), (5,2)-(5,3), (5,3)-(5,4), (5,4)-(5,5), (5,5)-(5,6), (6,1)-(6,2), (6,2)-(6,3), (6,3)-(6,4), (6,4)-(6,5), (6,5)-(6,6), (1,1)-(2,1), (2,1)-(3,1), (3,1)-(4,1), (4,1)-(5,1), (5,1)-(6,1), (1,2)-(2,2), (2,2)-(3,2), (3,2)-(4,2), (4,2)-(5,2), (5,2)-(6,2), (1,3)-(2,3), (2,3)-(3,3), (3,3)-(4,3), (4,3)-(5,3), (5,3)-(6,3), (1,4)-(2,4), (2,4)-(3,4), (3,4)-(4,4), (4,4)-(5,4), (5,4)-(6,4), (1,5)-(2,5), (2,5)-(3,5), (3,5)-(4,5), (4,5)-(5,5), (5,5)-(6,5), (1,6)-(2,6), (2,6)-(3,6), (3,6)-(4,6), (4,6)-(5,6), (5,6)-(6,6)]
*/

iaPlacementH1(Etat, NewLutin):-
    placementLutinHeuristique1(Etat, ([NewLutin|Reste], ListePont, NextordreJeu)).

iaPlacementH2(Etat, NewLutin):-
    placementLutinHeuristique2(Etat, ([NewLutin|Reste], ListePont, NextordreJeu)).

/**
 * (IN, OUT)
 * Crée un nouveau lutin qui sera le plus éloigné des autres lutins adverses.
*/
placementLutinHeuristique1((ListeLutin, ListePont, [Couleur|Restant]), (NextListeLutin, ListePont, NextOrdreJeu)):-
    genereListePosition(ListeLutin, AllPositionPossible),
    genereListeDistanceMin(AllPositionPossible, ListeLutin, ListeDistanceMin),
    max_member((Score, X, Y), ListeDistanceMin),
    writeln((Score, X, Y)),
    not(member((_, X, Y), ListeLutin)),
    NextListeLutin = [(Couleur, X, Y)|ListeLutin],
    rotation([Couleur|Restant], NextOrdreJeu),
    !.



/**
 * (IN, OUT)
 * Crée un nouveau lutin sur une base aléatoire
*/
placementLutinHeuristique2((ListeLutin, ListePont, [Couleur|Restant]), (NextListeLutin, ListePont, NextOrdreJeu)):-
    generePositionHeuristique2(ListeLutin, NewX, NewY),
    not(member((_, NewX, NewY), ListeLutin)),  % facultatif car déjà vérifié dans generePosition
    NextListeLutin = [(Couleur, NewX, NewY)|ListeLutin],
    rotation([Couleur|Restant], NextOrdreJeu), !.


generePositionHeuristique2(ListeLutin, X, Y):-
    random_between(1, 6, NewX),
    random_between(1, 6, NewY),
    (member((_, NewX, NewY), ListeLutin) ->
        generePositionHeuristique2(ListeLutin, X, Y) 
        ;   
    (X = NewX, Y = NewY)). 


         

/**
 * (IN,OUT)
 * génère la liste des positions possible du prochain lutin (en enlevant les positions des lutins déja présents)
*/
genereListePosition(ListeLutin, Result):-
    genereListePositionAcc(1,1,[], TempResult), 
    findall((X,Y), 
            (member((X,Y), TempResult), not(member((_,X,Y), ListeLutin))), 
            Result),
    !.
genereListePositionAcc(6,6, Acc, [(6,6)|Acc]):- !.
genereListePositionAcc(X,Y, Acc, Result):-
    (Y < 6 -> NewY is Y + 1, genereListePositionAcc(X, NewY, [(X,Y)|Acc], Result)
    ;  NewX is X + 1,  genereListePositionAcc(NewX, 1, [(X,Y)|Acc], Result)
    ), !.



/**
 * (IN, IN, OUT)
 * Donne la liste des distances d'une position potentiel du nouveau lutin avec les lutins déja existants
*/
distanceManhattan(PositionPotentiel, ListeLutin, ListeDistant):-
    distanceManhattanAcc(PositionPotentiel, ListeLutin, [], ListeDistant), !.
distanceManhattanAcc(_, [], Acc, Acc):- !.
distanceManhattanAcc((NextX, NextY), [(_, X, Y)|Restant], Acc, ListeDistant):-
    Distance is  abs(NextX - X) + abs(NextY - Y),
    distanceManhattanAcc((NextX, NextY), Restant, [(Distance, X, Y)|Acc], ListeDistant).
    

/**
 * (IN, OUT)
 * Calcul la distance minimal parmis une liste de distance
*/
distanceMin(ListeDistant, Result):-
    distanceMinAcc(ListeDistant, (10000000, 10000000, 10000000), Result).
distanceMinAcc([], Acc, Acc).
distanceMinAcc([(Distance, X,Y)|Reste], (DistanceAcc, XAcc, YAcc), Result):-
    (Distance =< DistanceAcc 
        -> distanceMinAcc(Reste, (Distance, X, Y), Result)
        ;
        distanceMinAcc(Reste, (DistanceAcc, XAcc, YAcc), Result)).

/**
 * (IN, IN, OUT)
 * Cette fonction renvoie la liste des scores minimaux de cahque position poetentiel du futur lutin
*/
genereListeDistanceMin(ListePositionPotentiel, ListeLutin, ListeScoreMin ):-
    genereListeDistanceMinAcc(ListePositionPotentiel, ListeLutin, [], ListeScoreMin ).
genereListeDistanceMinAcc([], _, Acc, Acc).
genereListeDistanceMinAcc([(X, Y)|Reste], ListeLutin, Acc, ListeScoreMin):-
    distanceManhattan((X, Y), ListeLutin, ListeDistance),
    distanceMin(ListeDistance, (MinDistance, _, _)), 
    genereListeDistanceMinAcc(Reste, ListeLutin, [(MinDistance, X, Y)|Acc], ListeScoreMin).



