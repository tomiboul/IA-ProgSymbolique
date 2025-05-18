:- module(situation, [ajoutLutin/3, getScore/3, changevecteur/4, pontAProximite/4, ia/2]).

:- use_module(jeu, [ajoutLutin/3, deplaceLutin/5, suppLutin/3 , deplacePont/4, suppPont/3, pontExistant/2]).
:- use_module(heuristique, [heuristique/3, perdPointLutinAdverse/3, gagnePointMesJoueurs/3 , gagnePointMesPontsAutour/4]).

/*Predicat d'appel à ia avec les valeurs initialisées*/
ia((ListeLutin, ListePont, [P1|R]), ReformatageEtat):-
    writeln("passe dans l'ia"),
    max_n_elag((ListeLutin, ListePont, [P1|R]), P1, 6, [(vert,0),(bleu,0),(rouge,0),(jaune,0)], NextScore, [(vert,-100000000000), (bleu,-100000000000), (rouge,-100000000000), (jaune,-100000000000)], NextEtat),
    reformatage((ListeLutin, ListePont, [P1|R]), NextEtat, ReformatageEtat).


/*predicat qui reformate le coup réalisé par l'ia tq 
((couleur, x,y), (newcouleur, newx, newy), (x1,y1)-(x2,y2), (newx1,newy1)-(newx2,newy2))
((bleu,1,2),(bleu2,2), (1,2)-(2,2), none) -> lutin déplacé et pont supprimé
((bleu,1,2),(bleu2,2), (1,2)-(2,2), (2,2)-(2,3))-> pont rotated
*/
reformatage((ListeLutin, ListePont, _), ([NewCoordLutin|NewResteLutin], NewListePont, _), (CoordLutin, NewCoordLutin, CoordPont, NewCoordPont)):-
    findLutinThatMoved(ListeLutin, [NewCoordLutin|NewResteLutin], (none,none,none), CoordLutin),
    findBridge(ListePont, NewListePont, (CoordPont, NewCoordPont)).

/*trouver le deplacement différent*/
findLutinThatMoved([Lutin], NewListeLutin, _, Lutin).
findLutinThatMoved([Lutin|ResteLutin], NewLutins, OldLutin, NewOldLutin):-
    (not(isLutinInListe(Lutin, NewLutins)))->NewOldLutin = Lutin;findLutinThatMoved(ResteLutin, NewLutins, OldLutin, NewOldLutin).


isLutinInListe(_, []):-false.
isLutinInListe(LutinToSearch, [Lutin|ResteLutin]):-(LutinToSearch \= Lutin)-> isLutinInListe(LutinToSearch, ResteLutin);true.



findBridge([Pont|RestePont], [Pont|NewRestePont], (OldPont, none)):-
    findDifferentBridge([Pont|RestePont], [Pont|NewRestePont], OldPont).

findBridge([P1,P2|RestePont], [P3,P4|NewRestePont], (OldPont, none)):-
    P2 = P3,
    findDifferentBridge([P1,P2|RestePont], [P3,P4|NewRestePont], OldPont).

findBridge([(X1,Y1)-(X2,Y2)|RestePont], [(X3,Y3)-(X4,Y4)|NewRestePont], (OldPont, (X3,Y3)-(X4,Y4))):-
    (X1,Y1)-(X2,Y2) \= (X3,Y3)-(X4,Y4),
    findDifferentBridge([(X1,Y1)-(X2,Y2)|RestePont], [(X3,Y3)-(X4,Y4)|NewRestePont], OldPont).


/*trouver le pont différent*/
findDifferentBridge([(X1,Y1)-(X2,Y2)], _, (X1,Y1)-(X2,Y2)).
findDifferentBridge([(X1,Y1)-(X2,Y2)|RestePont], [NewPont|NewRestePont],NewOldPont):-
    (member((X1,Y1)-(X2,Y2), [NewPont|NewRestePont]))->findDifferentBridge(RestePont, [NewPont|NewRestePont], NewOldPont);NewOldPont = (X1,Y1)-(X2,Y2).




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
max_n((ListeLutin, ListePont, OrdreJeu),JoueurActuel, _, Score, NextScore, _, _,(ListeLutin, ListePont, [JoueurActuel])):-
    plusLutinsAdverses(ListeLutin, ListePont, OrdreJeu, JoueurActuel),
    infini(X),
    changevecteur(Score, JoueurActuel, X, NextScore),!.

