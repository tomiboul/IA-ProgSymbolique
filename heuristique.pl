%% les fonctions à import vers les autres fonctions
:- module(heuristique, [heuristique/3, perdPointLutinAdverse/3, gagnePointMesJoueurs/3 , gagnePointMesPontsAutour/4]).

%% les fct appelées depuis le fichier situation
:- use_module(situation,[getScore/3, changevecteur/4, pontAProximite/4]).


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
    /*NewNewNewScore is STemp*2,
    perdPointPontLutinAdverse(ListeLutin, (Couleur, NewNewNewScore), ListePont, NewNewNewNewScore),*/
    
    changevecteur(Scores, Couleur, NewNewNewScore, NewScores),
    heuristique((ListeLutin, ListePont, Reste), NewScores, FinalScores).
    



/* ################################################################################################################## */
/* ############################################# Perds des points ################################################### */
/* ################################################################################################################## */
/**
 * Enlève des points aux scores du joueur qu on cherche à maximiser en fonction du 
 * nombre de lutin d'une couleure différente de lui
 * (in, in, out)
 * (en fonction du nbre de point a enlever modifier la valeur ici "NewAcc is Acc + 4")
*/
perdPointLutinAdverse([(CouleurLutin, _, _)|Reste], (Couleur, Score), ScoreFinal ):-
    perdPointLutinAdverseAcc([(CouleurLutin, _, _)|Reste], (Couleur, Score), ScoreFinal, 0 ).

perdPointLutinAdverseAcc([], (Couleur, Score), ScoreFinal, Acc ):-
    ScoreFinal is Score - Acc.
perdPointLutinAdverseAcc([(CouleurLutin, _, _)|Reste], (Couleur, Score), Result, Acc ):-
    (CouleurLutin = Couleur -> NewAcc is Acc ; NewAcc is Acc + 4),
    perdPointLutinAdverseAcc(Reste, (Couleur, Score), Result, NewAcc ).




/**
 * Enlève des points aux scores du joueur qu on cherche à maximiser en fonction du 
 * nombre de ponts pres des lutin d'une couleure différente de lui
 * (in, in, out)
 * (en fonction du nbre de point a enlever modifier la valeur ici "NewAcc is Acc + 1")
*/
perdPointPontLutinAdverse([(CouleurLutin, X, Y)|Reste], (Couleur, Score), ListePont, ScoreFinal ):-
    perdPointPontLutinAdverseAcc([(CouleurLutin, X, Y)|Reste], (Couleur, Score),ListePont,  ScoreFinal, 0 ).
    

perdPointPontLutinAdverseAcc([], (_, Score), _, ScoreFinal, Acc ):-
    ScoreFinal is Score - Acc.
perdPointPontLutinAdverseAcc([(CouleurLutin, X, Y)|Reste], (Couleur, Score), ListePont, Result, Acc ):-
    (CouleurLutin = Couleur -> NewAcc is Acc ; pontAProximite((CouleurLutin,X,Y), ListePont, 0, Compte), NewAcc is Acc + Compte),
    perdPointPontLutinAdverseAcc(Reste, (Couleur, Score), ListePont, Result, NewAcc).



/* ################################################################################################################## */
/* ############################################# Gagne des points ################################################### */
/* ################################################################################################################## */

/**
 * Ajoute des points aux scores du joueur qu on cherche à maximiser en fonction du 
 * nombre de lutin de la meme couleur que lui
 * (in, in, out)
 * (en fonction du nbre de point a enlever modifier la valeur ici "NewAcc is Acc + 16")
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
    gagnePointMesPontsAutourAcc([(CouleurLutin, X, Y)|Reste], (Couleur, Score),ListePont,  ScoreFinal, 0 ).

gagnePointMesPontsAutourAcc([], (_, Score), _, ScoreFinal, Acc ):-
    ScoreFinal is Score + Acc.
gagnePointMesPontsAutourAcc([(CouleurLutin, X, Y)|Reste], (Couleur, Score), ListePont, Result, Acc ):-
    (CouleurLutin \= Couleur -> NewAcc is Acc ; pontAProximite((CouleurLutin,X,Y), ListePont, 0, Compte), NewAcc is Acc + Compte),
    gagnePointMesPontsAutourAcc(Reste, (Couleur, Score), ListePont, Result, NewAcc ).




