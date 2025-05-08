%%:- module(situation, [ajoutLutin/3]).
%% etat(ListeLutin, ListePont, OrdreJeu)
:- use_module(jeu, [ajoutLutin/3, deplaceLutin/5, suppLutin/3 , deplacePont/4, suppPont/3, pontExistant/2]).

eliminationJoueur((ListeLutin, ListePont, OrdreJeu), (Couleur, _, _), (NewListeLutin, ListePont, NewOrdreJeu)):-
    findall((Couleur, _, _), member((Couleur, _, _), ListeLutin), ListeLutinCouleur), 
    verifLutin(ListeLutinCouleur, ListePont),
    suppAllLutin((Couleur, _, _), ListeLutin, NewListeLutin),
    suppLutinOrdrejeu((Couleur, _, _),OrdreJeu, NewOrdreJeu).


/* ################################################################################################################## */
/* ######################################## partie où on gere les tours ############################################# */
/* ################################################################################################################## */ 
/**
 * Met le tour au joueur suivant
*/
rotation([Joueur1,Joueur2,Joueur3,Joueur4], Result):-
    Result = [Joueur2,Joueur3,Joueur4 |[Joueur1]].
rotation([Joueur1,Joueur2,Joueur3], Result):-
    Result = [Joueur2,Joueur3 |[Joueur1]].
rotation([Joueur1,Joueur2], Result):-
    Result = [Joueur2|[Joueur1]].


/* ################################################################################################################## */
/* ####################################### partie où on gere les lutins ############################################# */
/* ################################################################################################################## */

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

%% cas de base 1 : on s arrête quand plus de lutins adverses.
max_n((ListeLutin, ListePont, OrdreJeu),JoueurActuel, _, Score, NextScore, _, _,(ListeLutin, ListePont, [JoueurActuel])):-
    plusLutinsAdverses(ListeLutin, ListePont, JoueurActuel),
    infini(X),
    changevecteur(Score, JoueurActuel, X, NextScore),!.

%% cas de base 2 : le joueur qu on cherche à maximiser perds (on veut le faire gagner)
max_n((ListeLutin, ListePont, Joueurs),JoueurActuel , Depth, Score, NextScore, _, _, (ListeLutin, ListePont, Joueurs)):-
    not(member(JoueurActuel, Joueurs)),
    rotation(Joueurs, NouveauTourDeJoueur),
    negative_infini(X),
    changevecteur(Score, JoueurActuel, X, NextScore),!.
    
%% cas de base 3 : profondeur arrivé à une feuille.
max_n((ListeLutin, ListePont, OrdreJeu),JoueurActuel, 0, _, NextScore, _, CurrentBest, (ListeLutin, ListePont, OrdreJeu)):-
    heuristique((ListeLutin, ListePont, OrdreJeu), [(vert,0),(bleu,0),(rouge,0),(jaune,0)], NextScore),!.
    
max_n((ListeLutin, ListePont, [JoueurActuel,NextPlayer|ResteJoueurs]), JoueurActuel, Depth, Score, NextScore, Bornes, none, (NextListeLutin, NextListePont, NextOrdreJeu)):-
    etatsPossibles((ListeLutin, ListePont,[JoueurActuel, NextPlayer|ResteJoueurs]),JoueurActuel, [PremierEtat|ResteEtat]),

    NewDepth is Depth -1,
    max_n(PremierEtat, NextPlayer, NewDepth, Score, NewSinit, _, _,CurrentEtat),
    %%writeln("AAAAAAAAAAAH"),
    %%writeln(CurrentBest + "est comparé à" + NewSinit),
    %%writeln(InitBornes + "est comparé à" + NewSinit),
    InitBornes = NewSinit,
    CurrentBest = NewSinit,
    
    %%récupère tous les scores des coups possibles
    findall((NextEtat, NewScore), 
    (member(NextEtat, ResteEtat), 
    getScore(Score, JoueurActuel, S), 
    getScore(InitBornes, JoueurActuel, B),

    ((S<B)->(changevecteur(InitBornes, JoueurActuel, S, NewBornes),max_n(NextEtat, NextPlayer, NewDepth, Score, NewScore, NewBornes, CurrentBest, _)); 
    CurrentBest = Score)), 
    Scores),

    negative_infini(X),
    %%récupère l'état qui propose le meilleur score parmis tous ceux renvoyés par le findall
    findBestMove(Scores, JoueurActuel, (CurrentEtat, CurrentBest), ((NextListeLutin, NextListePont, NextOrdreJeu), NextScore)), !.