%% cas de base 2 : le joueur qu on cherche à maximiser perds (on veut le faire gagner)
max_n((ListeLutin, ListePont, Joueurs),JoueurActuel , _, Score, NextScore, _, _, (ListeLutin, ListePont, Joueurs)):- %Depth
    plusLutins(ListeLutin, ListePont, JoueurActuel),
    %%rotation(Joueurs, NouveauTourDeJoueur),
    negative_infini(X),
    changevecteur(Score, JoueurActuel, X, NextScore),!.
    
%% cas de base 3 : profondeur arrivé à une feuille.
max_n((ListeLutin, ListePont, OrdreJeu),_, 0, _, NextScore, _, CurrentBest, (ListeLutin, ListePont, OrdreJeu)):- % JoueurActuel, CurrentBest
    heuristique((ListeLutin, ListePont, OrdreJeu), [(vert,0),(bleu,0),(rouge,0),(jaune,0)], NextScore),!.
    
max_n((ListeLutin, ListePont, [JoueurActuel,NextPlayer|ResteJoueurs]), JoueurActuel, Depth, Score, NextScore, Bornes, none, (NextListeLutin, NextListePont, NextOrdreJeu)):-
    etatsPossibles((ListeLutin, ListePont,[JoueurActuel, NextPlayer|ResteJoueurs]),JoueurActuel, [PremierEtat|ResteEtat]),
    length([PremierEtat|ResteEtat], Prout),
    NewDepth is Depth -1,
    
    %%check le premier cas, la branche tout à gauche pour avoir une branche d'initialisation
    max_n(PremierEtat, NextPlayer, NewDepth, Score, NewSinit, _, _,CurrentEtat),
    InitBornes = NewSinit,
    CurrentBest = NewSinit,
    
    %%récupère tous les scores des coups possibles
    findall((NextEtat, NewScore), 
                (member(NextEtat, ResteEtat), 
                getScore(NewSinit, JoueurActuel, S), 
                getScore(InitBornes, JoueurActuel, B), 
              
            
                ((S=<B)->(max_n(NextEtat, NextPlayer, NewDepth, NewSinit, NewScore, InitBornes, CurrentBest, _)); 
                changevecteur(InitBornes, JoueurActuel, S, NewBornes), InitBornes = NewBornes, CurrentBest = Score)), 
            Scores),
   
    negative_infini(X),
    %%récupère l'état qui propose le meilleur score parmis tous ceux renvoyés par le findall
    findBestMove(Scores, JoueurActuel, (CurrentEtat, CurrentBest), ((NextListeLutin, NextListePont, NextOrdreJeu), NextScore)), !.

max_n((ListeLutin, ListePont, [JoueurActuel,NextPlayer|ResteJoueurs]), JoueurActuel, Depth, Score, NextScore, Bornes, CurrentBest, (NextListeLutin, NextListePont, NextOrdreJeu)):-
    etatsPossibles((ListeLutin, ListePont,[JoueurActuel, NextPlayer|ResteJoueurs]),JoueurActuel, ListeEtat),
    NewDepth is Depth -1,
    length(ListeEtat, Prout),

    %%récupère tous les scores des coups possibles
    
    findall((NextEtat, NewScore), 
                (member(NextEtat, ListeEtat),
                getScore(Score, JoueurActuel, S), 
                getScore(Bornes, JoueurActuel, B), 
                ((S=<B)->(max_n(NextEtat, NextPlayer, NewDepth, Score, NewScore, Bornes, CurrentBest, _))
                ;
                changevecteur(Bornes, JoueurActuel, S, NewBornes), Bornes = NewBornes,CurrentBest = Score)), 
            Scores),
        
    negative_infini(X),
    %%récupère l'état qui propose le meilleur score parmis tous ceux renvoyés par le findall
    findBestMove(Scores, JoueurActuel, (([],[],[]), [(vert, X), (bleu, X), (rouge, X), (jaune,X)]), ((NextListeLutin, NextListePont, NextOrdreJeu), NextScore)), !.


