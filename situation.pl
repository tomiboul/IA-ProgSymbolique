:- module(situation, [ajoutLutin/3, getScore/3, changevecteur/4, pontAProximite/4]).

:- use_module(jeu, [ajoutLutin/3, deplaceLutin/5, suppLutin/3 , deplacePont/4, suppPont/3, pontExistant/2]).
:- use_module(heuristique, [heuristique/3, perdPointLutinAdverse/3, gagnePointMesJoueurs/3 , gagnePointMesPontsAutour/4]).




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
/* ################################################################################################################## */
/* ###################################### partie Max^N ( pas alpha beta )############################################ */
/* ################################################################################################################## */
/* ################################################################################################################## */

infini(100000000000).
negative_infini(-100000000000).



%% cas de base 1 : on s arrête quand plus de lutins adverses.
max_n((ListeLutin, ListePont, _),JoueurActuel, _, Score, NextScore, _, _,(ListeLutin, ListePont, [JoueurActuel])):-
    plusLutinsAdverses(ListeLutin, ListePont, JoueurActuel),
    infini(X),
    changevecteur(Score, JoueurActuel, X, NextScore),!.

%% cas de base 2 : le joueur qu on cherche à maximiser perds (on veut le faire gagner)
max_n((ListeLutin, ListePont, Joueurs),JoueurActuel , _, Score, NextScore, _, _, (ListeLutin, ListePont, Joueurs)):- %Depth
    not(member(JoueurActuel, Joueurs)),
    %%rotation(Joueurs, NouveauTourDeJoueur),
    negative_infini(X),
    changevecteur(Score, JoueurActuel, X, NextScore),!.
    
%% cas de base 3 : profondeur arrivé à une feuille.
max_n((ListeLutin, ListePont, OrdreJeu),_, 0, _, NextScore, _, CurrentBest, (ListeLutin, ListePont, OrdreJeu)):- % JoueurActuel, CurrentBest
    heuristique((ListeLutin, ListePont, OrdreJeu), [(vert,0),(bleu,0),(rouge,0),(jaune,0)], NextScore),!.
    
max_n((ListeLutin, ListePont, [JoueurActuel,NextPlayer|ResteJoueurs]), JoueurActuel, Depth, Score, NextScore, Bornes, none, (NextListeLutin, NextListePont, NextOrdreJeu)):-
    etatsPossibles((ListeLutin, ListePont,[JoueurActuel, NextPlayer|ResteJoueurs]),JoueurActuel, [PremierEtat|ResteEtat]),
    length([PremierEtat|ResteEtat], Prout),
    %%writeln("prout = " + Prout),
    NewDepth is Depth -1,
    max_n(PremierEtat, NextPlayer, NewDepth, Score, NewSinit, _, _,CurrentEtat),
    writeln(Score),
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
                writeln("S : " + S),
                writeln("B : " + B),
                ((S<B)->(max_n(NextEtat, NextPlayer, NewDepth, Score, NewScore, InitBornes, CurrentBest, _)); 
                changevecteur(InitBornes, JoueurActuel, S, NewBornes),CurrentBest = Score)), 
            Scores),

    negative_infini(X),
    %%récupère l'état qui propose le meilleur score parmis tous ceux renvoyés par le findall
    findBestMove(Scores, JoueurActuel, (CurrentEtat, CurrentBest), ((NextListeLutin, NextListePont, NextOrdreJeu), NextScore)), !.

max_n((ListeLutin, ListePont, [JoueurActuel,NextPlayer|ResteJoueurs]), JoueurActuel, Depth, Score, NextScore, Bornes, CurrentBest, (NextListeLutin, NextListePont, NextOrdreJeu)):-
    etatsPossibles((ListeLutin, ListePont,[JoueurActuel, NextPlayer|ResteJoueurs]),JoueurActuel, ListeEtat),
    NewDepth is Depth -1,
    length(ListeEtat, Prout),
    %%writeln("prout" +Prout),

    %%récupère tous les scores des coups possibles
    
    findall((NextEtat, NewScore), 
                (member(NextEtat, ListeEtat),
                getScore(Score, JoueurActuel, S), 
                getScore(Bornes, JoueurActuel, B), 
                ((S<B)->(max_n(NextEtat, NextPlayer, NewDepth, Score, NewScore, Bornes, CurrentBest, _))
                ;
                changevecteur(Bornes, JoueurActuel, S, NewBornes), CurrentBest = Score)), 
            Scores),
        
    negative_infini(X),
    writeln(Scores),
    writeln("\n\n\n"),
    %%récupère l'état qui propose le meilleur score parmis tous ceux renvoyés par le findall
    findBestMove(Scores, JoueurActuel, (([],[],[]), [(vert, X), (bleu, X), (rouge, X), (jaune,X)]), ((NextListeLutin, NextListePont, NextOrdreJeu), NextScore)), !.




