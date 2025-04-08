
 
 /* Fonction principale : conversion string -> liste */
 levenshtein(A, B, Dist) :-
    string_chars(A, ListCharA),  
    string_chars(B, ListCharB), 
    lev_list(ListCharA, ListCharB, 0, Dist, [], []).
 
 
 /* Version Levenshtein : */
 /* 1. Formule Wikipedia : */
 
 /* Cas de base 1 : si un des mots est de longueur 0 -> Dist = longueur de l'autre mot */
 lev_list(A, [], Dist_I, Dist_I, TabInit, TabOut) :- length(A, Dist_I).
 lev_list([], B, Dist_J, Dist_J, TabInit, TabOut) :- length(B, Dist_J).
 
 
 /* Cas de base 2 : si les 2 mots commencent par la même lettre, on retire cette lettre et on rappelle lev_list() */
 lev_list([Head | TailA], [Head | TailB], Dist, Dist, TabInit, TabOut) :-
   /*length([Head | TailA], LengthA),
   length([Head | TailB], LengthB),

   TabOut = [(LengthA,LengthB,Dist)| TabIn],*/
   
   !,
   lev_list(TailA, TailB, Dist, Dist,TabOut, TabOut).
 
 /* Sinon, on prend le minimum des trois opérations possibles, donc :
 Dist = min (lev(a-1, b)
             lev(a, b-1)
             lev(a-1, b-1)
             )  */
 
 
 
 lev_list([H1 | T1], [H2 | T2], MinIn, MinOut, TabIn, TabOut) :-
    length([H1 | T1], LengthA),
    length([H2 | T2], LengthB),
    
    ( member((LengthA, LengthB, _), TabIn)  -> find_value((LengthA, LengthB, _), TabIn, Result), MinOut = Result, TabOut = TabIn
      ;
       lev_list(T1, [H2 | T2], Dist1, MinOut, TabIn, TabOut1),  
       lev_list([H1 | T1], T2, Dist2, MinOut, TabOut1, TabOut2), 
       lev_list(T1, T2, Dist3, MinOut , TabOut2, TabOut3), 
 
       (H1 = H2 -> C is 0 ; C is 1),   
 
       NewDist1 is Dist1 + 1,   
       NewDist2 is Dist2 + 1,   
       NewDist3 is Dist3 + C,
 
       min3(NewDist1, NewDist2, NewDist3, Min),
       %%MinOut = Min,
       TabOut = [(LengthA,LengthB,Min)| TabIn]
    ).
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
  