%%---------------------------------------------------------------------------------
%%###########################################################""
%% cas de base 1 : on s arrête quand plus de lutins adverses.
max_n_elag((ListeLutin, ListePont, OrdreJeu),JoueurActuel, _, Score, NextScore,  _,(ListeLutin, ListePont, [JoueurActuel])):-
    plusLutinsAdverses(ListeLutin, ListePont, OrdreJeu, JoueurActuel),
    infini(X),
    changevecteur(Score, JoueurActuel, X, NextScore),!.

%% cas de base 2 : le joueur qu on cherche à maximiser perds (on veut le faire gagner)
max_n_elag((ListeLutin, ListePont, Joueurs),JoueurActuel , _, Score, NextScore, _, (ListeLutin, ListePont, Joueurs)):- %Depth
    plusLutins(ListeLutin, ListePont, JoueurActuel),
    %%rotation(Joueurs, NouveauTourDeJoueur),
    negative_infini(X), 
    changevecteur(Score, JoueurActuel, X, NextScore),!.
    
%% cas de base 3 : profondeur arrivé à une feuille.
max_n_elag((ListeLutin, ListePont, OrdreJeu),_, 0, _, NextScore,  CurrentBest, (ListeLutin, ListePont, OrdreJeu)):- % JoueurActuel, CurrentBest
    heuristique((ListeLutin, ListePont, OrdreJeu), [(vert,0),(bleu,0),(rouge,0),(jaune,0)], NextScore),!.
    

max_n_elag((ListeLutin, ListePont, [JoueurActuel,NextPlayer|ResteJoueurs]), JoueurActuel, Depth, Score, NextScore, CurrentBest, (NextListeLutin, NextListePont, NextOrdreJeu)):-
    etatsPossibles((ListeLutin, ListePont,[JoueurActuel, NextPlayer|ResteJoueurs]),JoueurActuel, ListeEtat),

    NewDepth is Depth -1,
    %%negative_infini(X),
    %%InitScore = [(vert,X), (bleu,X), (rouge,X), (jaune,X)],
    
    evaluer_etats(ListeEtat, NextPlayer, NewDepth, CurrentBest, ([],[],[]), (NextListeLutin, NextListePont, NextOrdreJeu), NextScore).
   

evaluer_etats([], _, _, BestScore, BestEtat, BestEtat, BestScore).

evaluer_etats([Etat | Reste], JoueurActuel, Depth, CurrentBestScore, CurrentBestEtat, BestEtatFinal, BestScoreFinal) :-
    %%évalue la branche et assure qu'on va voir tout en bas à gauche
    negative_infini(X),
    InitScore = [(vert,X), (bleu,X), (rouge,X), (jaune,X)],
    
    max_n_elag(Etat, JoueurActuel, Depth, InitScore, Score, CurrentBestScore, _),
    getScore(Score, JoueurActuel, S),
    
    getScore(CurrentBestScore, JoueurActuel, B),
    ( S < B ->
            (BestEtatFinal = Etat,
            BestScoreFinal = Score)
        ;
            (
            getScore(CurrentBestScore, JoueurActuel, SBest),
            (S > SBest ->NewBestScore = Score,NewBestEtat = Etat
            ;
            NewBestScore = CurrentBestScore,
            NewBestEtat = CurrentBestEtat
            ),
            evaluer_etats(Reste, JoueurActuel, Depth, NewBestScore, NewBestEtat, BestEtatFinal, BestScoreFinal)
            )
    ).

%################################
%%---------------------------------------------------------------------------------------------------


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

