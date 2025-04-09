/*Définition du minimum de trois valeurs */
min3(A, B, C, Min) :- 
   min(A, B, Min1), 
   min(Min1, C, Min).

min(A, B, A) :- A =< B, !.
min(_, B, B).

/* Fonction principale : conversion string -> liste */
lev(A, B, Dist) :-
   string_chars(A, ListA),  
   string_chars(B, ListB), 
   lev_list(ListA, ListB, Dist).

/* Version Levenshtein : */

/* 1. Formule Wikipedia : */

/* Cas de base 1 : si un des mots est de longueur 0 -> Dist = longueur de l'autre mot */
lev_list([], B, Dist) :- length(B, Dist).
lev_list(A, [], Dist) :- length(A, Dist).


/* Cas de base 2 : si les 2 mots commencent par la même lettre, on retire cette lettre et on rappelle lev() */
lev_list([Head | TailA], [Head | TailB], Dist) :-
   lev_list(TailA, TailB, Dist).


lev_list([_ | T1], [_ | T2], Dist) :-
   lev_list(T1, [_ | T2], Dist1),  % Opération n°1: suppression dans A
   lev_list([_ | T1], T2, Dist2),  % Opération n°2: suppression dans B
   lev_list(T1, T2, Dist3),   
        % Opération n°3: remplacement
   min3(Dist1, Dist2, Dist3, Min),
   Dist is Min + 1.  % Tenir compte de l'opération effectuée