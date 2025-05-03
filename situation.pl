%%:- module(situation, [ajoutLutin/3]).
%% etat(ListeLutin, ListePont, OrdreJeu)
:- use_module(jeu, [ajoutLutin/3, deplaceLutin/5, suppLutin/3 , deplacePont/4, suppPont/3, pontExistant/2]).

eliminationJoueur((ListeLutin, ListePont, OrdreJeu), (Couleur, _, _), (NewListeLutin, ListePont, NewOrdreJeu)):-
    findall((Couleur, _, _), member((Couleur, _, _), ListeLutin), ListeLutinCouleur), 
    verifLutin(ListeLutinCouleur, ListePont),
    suppAllLutin((Couleur, _, _), ListeLutin, NewListeLutin),
    suppLutinOrdrejeu((Couleur, _, _),OrdreJeu, NewOrdreJeu).


/**
 * Met le tour au joueur suivant
*/
rotation([Joueur1,Joueur2,Joueur3,Joueur4], Result):-
    Result = [Joueur2,Joueur3,Joueur4 |[Joueur1]].
rotation([Joueur1,Joueur2,Joueur3], Result):-
    Result = [Joueur2,Joueur3 |[Joueur1]].
rotation([Joueur1,Joueur2], Result):-
    Result = [Joueur2|[Joueur1]].


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
/* ###################################### partie Max^N ( pas alpha beta )############################################ */
/* ################################################################################################################## */
/* ################################################################################################################## */

infini(100000000000).
negative_infini(-100000000000).


/*
    Prédicat pour le tour de jeu après la phase de placement
    à utiliser dans le prédicat IA
*/
%% cas de base 1 : profondeur arrivé à une feuille.
max_n((ListeLutin, ListePont, OrdreJeu),JoueurActuel, 0, Score, NextScore, (ListeLutin, ListePont, OrdreJeu)).
    heuristique((ListeLutin, ListePont, OrdreJeu), Score).

%%forme du score
%%[(Vert, 5), (Rouge, 7), (Jaune, 2), (Bleu, 9)]

%% cas de base 2 : on s arrête quand plus de lutins adverses.
max_n((ListeLutin, ListePont, [JoueurActuel]),JoueurActuel, _, Score, NextScore, (ListeLutin, ListePont, [JoueurActuel])):-
    infini(X),
    changevecteur(Score, JoueurActuel, X, NewScore).

%% cas de base 3 : le joueur qu on cherche à maximiser perds (on veut le faire gagner)
max_n((ListeLutin, ListePont, Joueurs),JoueurActuel , _, Score, NextScore, (ListeLutin, ListePont, Joueurs)):-
    not(member(JoueurActuel, Joueurs)),
    rotation([Couleur1|Reste], NouveauTourDeJoueur),
    negative_infini(X),
    changevecteur(Score, JoueurActuel, X, NewScore).
    
    
max_n((ListeLutin, ListePont, [P1,NextPlayer|ResteJoueurs]), JoueurActuel, Depth, Score, NextScore, (NextListeLutin, NextListePont, NextOrdreJeu)):-
    etatsPossibles((ListeLutin, ListePont,OrdreJeu),JoueurActuel, ListeEtat),

    %%récupère tous les scores des coups possibles
    findall((NextEtat, NewScore), 
    (member(NextEtat, ListeEtat), max_n(NextEtat, NextPlayer, Depth-1, NextScore, NewScore, _)), 
    Scores),

    negative_infini(X),
    %%récupère l'état qui propose le meilleur score parmis tous ceux renvoyés par le findall
    findBestMove(Scores, JoueurActuel, (([],[],[]), X), ((NextListeLutin, NextListePont, NextOrdreJeu), NextScore)).

getScore([(JoueurActuel, S1), (J2,S2), (J3,S3), (J4,S4)], JoueurActuel, S1).
getScore([(J1, S1), (JoueurActuel,S2), (J3,S3), (J4,S4)], JoueurActuel, S2).
getScore([(J1, S1), (J2,S2), (JoueurActuel,S3), (J4,S4)], JoueurActuel, S3).
getScore([(J1, S1), (J2,S2), (J3,S3), (JoueurActuel,S4)], JoueurActuel, S4).

/*Renvoie le meilleur move à faire, et son score associé  (in, in, in, out) (fonctionnel)*/
findBestMove([],_, (MeilleurEtat, MeilleurScore), (MeilleurEtat, MeilleurScore)).
findBestMove([(Etat, Score)|Reste], JoueurActuel, (MeilleurEtatPrecedent, MeilleurScorePrecedent), (NewEtat, NewScore)):-
    getScore(Score, JoueurActuel, WantedScore),
    getScore(MeilleurScorePrecedent, JoueurActuel, MeilleurWantedScore),
    (WantedScore >= MeilleurWantedScore)->
    findBestMove(Reste, JoueurActuel, (Etat, Score),(NewEtat, NewScore));
    findBestMove(Reste, JoueurActuel, (MeilleurEtatPrecedent, MeilleurScorePrecedent), (NewEtat, NewScore)).    



/**
*Change le vecteur de score avec la valeur et couleur donnée en entrée (fonctionnel)
*/
changevecteur([(Couleur, Score)|ResteScore], Couleur, NewScoreInteger, [(Couleur, NewScoreInteger)|ResteScore]).
changevecteur([(Couleur1, Score)|ResteScore], Couleur2, NewScoreInteger, [(Couleur1,Score)|NewScorevecteur]):-
    changevecteur(ResteScore, Couleur2, NewScoreInteger, NewScorevecteur).