plusLutins([], _, _).
plusLutins([(Couleur, X, Y)|ResteLutin], ListePont, Couleur):-
    X1 is X+1,
    not(member((X,Y)-(X1,Y),ListePont)),
    Y1 is Y+1,
    not(member((X,Y)-(X,Y1),ListePont)),
    X2 is X-1,
    not(member((X2,Y)-(X,Y),ListePont)),
    Y2 is Y-1,
    not(member((X,Y2)-(X,Y),ListePont)),
    plusLutins(ResteLutin, ListePont, Couleur).
    
plusLutins([(CouleurLutin, _, _)|Reste], ListePont, Couleur) :-
    CouleurLutin \= Couleur,
    plusLutins(Reste, ListePont, Couleur).
  
plusLutinsAdverses(_, _, [], _).
plusLutinsAdverses(ListeLutin, ListePont, [C1|Reste], Couleur):-
    (C1==Couleur)->plusLutinsAdverses(ListeLutin, ListePont, Reste, Couleur); plusLutins(ListeLutin, ListePont, C1),plusLutinsAdverses(ListeLutin, ListePont, Reste, Couleur).



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
    lutinLePlusEnDanger((ListeLutin, ListePont, OrdreJeu), ListeLutin, JoueurActuel, (none, none, none), 10000, (CouleurLutinEnDanger, XLutinEnDanger, YLutinEnDanger), _),
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

lutinLePlusEnDanger(([], ListePont, OrdreJeu), ListeLutin,JoueurActuel, Lutin,NbrPonts, Lutin, NbrPonts).
lutinLePlusEnDanger(([(Couleur, X,Y)|ResteLutin], ListePont, OrdreJeu), ListeLutin, JoueurActuel, Lutin, NbrPonts, NewLutin, NewPonts):-
    (Couleur == JoueurActuel)->
    (
        (
        nbrPontPresLutin((JoueurActuel, X,Y), ListePont, 0, Nbr),
        (Nbr=<NbrPonts, findall(ListeLutinPossible, deplaceLutin((JoueurActuel, X,Y), (JoueurActuel, X1,Y1), ListePont, ListeLutin, ListeLutinPossible), L), length(L, Skibidi), Skibidi \= 0)->
            lutinLePlusEnDanger((ResteLutin, ListePont, OrdreJeu), ListeLutin, JoueurActuel, (JoueurActuel, X, Y), Nbr, NewLutin, NewPonts)
            ;
            lutinLePlusEnDanger((ResteLutin, ListePont, OrdreJeu), ListeLutin, JoueurActuel, Lutin, NbrPonts, NewLutin, NewPonts)
        )
    );
    lutinLePlusEnDanger((ResteLutin, ListePont, OrdreJeu), ListeLutin, JoueurActuel, Lutin, NbrPonts, NewLutin, NewPonts).





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
    
    %%ponts intéressants à déplcer, ponts au contact d'un lutin adverse ou allié
    findall((Pont),(member(Pont, ListePont),pontPresLutin(Pont, ListeLutin, none)),ListePontDeplac),
    sort(ListePontDeplac, ListePontDeplacer),

    findall((Pont2), (member(Pont2, ListePontDeplacer), pontPresLutin(Pont2, ListeLutin, JoueurActuel)), ListePontSupp),
    sort(ListePontSupp, ListePontSupprimer).

%%heuristique de choix de pont stratégiquement intéressant à prendre en compte pour limiter les appels récursifs
pontInteressantADeplacerOuSupprimerV2((ListeLutin, ListePont, OrdreJeu), JoueurActuel, ListePontDeplacer, ListePontDeplacer):-
    length(ListePont, Z),
    
    %%ponts intéressants à déplcer, ponts au contact d'un lutin adverse ou allié
    findall((Pont),(member(Pont, ListePont),pontPresLutin(Pont, ListeLutin, JoueurActuel)),ListePontDeplac),
    sort(ListePontDeplac, ListePontDeplacer),
    length(ListePontDeplacer, T).

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