/* ################################################################################################################## */
/* ########################################## Les scores des joueurs  ############################################### */
/* ################################################################################################################## */ 

/**
 * Donne le score du joueur recherché
*/
getScore([(JoueurActuel, S1), (J2,S2), (J3,S3), (J4,S4)], JoueurActuel, S1).
getScore([(J1, S1), (JoueurActuel,S2), (J3,S3), (J4,S4)], JoueurActuel, S2).
getScore([(J1, S1), (J2,S2), (JoueurActuel,S3), (J4,S4)], JoueurActuel, S3).
getScore([(J1, S1), (J2,S2), (J3,S3), (JoueurActuel,S4)], JoueurActuel, S4).


/**
*Change le vecteur de score avec la valeur et couleur donnée en entrée (fonctionnel)
*/
changevecteur([(Couleur, Score)|ResteScore], Couleur, NewScoreInteger, [(Couleur, NewScoreInteger)|ResteScore]).
changevecteur([(Couleur1, Score)|ResteScore], Couleur2, NewScoreInteger, [(Couleur1,Score)|NewScorevecteur]):-
    changevecteur(ResteScore, Couleur2, NewScoreInteger, NewScorevecteur).



/* ################################################################################################################## */
/* ######################################## condition pour la victoire ############################################## */
/* ################################################################################################################## */ 

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
  

/*
exec_ia(NextEtat, NextScore):-max_n(
    ([(vert, 1, 2), (vert, 1, 1), (rouge, 6, 6), (rouge, 5, 6), (rouge, 4, 6), (jaune, 1, 6), (jaune, 1, 5), (bleu, 2, 4), (bleu, 3, 3)], [(1,1)-(1,2),(1,1)-(2,1),(1,2)-(1,3),(1,2)-(2,2),(1,3)-(1,4),(1,3)-(2,3),(1,4)-(1,5),(1,4)-(2,4),(1,5)-(1,6),(1,5)-(2,5),(1,6)-(2,6),(2,1)-(2,2),(2,1)-(3,1),(2,2)-(2,3),(2,2)-(3,2),(2,3)-(2,4),(2,4)-(3,4),(2,5)-(2,6),(2,5)-(3,5),(2,6)-(3,6),(3,1)-(3,2),(3,1)-(4,1),(3,2)-(4,2),(3,3)-(3,4),(3,3)-(4,3),(3,4)-(3,5),(3,4)-(4,4),(3,5)-(3,6),(3,5)-(4,5),(3,6)-(4,6),(4,1)-(4,2),(4,1)-(5,1),(4,2)-(4,3),(4,2)-(5,2),(4,3)-(4,4),(4,3)-(5,3),(4,4)-(4,5),(4,4)-(5,4),(4,5)-(4,6),(4,5)-(5,5),(4,6)-(5,6),(5,1)-(5,2),(5,1)-(6,1),(5,2)-(5,3),(5,2)-(6,2),(5,3)-(5,4),(5,3)-(6,3),(5,4)-(5,5),(5,4)-(6,4),(5,5)-(5,6),(5,5)-(6,5),(5,6)-(6,6),(6,1)-(6,2),(6,2)-(6,3),(6,3)-(6,4),(6,4)-(6,5),(6,5)-(6,6)], [jaune, vert, rouge, bleu]), 
    jaune, 2, [(vert,0),(bleu,0),(rouge,0),(jaune,0)], 
    NextScore,
    [(rouge, 10000000), (jaune, 10000000), (vert,10000000), (bleu, 10000000)], 
    none, 
    NextEtat).
*/

/*
    * Renvoie le meilleur move à faire, et son score associé  (in, in, in, out) (fonctionnel)
*/
findBestMove([],_, (MeilleurEtat, MeilleurScore), (MeilleurEtat, MeilleurScore)).
findBestMove([(Etat, Score)|Reste], JoueurActuel, (MeilleurEtatPrecedent, MeilleurScorePrecedent), (NewEtat, NewScore)):-
    getScore(Score, JoueurActuel, WantedScore),
    getScore(MeilleurScorePrecedent, JoueurActuel, MeilleurWantedScore),
    (WantedScore >= MeilleurWantedScore)->
    findBestMove(Reste, JoueurActuel, (Etat, Score),(NewEtat, NewScore));
    findBestMove(Reste, JoueurActuel, (MeilleurEtatPrecedent, MeilleurScorePrecedent), (NewEtat, NewScore)).    





