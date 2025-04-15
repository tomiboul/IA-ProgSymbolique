%% :- module(jeu, [reponse/2]).

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
lutin(Vert, 3, 4).
%%listeLutin = [].

/*#################### Les ponts #####################*/
/*
exemple de pont a ajouté :
pont(X, Y).
*/
pont((3, 4)-(4, 4)).
%%listePont = [].

/*#################### La carte #####################*/
ailleCarte(6,6).

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
    
suppLutin((_, X, Y), ListeLutin, NewListeLutin):-
    delete(ListeLutin, (_, X, Y), NewListeLutin).
    
/*################# Fonction ponts ##################*/
ajoutPont((X, Y), ListePont, NewListePont):- %% a enleve car de souvenir on peut pas ajouter des ponts
    number(X),
    number(Y),
    X =< 6,
    X >= 1,
    Y =< 6,
    Y >= 1,
    NewListePont = [(X, Y)|ListePont].
    
suppPont((X, Y), ListePont, NewListePont):- %% A finir car pont pas correctement def : ca doit etre ainsi pont((3, 4)-(4, 4)).
    delete(ListePont, (X, Y), NewListePont).

deplacerPont((X, Y), ListePont, NewListePont):-  %% A finir car pont pas correctement def : ca doit etre ainsi pont((3, 4)-(4, 4)).
    delete(ListePont, (X, Y), TempListePont),
    NewListePont = [(X,Y)|TempListePont].