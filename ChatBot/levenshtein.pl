:- module(levenshtein,[lev/3]).


lev(A, B, Dist) :-
   string_chars(A, ListA),  
   string_chars(B, ListB), 

   %% n initialsie le dictionnaire qui va stocker les valeurs des coordonnées dans la matrice
   Matrice_Levenshtein = _{}, 
   lev_list(ListA, ListB, Dist, Matrice_Levenshtein, _), !.

/* Version Levenshtein : */
/* 1. Formule Wikipedia : */



/* Cas de base 1 : si un des mots est de longueur 0 -> Dist = longueur de l'autre mot */
lev_list([], B, Dist, Matrice_Levenshtein, New_Matrice_Levenshtein) :- 
   length(B, Dist),
   term_to_atom((0, Dist), Tuple_String), 
   New_Matrice_Levenshtein = Matrice_Levenshtein.put(Tuple_String, Dist).

lev_list(A, [], Dist, Matrice_Levenshtein, New_Matrice_Levenshtein) :- 
   length(A, Dist),
   term_to_atom((Dist,0), Tuple_String), 
   New_Matrice_Levenshtein = Matrice_Levenshtein.put(Tuple_String, Dist).



/* Cas de base 2 : si les 2 mots commencent par la même lettre, on retire cette lettre et on rappelle lev() */
lev_list([Head | TailA], [Head | TailB], Dist, Matrice_Levenshtein, New_Matrice_Levenshtein) :-
   length([Head | TailA], LengthA),
   length([Head | TailB], LengthB), 
   term_to_atom((LengthA, LengthB), Tuple_String), 

   New_Matrice_Levenshtein = Matrice_Levenshtein.put(Tuple_String, Dist),
   /*write("\n Matrice cas 2 : " + New_Matrice_Levenshtein),*/
   lev_list(TailA, TailB, Dist, New_Matrice_Levenshtein, _).



lev_list([H1 | T1], [H2 | T2], Dist, Matrice_Levenshtein, Matrice_Levenshtein) :-
   length([H1 | T1], LengthA),
   length([H2 | T2], LengthB), 
   term_to_atom((LengthA, LengthB), Tuple_String), 
   get_dict(Tuple_String, Matrice_Levenshtein, Value),
   Dist = Value, !.


lev_list([H1 | T1], [H2 | T2], Dist, Matrice_Levenshtein, New_Matrice_Levenshtein) :-
   length([H1 | T1], LengthA),
   length([H2 | T2], LengthB), 

   term_to_atom((LengthA, LengthB), Tuple_String), 

   lev_list(T1, [H2 | T2], Dist1, Matrice_Levenshtein,Out1),%effacement
   lev_list([H1| T1], T2, Dist2, Out1,Out2),%insertion
   lev_list(T1, T2, Dist3, Out2,Out3),   
       
   min3(Dist1, Dist2, Dist3, Min),
   Dist is Min + 1,

   New_Matrice_Levenshtein = Out3.put(Tuple_String, Dist).



/*Définition du minimum de trois valeurs */
min3(A, B, C, Min) :- 
   min(A, B, Min1), 
   min(Min1, C, Min).

min(A, B, A) :- A =< B, !.
min(_, B, B).