/*
##########################################################################################################################################
##################################################### PREDICATS ETATS POSSIBLES ##########################################################
##########################################################################################################################################
*/


/**
* Renvoie les coups possibles à partir d'un état (in, in, out)
*/
etatsPossibles((ListeLutin, ListePont, OrdreJeu), JoueurActuel, ListeEtat):-
    pontInteressantADeplacerOuSupprimerV2((ListeLutin, ListePont, OrdreJeu),JoueurActuel, ListePontDeplacer, ListePontSupprimer),
    lutinLePlusEnDanger((ListeLutin, ListePont, OrdreJeu), JoueurActuel, (none, none, none), 10000, (CouleurLutinEnDanger, XLutinEnDanger, YLutinEnDanger), _),
    rotation(OrdreJeu, OrdreJeuPossible),
   
    findall(
        (ListeLutinPossible, ListePontPossible, OrdreJeuPossible),
        ((CouleurLutinEnDanger, XLutinEnDanger, YLutinEnDanger) = (JoueurActuel,X,Y),deplaceLutin((JoueurActuel, X, Y), (JoueurActuel, X1, Y1),ListePont, ListeLutin, ListeLutinPossible),
        ((member(Pont, ListePontDeplacer), deplacePont(Pont, NewPont, ListePont, ListePontPossible)) ; 
        member(Pont2, ListePontSupprimer),suppPont(Pont2, ListePont, ListePontPossible))
        ),
        ListeEtat
    ).

etatsPossiblesSansModif((ListeLutin, ListePont, OrdreJeu), JoueurActuel, ListeEtat):-
    rotation(OrdreJeu, OrdreJeuPossible),
    
    findall(
        (ListeLutinPossible, ListePontPossible, OrdreJeuPossible),
        (deplaceLutin((JoueurActuel, X, Y), (JoueurActuel, X1, Y1),ListePont, ListeLutin, ListeLutinPossible),
        ((member(Pont, ListePont), deplacePont(Pont, NewPont, ListePont, ListePontPossible)) ; 
        member(Pont2, ListePont),suppPont(Pont2, ListePont, ListePontPossible))
        ),
        ListeEtat
    ).

/*
##########################################################################################################################################
 ############################################## PREDICAT CHOIX DE DEPLACEMENT ###########################################################
##########################################################################################################################################
*/

lutinLePlusEnDanger(([], ListePont, OrdreJeu), JoueurActuel, Lutin,NbrPonts, Lutin, NbrPonts).
lutinLePlusEnDanger(([(Couleur, X,Y)|ResteLutin], ListePont, OrdreJeu), JoueurActuel, Lutin, NbrPonts, NewLutin, NewPonts):-
    (Couleur == JoueurActuel)->
    (
        (
        nbrPontPresLutin((JoueurActuel, X,Y), ListePont, 0, Nbr),
        (Nbr=<NbrPonts)->
            lutinLePlusEnDanger((ResteLutin, ListePont, OrdreJeu), JoueurActuel, (JoueurActuel, X, Y), Nbr, NewLutin, NewPonts)
            ;
            lutinLePlusEnDanger((ResteLutin, ListePont, OrdreJeu), JoueurActuel, Lutin, NbrPonts, NewLutin, NewPonts)
        )
    );
    lutinLePlusEnDanger((ResteLutin, ListePont, OrdreJeu), JoueurActuel, Lutin, NbrPonts, NewLutin, NewPonts).





/*Renvoie nbr ponts autour d'un lutin*/
nbrPontPresLutin(Lutin, [], Nombre, Nombre).
nbrPontPresLutin(Lutin, [Pont | RestePont], Nombre, NewNombre):-
    (pontPresLutin(Pont, [Lutin], none) -> NewNombre2 is Nombre+1, nbrPontPresLutin(Lutin, RestePont, NewNombre2, NewNombre)
        ;
        nbrPontPresLutin(Lutin, RestePont, Nombre, NewNombre)
    ).
    

/*
##########################################################################################################################################
########################################################## PREDICAT CHOIX DE PONTS #######################################################
##########################################################################################################################################
*/

