:- module(ecrire_reponse,[ecrire_reponse/1]).

ecrire_reponse(L) :-
    nl, 
    write('PBot :'),
    ecrire_ligne(L,1,1,Mf).

% ecrire_ligne(Li,Mi,Ei,Mf)
% input : Li, liste de mots a ecrire
%         Mi, indique si le premier caractere du premier mot 
%            doit etre mis en majuscule (1 si oui, 0 si non)
%         Ei, indique le nombre d espaces avant ce premier mot 
% output : Mf, booleen tel que decrit ci-dessus a appliquer 
% a la ligne suivante, si elle existe

ecrire_ligne([],M,_,M) :- 
    nl.
 
 ecrire_ligne([M|L],Mi,Ei,Mf) :-
    ecrire_mot(M,Mi,Maux,Ei,Eaux),
    ecrire_ligne(L,Maux,Eaux,Mf).

% ecrire_mot(M,B1,B2,E1,E2)
% input : M, le mot a ecrire
%         B1, indique s il faut une majuscule (1 si oui, 0 si non)
%         E1, indique s il faut un espace avant le mot (1 si oui, 0 si non)
% output : B2, indique si le mot suivant prend une majuscule
%          E2, indique si le mot suivant doit etre precede d'un espace

ecrire_mot('.',_,1,_,1) :-
    write('. '), !.
 ecrire_mot('\'',X,X,_,0) :-
    write('\''), !.
 ecrire_mot(',',X,X,E,1) :-
    espace(E), write(','), !.
 ecrire_mot(M,0,0,E,1) :-
    espace(E), write(M).
 ecrire_mot(M,1,0,E,1) :-
    name(M,[C|L]),
    D is C - 32,
    name(N,[D|L]),
    espace(E), write(N).


espace(0).
espace(N) :- N>0, Nn is N-1, write(' '), espace(Nn).