/**
* Renvoie les coups possibles à partir d'un état (in, in, out)
*/
etatsPossibles((ListeLutin, ListePont, OrdreJeu), JoueurActuel, ListeEtat):-
    rotation(OrdreJeu, OrdreJeuPossible),
    
    findall(
        (ListeLutinPossible, ListePontPossible, OrdreJeuPossible),
        (deplaceLutin((JoueurActuel, X, Y), (JoueurActuel, X1, Y1),ListePont, ListeLutin, ListeLutinPossible),
        ((pontExistant(ListePont, Pont), deplacePont(Pont, NewPont, ListePont, ListePontPossible)) ; 
        suppPont((X2,Y2)-(X3,Y3), ListePont, ListePontPossible)), write("un cas \n")
        ),
        ListeEtat
    ).


/**
 * Calcul maximum between current value and MinMax with a depth - 1
*/
/*fct_max(Value, (ListeLutin, ListePont, OrdreJeu), Depth, BooleanMaxTurn, (NewListeLutin, NewListePont, NewOrdreJeu), Result ):-
    ReduceDepth is Depth - 1,
    min_max((ListeLutin, ListePont, OrdreJeu), ReduceDepth, ValueMinMax, (NewListeLutin, NewListePont, NewOrdreJeu)),
    ( Value =< ValueMinMax -> Result is ValueMinMax ; Result is Value).*/

/**
 * Calcul minimum between current value and MinMax with a depth - 1
*/
/*fct_min(Value, (ListeLutin, ListePont, OrdreJeu), Depth, BooleanMaxTurn, (NewListeLutin, NewListePont, NewOrdreJeu), Result ):-
    ReduceDepth is Depth - 1,
    min_max((ListeLutin, ListePont, OrdreJeu), ReduceDepth, ValueMinMax, (NewListeLutin, NewListePont, NewOrdreJeu)),
    ( Value =< ValueMinMax -> Result is Value ; Result is ValueMinMax).*/



heuristique((ListeLutin, ListePont, [Couleur|Reste]), Scores).



/*
 compte les ponts d'une proximité de maximum 2 de la case ####
 (in, in, in, out) -  3e in doit commencer à 0
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


/* ################################################################################################################## */
/* ################################## Fonction servant à calculer les scores ######################################## */
/* ################################################################################################################## */


/**
 * Enlève des points aux scores du joueur qu on cherche à maximiser en fonction du 
 * nombre de lutin d'une couleure différente de lui
 * (in, in, out)
 * (en fonction du nbre de point a enlever modifier la valeur ici "NewAcc is Acc + 1")
*/
perdPointLutinAdverse([(CouleurLutin, _, _)|Reste], (Couleur, Score), ScoreFinal ):-
    perdPointLutinAdverseAcc([(CouleurLutin, _, _)|Reste], (Couleur, Score), ScoreFinal, 0 ).

perdPointLutinAdverseAcc([], (Couleur, Score), ScoreFinal, Acc ):-
    ScoreFinal is Score - Acc.
perdPointLutinAdverseAcc([(CouleurLutin, _, _)|Reste], (Couleur, Score), Result, Acc ):-
    (CouleurLutin = Couleur -> NewAcc is Acc ; NewAcc is Acc + 1),
    perdPointLutinAdverseAcc(Reste, (Couleur, Score), Result, NewAcc ).


/**
 * Ajoute des points aux scores du joueur qu on cherche à maximiser en fonction du 
 * nombre de lutin de la meme couleur que lui
 * (in, in, out)
 * (en fonction du nbre de point a enlever modifier la valeur ici "NewAcc is Acc + 1")
*/
gagnePointMesJoueurs([(CouleurLutin, _, _)|Reste], (Couleur, Score), ScoreFinal ):-
    gagnePointMesJoueurs([(CouleurLutin, _, _)|Reste], (Couleur, Score), ScoreFinal, 0 ).

gagnePointMesJoueurs([], (Couleur, Score), ScoreFinal, Acc ):-
    ScoreFinal is Score + Acc.
gagnePointMesJoueurs([(CouleurLutin, _, _)|Reste], (Couleur, Score), Result, Acc ):-
    (CouleurLutin \= Couleur -> NewAcc is Acc ; NewAcc is Acc + 1),
    gagnePointMesJoueurs(Reste, (Couleur, Score), Result, NewAcc ).


/**
 * Ajoute des points aux scores du joueur qu on cherche à maximiser en fonction du 
 * nombre de pont à une proximité de maximum 2 de la case 
 * (in, in, in, out)
*/
gagnePointMesPontsAutour([(CouleurLutin, X, Y)|Reste], (Couleur, Score), ListePont, ScoreFinal ):-
    gagnePointMesPontsAutour([(CouleurLutin, X, Y)|Reste], (Couleur, Score),ListePont,  ScoreFinal, 0 ).

gagnePointMesPontsAutour([], (_, Score), _, ScoreFinal, Acc ):-
    ScoreFinal is Score + Acc.
gagnePointMesPontsAutour([(CouleurLutin, X, Y)|Reste], (Couleur, Score), ListePont, Result, Acc ):-
    (CouleurLutin \= Couleur -> NewAcc is Acc ; pontAProximite((CouleurLutin,X,Y), ListePont, 0, Compte), NewAcc is Acc + Compte),
    gagnePointMesPontsAutour(Reste, (Couleur, Score), ListePont, Result, NewAcc ).

