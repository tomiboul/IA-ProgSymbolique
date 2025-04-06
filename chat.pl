:- use_module(library(isub)).
:- use_module(library(readutil)).
:- use_module(lire_question,[lire_question/1]).
:- use_module(ecrire_reponse,[ecrire_reponse/1]).
:- use_module(produire_reponse,[produire_reponse/2]).

rules('Les règles du jeu Pontu sont les suivantes.').


chat("Bonjour", "Bonjour, comment puis je vous aider ?").
chat("Salut", "Salut, quoi de neuf ?").
chat("Wesh", "Wesh bien ou quoi ?").
chat("Hola", "No habla español").
chat("Explique moi les règles de pontu", Rules) :- rules(Rules).
chat("Règles de Pontu", Rules) :- rules(Rules).
chat("C est quoi Pontu ?", Rules) :- rules(Rules).
chat("Qu est-ce que Pontu ?", Rules) :- rules(Rules).
chat("Explique moi Pontu", Rules) :- rules(Rules).
chat("Comment jouer à Pontu ?", Rules) :- rules(Rules).
chat("Comment joue-t-on à Pontu ?", Rules) :- rules(Rules).
chat("Je veux jouer à pontu, explique les règles", Rules) :- rules(Rules).
chat("Je voudrais jouer à pontu, explique moi les règles du jeu", Rules) :- rules(Rules).
chat("Comment est-ce qu on joue à Pontu ?", Rules) :- rules(Rules).



answer(Input, Answer) :-
   findall(Similarity-Response, (chat(Phrase, Response), isub(Phrase, Input, Similarity, [true, true, 2])), Similarities),
   sort(Similarities, SortedSimilarities),
   reverse(SortedSimilarities, [BestSimilarity-BestResponse|_]),
   (BestSimilarity > 0.3 ->  Answer = BestResponse; Answer = 'Je ne sais pas').


chatbot :-
   repeat,
   write('Vous: '),
   read_line_to_string(user_input, Input),
   (Input = ("Terminé" ; "Au revoir") ->  write('ChatJaiPété: Au revoir!'), nl, !; answer(Input, Answer), write('ChatJaiPété: '), write(Answer), nl,fail).
   
   





/* Fonction principale : conversion string -> liste */
lev(A, B, Dist, TabInit) :-
   string_chars(A, ListCharA),  
   string_chars(B, ListCharB), 
   lev_list(ListCharA, ListCharB, Dist, TabInit).


/* Version Levenshtein : */

/* 1. Formule Wikipedia : */

/* Cas de base 1 : si un des mots est de longueur 0 -> Dist = longueur de l'autre mot */
lev_list(A, [], I_Tab1, TabInit) :- length(A, I_Tab1).
lev_list([], B, J_Tab2, TabInit) :- length(B, J_Tab2).


/* Cas de base 2 : si les 2 mots commencent par la même lettre, on retire cette lettre et on rappelle lev_list() */
lev_list([Head | TailA], [Head | TailB], Dist, TabInit) :-
   lev_list(TailA, TailB, Dist, TabInit).

/* Sinon, on prend le minimum des trois opérations possibles, donc :
Dist = min (lev(a-1, b)
            lev(a, b-1)
            lev(a-1, b-1)
            )  
*/
lev_list([H1 | T1], [H2 | T2], Min, TabInit) :-
   lev_list(T1, [H2 | T2], Dist1, TabInit),  
   lev_list([H1 | T1], T2, Dist2, TabInit),  
   lev_list(T1, T2, Dist3, TabInit),  
   (H1 = H2 -> C is 0 ; C is 1),   
   min3(Dist1, Dist2, Dist3, Min),

   length([H1 | T1], LengthA),
   length([H2 | T2], LengthB),

   (member((LengthA, LengthB, _), TabInit) -> find_value((LengthA, LengthB, _), TabInit, Result),  Min = Result ; 
      NewDist1 is Dist1 + 1,   
      NewDist2 is Dist2 + 1,   
      NewDist3 is Dist3 + C,
      min3(NewDist1, NewDist2, NewDist3, Min2),
      Min= Min2,
      append([( LengthA, LengthB, Min2)], TabInit, TabInit)
         ).
   /*Dist is Min + 1.*/



find_value((X,Y,_), [], 0).

find_value((X,Y,_), [(X,Y,Z2)|ResteListe], Z2).

find_value((X,Y,_), [(X2,Y2,Z2)|ResteListe], Result):-
   find_value((X,Y,_), ResteListe, Result).




/* Définition du minimum de trois valeurs */
min3(A, B, C, Min) :- 
   min(A, B, Min1), 
   min(Min1, C, Min).

min(A, B, A) :- A =< B, !.
min(_, B, B).




/* --------------------------------------------------------------------- */
/*                                                                       */
/*                         BOUCLE PRINCIPALE                             */
/*                                                                       */
/* --------------------------------------------------------------------- */
/*fin(L) :- member(fin,L).*/


/*pontuXL :- 
   nl, nl, nl,
   write('Bonjour, je suis PBot, le bot explicateur du jeu PontuXL.'), nl,
   write('En quoi puis-je vous etre utile ?'), 
   nl, nl, 
 
   repeat,
      write('Vous : '), ttyflush,
      lire_question(L_Mots),
      produire_reponse(L_Mots,L_reponse),
      ecrire_reponse(L_reponse), nl,
   fin(L_Mots), !.

:- pontuXL.*/


