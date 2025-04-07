
 
 /* Fonction principale : conversion string -> liste */
 levenshtein(A, B, Dist) :-
    string_chars(A, ListCharA),  
    string_chars(B, ListCharB), 
    lev_list(ListCharA, ListCharB, Dist, [], []).
 
 
 /* Version Levenshtein : */
 /* 1. Formule Wikipedia : */
 
 /* Cas de base 1 : si un des mots est de longueur 0 -> Dist = longueur de l'autre mot */
 lev_list(A, [], Dist_I, TabInit, TabOut) :- length(A, Dist_I).
 lev_list([], B, Dist_J, TabInit, TabOut) :- length(B, Dist_J).
 
 
 /* Cas de base 2 : si les 2 mots commencent par la même lettre, on retire cette lettre et on rappelle lev_list() */
 lev_list([Head | TailA], [Head | TailB], Dist, TabInit, TabOut) :-
    lev_list(TailA, TailB, Dist, TabInit, TabOut).
 
 /* Sinon, on prend le minimum des trois opérations possibles, donc :
 Dist = min (lev(a-1, b)
             lev(a, b-1)
             lev(a-1, b-1)
             )  */
 
 
 lev_list([H1 | T1], [H2 | T2], Min, TabInit, TabOut) :-
    length([H1 | T1], LengthA),
    length([H2 | T2], LengthB),
    
    ( member((LengthA, LengthB, _), TabInit) 
       -> find_value((LengthA, LengthB, _), TabInit, Result),  Min = Result, TabOut = TabInit
       ;
 
       lev_list(T1, [H2 | T2], Dist1, TabInit, TabOut1),  
       lev_list([H1 | T1], T2, Dist2, TabOut1, TabOut2), 
       lev_list(T1, T2, Dist3, TabOut2, TabOut3), 
 
       (H1 = H2 -> C is 0 ; C is 1),   
 
       NewDist1 is Dist1 + 1,   
       NewDist2 is Dist2 + 1,   
       NewDist3 is Dist3 + C,
 
       min3(NewDist1, NewDist2, NewDist3, Min),
       TabOut = [(LengthA,LengthB,Min)| TabOut3]
    ).
       /* Min= Min2,*/
       /*append([( LengthA, LengthB, Min)], TabInit, TabOut)).*/
       /*Dist is Min + 1.*/
 
 
 /*find_value((X,Y,_), [], 0).*/
 
 find_value((X,Y,_), [(X,Y,Z2)|ResteListe], Z2):- !.
 
 find_value((X,Y,_), [(X2,Y2,Z2)|ResteListe], Result):-
    find_value((X,Y,_), ResteListe, Result).
 
 
 /* Définition du minimum de trois valeurs */
 min3(A, B, C, Min) :- 
    min(A, B, Min1), 
    min(Min1, C, Min).
 
 min(A, B, A) :- A =< B, !.
 min(_, B, B).
  