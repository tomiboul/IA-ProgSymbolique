:- module(jeu, [ajoutLutin/3, deplaceLutin/4, suppLutin/3 , deplacePont/4, suppPont/3, pontExistant/2]).


/*################## Les couleurs ####################*/
couleur(vert).
couleur(bleu).
couleur(jaune).
couleur(rouge).

/*#################### Les lutins #####################*/
/*
exemple de lutin a ajouté :
lutin(Couleur, X, Y).
*/
%%lutin(Vert, 3, 4).
%%listeLutin = [].

/*#################### Les ponts #####################*/
/*
exemple de pont a ajouté :
pont(X, Y).
*/
%%pont((3, 4)-(4, 4)).
%%listePont = [].

/*#################### La carte #####################*/
tailleCarte(6,6).

/*############### Ordre du gameplay #################*/
ordreJoueur([Vert, Bleu, Jaune, Rouge]).

/*################# Fonction Lutins ##################*/
ajoutLutin((Couleur, X, Y), ListeLutin, NewListeLutin):-
    couleur(Couleur),
    number(X),
    number(Y),
    X =< 6,
    X >= 1,
    Y =< 6,
    Y >= 1,
    not(member((_, X,Y), ListeLutin)), %% on va vérifier qu il n existe pas deja de lutin a cette position
    NewListeLutin = [(Couleur, X, Y)|ListeLutin].

/*
deplaceLutin((Couleur, X, Y), (Couleur, NewX, NewY), ListeLutin, NewListeLutin):-
    number(X),
    number(Y),
    X =< 6,
    X >= 1,
    Y =< 6,
    Y >= 1,
    NewX =< 6,
    NewX >= 1,
    NewY =< 6,
    NewY >= 1,
    member((Couleur, X, Y), ListeLutin),
    not(member((Couleur, NewX, NewY), ListeLutin)),
    suppLutin((Couleur, X, Y), ListeDist, TempNewListeLutin),
    NewListeLutin = [(Couleur, NewX, NewY)|TempNewListeLutin], !.*/



deplaceLutin((Couleur, X, Y), (Couleur, NewX, NewY), ListePont, ListeLutin, NewListeLutin) :-
    member((Couleur, X, Y), ListeLutin),
    deplaceCaseACote(X, Y, NewX, NewY),
    (member((X,Y)-(NewX,NewY), ListePont);member((NewX,NewY)-(X,Y), ListePont)),
    \+ member((_, NewX, NewY), ListeLutin),
    suppLutin((Couleur, X, Y), ListeLutin, TempNewListeLutin),
    NewListeLutin = [(Couleur, NewX, NewY)|TempNewListeLutin].

deplaceCaseACote(X, Y, NewX, Y) :-
    (NewX is X + 1 ; NewX is X - 1),    
    NewX =< 6,
    NewX >= 1.

deplaceCaseACote(X, Y, X, NewY) :-
    (NewY is Y + 1 ; NewY is Y - 1),
    NewY =< 6,
    NewY >= 1.


/* ATTENTION ne pas remettre le '_' à la palce de Couleur car "nécéssaire" dans fichier situation.pl */
suppLutin((Couleur, X, Y), ListeLutin, NewListeLutin):-
    member((Couleur, X, Y), ListeLutin),
    delete(ListeLutin, (Couleur, X, Y), NewListeLutin).
    
pontExistant(ListePont, Pont):-
    member(Pont, ListePont).


/*################# Fonction ponts ##################*/
/**
* (in, in, in, out)
*/
deplacePont(((X1, Y1)-(X2,Y2)), ((NewX1, NewY1)-(NewX2,NewY2)), ListePont, NewListePont):- 
    %% a enleve car de souvenir on peut pas ajouter des ponts
    number(X1),
    number(Y1),
    number(X2),
    number(Y2),
    X1 =< 6,
    X1 >= 1,
    Y1 =< 6,
    Y1 >= 1,
    X2 =< 6,
    X2 >= 1,
    Y2 =< 6,
    Y2 >= 1,

    member(((X1, Y1)-(X2,Y2)), ListePont),
    
    %% Rotation de 90° du pont horizontal vers vertical (avec du coup les 4 possibilités)
    (Y1 = Y2 ->((NewX1 = X1, NewY1 is Y1 - 1, NewX2 = X1, NewY2 = Y1) ; 
                (NewX1 = X1, NewY1 = Y1, NewX2 = X1, NewY2 is Y1 + 1) ; 
                (NewX1 = X2, NewY1 is Y1 - 1, NewX2 = X2, NewY2 = Y1);
                (NewX1 = X2, NewY1 = Y1, NewX2 = X2, NewY2 is Y1 + 1))
    ; %% Rotation de 90° du pont vertical vers horizontal (avec du coup les 4 possibilités)
        ((NewX1 is X1 - 1, NewY1 = Y1, NewX2 = X1, NewY2 is Y1);
        (NewX1 = X1, NewY1 = Y1, NewX2 is X1 + 1, NewY2 is Y1);
        (NewX1 is X1 - 1, NewY1 = Y2, NewX2 = X1, NewY2 is Y2);            
        (NewX1 = X1, NewY1 = Y2, NewX2 is X1 + 1, NewY2 is Y2))
    ),
    
    NewX1 =< 6,
    NewX1 >= 1,
    NewY1 =< 6,
    NewY1 >= 1,
    NewX2 =< 6,
    NewX2 >= 1,
    NewY2 =< 6,
    NewY2 >= 1,

    not(member(((NewX1, NewY1)-(NewX2,NewY2)), ListePont)), %% on va vérifier qu il n existe pas deja de pont a cette position
    suppPont(((X1, Y1)-(X2,Y2)), ListePont, TempNewListePont),
    NewListePont = [((NewX1, NewY1)-(NewX2,NewY2))|TempNewListePont].
    

suppPont(((X1, Y1)-(X2,Y2)), ListePont, NewListePont):- 
    member((X1,Y1)-(X2,Y2), ListePont),
    delete(ListePont, ((X1, Y1)-(X2,Y2)), NewListePont).