max_n((ListeLutin, ListePont, [JoueurActuel,NextPlayer|ResteJoueurs]), JoueurActuel, Depth, Score, NextScore, Bornes, CurrentBest, (NextListeLutin, NextListePont, NextOrdreJeu)):-
    etatsPossibles((ListeLutin, ListePont,[JoueurActuel, NextPlayer|ResteJoueurs]),JoueurActuel, ListeEtat),
    NewDepth is Depth -1,

    %%récupère tous les scores des coups possibles
    
    findall((NextEtat, NewScore), 
    (member(NextEtat, ListeEtat), 
    getScore(Score, JoueurActuel, S), 
    getScore(Bornes, JoueurActuel, B), 
    ((S<B)->(changevecteur(Bornes, JoueurActuel, S, NewBornes), max_n(NextEtat, NextPlayer, NewDepth, Score, NewScore, NewBornes, CurrentBest, _));CurrentBest = Score)), 
    Scores),
    negative_infini(X),
    %%récupère l'état qui propose le meilleur score parmis tous ceux renvoyés par le findall
    findBestMove(Scores, JoueurActuel, (([],[],[]), [(vert, X), (bleu, X), (rouge, X), (jaune,X)]), ((NextListeLutin, NextListePont, NextOrdreJeu), NextScore)), !.

getScore([(JoueurActuel, S1), (J2,S2), (J3,S3), (J4,S4)], JoueurActuel, S1).
getScore([(J1, S1), (JoueurActuel,S2), (J3,S3), (J4,S4)], JoueurActuel, S2).
getScore([(J1, S1), (J2,S2), (JoueurActuel,S3), (J4,S4)], JoueurActuel, S3).
getScore([(J1, S1), (J2,S2), (J3,S3), (JoueurActuel,S4)], JoueurActuel, S4).

plusLutinsAdverses([], _, _).
plusLutinsAdverses([(CouleurLutin, X, Y)|ResteLutin], ListePont, Couleur):-
    CouleurLutin \= Couleur,
    X1 is X+1,
    not(member((X,Y)-(X1,Y),ListePont)),
    Y1 is Y+1,
    not(member((X,Y)-(X,Y1),ListePont)),
    X2 is X-1,
    not(member((X2,Y)-(X,Y),ListePont)),
    Y2 is Y-1,
    not(member((X,Y2)-(X,Y),ListePont)),
    plusLutinsAdverses(ResteLutin, ListePont, Couleur).
    
    
plusLutinsAdverses([(CouleurLutin, _, _)|Reste], ListePont, Couleur) :-
    CouleurLutin == Couleur,
    plusLutinsAdverses(Reste, ListePont, Couleur).
  
exec_ia(NextEtat, NextScore):-max_n(
    ([(bleu, 1, 1), (vert, 5, 5), (bleu,2,3), (rouge,4,5),(jaune,2,5)], [(1,1)-(2,1),(1,2)-(2,2),(1,3)-(1,4),(1,3)-(2,3),(1,4)-(1,5),(1,4)-(2,4),(1,5)-(1,6),(1,5)-(2,5),(1,6)-(2,6),(2,1)-(2,2),(2,1)-(3,1),(2,2)-(2,3),(2,2)-(3,2),(2,3)-(2,4),(2,6)-(3,6),(3,1)-(3,2),(3,1)-(4,1),(3,2)-(4,2),(3,4)-(3,5),(3,4)-(4,4),(3,5)-(3,6),(3,5)-(4,5),(4,1)-(5,1),(4,2)-(4,3),(4,2)-(5,2),(4,3)-(5,3),(4,4)-(4,5),(4,4)-(5,4),(4,5)-(4,6),(4,6)-(5,6),(5,2)-(6,2),(5,3)-(5,4),(5,3)-(6,3),(5,4)-(5,5),(5,4)-(6,4),(5,5)-(5,6),(5,5)-(6,5),(5,6)-(6,6),(6,1)-(6,2),(6,2)-(6,3)], [bleu, vert, rouge, jaune]), bleu, 4, [(vert,0),(bleu,0),(rouge,0),(jaune,0)], NextScore,[(rouge, 10000000), (jaune, 10000000), (vert,10000000), (bleu, 10000000)], none, NextEtat).


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
        suppPont((X2,Y2)-(X3,Y3), ListePont, ListePontPossible))
        ),
        ListeEtat
    ).





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
/* ################################################ Heuristique ##################################################### */
/* ################################################################################################################## */
/* ################################## Fonction servant à calculer les scores ######################################## */
/* ################################################################################################################## */

heuristique((ListeLutin, ListePont, []), Scores, Scores).
heuristique((ListeLutin, ListePont, [Couleur|Reste]), Scores, FinalScores):-
    getScore(Scores, Couleur, S),
    perdPointLutinAdverse(ListeLutin, (Couleur, S), NewScore),
    gagnePointMesJoueurs(ListeLutin, (Couleur, NewScore), NewNewScore),
    gagnePointMesPontsAutour(ListeLutin, (Couleur, NewNewScore), ListePont, NewNewNewScore),
    
    changevecteur(Scores, Couleur, NewNewNewScore, NewScores),
    heuristique((ListeLutin, ListePont, Reste), NewScores, FinalScores).
    



    
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
    (CouleurLutin = Couleur -> NewAcc is Acc ; NewAcc is Acc + 4),
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
    (CouleurLutin \= Couleur -> NewAcc is Acc ; NewAcc is Acc + 16),
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