%%heuristique de choix de pont stratégiquement intéressant à prendre en compte pour limiter les appels récursifs
pontInteressantADeplacerOuSupprimer((ListeLutin, ListePont, OrdreJeu), JoueurActuel, ListePontDeplacer, ListePontSupprimer):-
    %%length(ListePont, Z),
    %%writeln("TailleListePont : " + Z),
    
    %%ponts intéressants à déplcer, ponts au contact d'un lutin adverse ou allié
    findall((Pont),(member(Pont, ListePont),pontPresLutin(Pont, ListeLutin, none)),ListePontDeplac),
    sort(ListePontDeplac, ListePontDeplacer),
    %%length(ListePontDeplacer, T),
    %%writeln("TailleDeplacer : "+ T),
    findall((Pont2), (member(Pont2, ListePontDeplacer), pontPresLutin(Pont2, ListeLutin, JoueurActuel)), ListePontSupp),
    sort(ListePontSupp, ListePontSupprimer).
    %%length(ListePontSupprimer, N),
    %%writeln("TailleSupp : " + N).


%%heuristique de choix de pont stratégiquement intéressant à prendre en compte pour limiter les appels récursifs
pontInteressantADeplacerOuSupprimerV2((ListeLutin, ListePont, OrdreJeu), JoueurActuel, ListePontDeplacer, ListePontDeplacer):-
    length(ListePont, Z),
    %%writeln("TailleListePont : " + Z),
    
    %%ponts intéressants à déplcer, ponts au contact d'un lutin adverse ou allié
    findall((Pont),(member(Pont, ListePont),pontPresLutin(Pont, ListeLutin, JoueurActuel)),ListePontDeplac),
    sort(ListePontDeplac, ListePontDeplacer),
    length(ListePontDeplacer, T).
    %%writeln("TailleDeplacer : "+ T).

    %%length(ListePontSupprimer, N),
    %%writeln("TailleSupp : " + N).

/*
renvoie si tel pont est proche d'un lutin quelconque
*/
pontPresLutin(Pont, [], _):-false.
pontPresLutin(Pont, [(Couleur, X,Y)|Reste], none):-
    NewX is X+1,NewY is Y+1,NewX2 is X-1,NewY2 is Y-1,


    (Pont = (X,Y)-(NewX,Y2),!;
    
    Pont =(X,Y)-(X,NewY),!;
   
    Pont =(NewX2,Y)-(X,Y),!;
    
    Pont =(X,NewY2)-(X,Y),!);
   
    pontPresLutin(Pont, Reste, none),!.

/*
renvoie si tel pont est proche d'un lutin adverse du joueur actuel
*/
pontPresLutin(Pont, [(Couleur, X,Y)|Reste], JoueurActuel):-
    (Couleur \= JoueurActuel)->
    (
    NewX is X+1,NewY is Y+1,NewX2 is X-1,NewY2 is Y-1,

    (Pont = (X,Y)-(NewX,Y2),!;
    
    Pont =(X,Y)-(X,NewY),!;
   
    Pont =(NewX2,Y)-(X,Y),!;
    
    Pont =(X,NewY2)-(X,Y),!) ;(pontPresLutin(Pont, Reste, JoueurActuel),!));
    
    (pontPresLutin(Pont, Reste, JoueurActuel),!).



/*
 compte les ponts d'une proximité de maximum 2 de la case ####
 (in, in, in, out) -  3e in doit commencer à 0
*/
pontAProximite((_,X,Y), [], Compte, Compte).
pontAProximite((_,X,Y), [(X1, Y1)-(X2,Y2)|RestePont], Compte, CompteRecursif):-

    ((
        (((X1 is X+1; X1 = X; X1 is X-1), (Y1 is Y+1; Y1 = Y; Y1 is Y-1)))->Newcompte is Compte+2 /* Tous les ponts autour de la case centrale */
        ;
        (
        ((X1 is X - 2, Y1 = Y),(X2 is X - 1, Y2 = Y)); /* pont 2 cases vers le gauche */
        ((X1 is X + 1, Y1 = Y),(X2 is X + 2, Y2 = Y)); /* pont 2 cases vers le droite */ 
        ((X1 = X , Y1 is Y - 2),(X2 = X, Y2 is Y - 1)) /* pont 2 cases vers le bas */
    ) -> Newcompte is Compte + 1
    ; 
        Newcompte is Compte
    )),
    pontAProximite((_,X,Y), RestePont, Newcompte, CompteRecursif).
