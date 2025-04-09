:- use_module(library(isub)).
:- use_module(library(readutil)).
:- use_module(lire_question,[lire_question/1]).
:- use_module(ecrire_reponse,[ecrire_reponse/1]).
:- use_module(produire_reponse,[produire_reponse/2]).
:- use_module(levenshtein,[lev/3]).

rules('Les règles du jeu Pontu sont les suivantes.').

chat("Bonjour", "Bonjour, comment puis je vous aider ?").
chat("Salut", "Salut, quoi de neuf ?").
/*
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
*/

/*
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
   
*/
get_Question_BD(ResultList) :-
   findall((Question, Reponse), chat(Question, Reponse), ResultList).

/*
answer_questions(Question_User, Result):- 
      get_Question_BD(Liste_Question_BD),
      findall((Dist, Question_BD), (Dist =< 20, member((Question_BD,_), Liste_Question_BD),lev(Question_User, Question_BD, Dist), write(" \n \n pppppepzeppzeppzeppz" + Dist )), ListeDist), 
      write( " result liste dist : " +  ListeDist),
      best(Question_User, ListeDist,  ResultQ, ResultDist),
      ResultDist =< 10,
      Result = ResultQ.*/
   
reponse(Question_User, Result):-
   get_Question_BD(Liste_Question_BD),
   answer_questions(Question_User, Liste_Question_BD,  Result).

answer_questions(Question_User,[(Q1, R1)|Reste], Result):- 
   lev(Question_User, Q1, Dist1),
   Dist1 < 11,
   \+ (
      member((Q2, _), Reste),
      lev(Question_User, Q2, Dist2),
      Dist2 < Dist1
   ),
   Result = R1.
   
answer_questions(_,Liste_Question_BD, L_reponse):-
      produire_reponse(_,L_reponse). %%L_reponse , PAS MODIF , nom de jacquet (voir fct PontuXL pour comprendre)
      %%random_member(Result,L_reponse).


best(_, [(Dist, Question)], Question, Dist).

best(Question_User, [(Dist, Question)|ResteListe], ResultQ, ResultDist):-
   best(Question_User, ResteListe, NewResultQ, NewResultDist),
   (Dist < NewResultDist -> ResultQ = Question, ResultDist = Dist; ResultQ = NewResultQ, ResultDist = NewResultDist).

/*
best_similarity(Question, [], Result, _).

best_similarity(Question, [(D1, Q1)|Qs], Result, Mindist):- 
      D1<=Mindist,
      best_similarity(Question , Qs, ResultNext, D1),
      Result=(D1,Q1).
      
best_similarity(Question, [(D1, Q1)|Qs], Result, Mindist):- 
      best_similarity(Question, Qs, ResultNext, Mindist).
      Result = ResultNext.*/

      





/* --------------------------------------------------------------------- */
/*                                                                       */
/*                         BOUCLE PRINCIPALE                             */
/*                                                                       */
/* --------------------------------------------------------------------- */
/*fin(L) :- member(fin,L).


pontuXL :- 
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


:- pontuXL.
*/
