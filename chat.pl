:- use_module(library(isub)).
:- use_module(library(readutil)).
:- use_module(lire_question,[lire_question/1]).
:- use_module(produire_reponse,[produire_reponse/2]).
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



/* --------------------------------------------------------------------- */
/*                                                                       */
/*        PRODUIRE_REPONSE(L_Mots,L_strings) :                           */
/*                                                                       */
/*        Input : une liste de mots L_Mots representant la question      */
/*                de l'utilisateur                                       */
/*        Output : une liste de strings donnant la                       */
/*                 reponse fournie par le bot                            */
/*                                                                       */
/*        NB Par défaut le predicat retourne dans tous les cas           */
/*            [  "Je ne sais pas.", "Les étudiants",                     */
/*               "vont m'aider, vous le verrez !" ]                      */
/*                                                                       */
/*        Je ne doute pas que ce sera le cas ! Et vous souhaite autant   */
/*        d'amusement a coder le predicat que j'ai eu a ecrire           */
/*        cet enonce et ce squelette de solution !                       */
/*                                                                       */
/* --------------------------------------------------------------------- */

produire_reponse([fin],L1) :-
   L1 = [merci, de, m, '\'', avoir, consulte], !.

produire_reponse(L,Rep) :-
   mclef(M,_), member(M,L),
   clause(regle_rep(M,_,Pattern,Rep),Body),
   match_pattern(Pattern,L), 
   call(Body), !.

produire_reponse(_, [Choix_aleatoire]) :-
   Choix_reponse =[
      " Je ne sais pas, je n ai actuellement pas encore la réponse.",
      " Je laisse mes créateurs supers intelligents répondre à votre question.",
      " Je n ai pas compris la question, est ce que vous pourriez la reformuler ? ",
      " Je n ai pas la réponse à cette question. ",
      " Cette question me laisse bouche bée",
      " Vous en avez des bonnes questions ...",
      " Je suis sans voix à cette question, vous en avez pas une autre ?",
      " Alors là, bonne question ... ",
      " Tu me poses une colle, joker !",
      " Tu vas me faire buguer avec ce genre de question. 😅"
      ],
   random_member(Choix_aleatoire, Choix_reponse).
   
   



/* Définition du minimum de trois valeurs */
min3(A, B, C, Min) :- 
   min(A, B, Min1), 
   min(Min1, C, Min).

min(A, B, A) :- A =< B, !.
min(_, B, B).


/* Fonction principale : conversion string -> liste */
lev(A, B, Dist) :-
   string_chars(A, ListCharA),  
   string_chars(B, ListCharB), 
   lev_list(ListCharA, ListCharB, Dist).


/* Version Levenshtein : */

/* 1. Formule Wikipedia : */

/* Cas de base 1 : si un des mots est de longueur 0 -> Dist = longueur de l'autre mot */
lev_list([], B, Dist) :- length(B, Dist).
lev_list(A, [], Dist) :- length(A, Dist).


/* Cas de base 2 : si les 2 mots commencent par la même lettre, on retire cette lettre et on rappelle lev_list() */
lev_list([Head | TailA], [Head | TailB], Dist) :-
   lev_list(TailA, TailB, Dist).

/* Sinon, on prend le minimum des trois opérations possibles, donc :
Dist = min (lev(a-1, b)
            lev(a, b-1)
            lev(a-1, b-1)
            )  
*/


lev_list([_ | T1], [_ | T2], Dist) :-
   lev_list(T1, [_ | T2], Dist1),  
   lev_list([_ | T1], T2, Dist2),  
   lev_list(T1, T2, Dist3),        
   min3(Dist1, Dist2, Dist3, Min),
   Dist is Min + 1.



/*############################################################################################*/
/*############################################################################################*/
/*############################################################################################*/
/*############################################################################################*/


   match_pattern(Pattern,Lmots) :-
      sublist(Pattern,Lmots).
  
  match_pattern(LPatterns,Lmots) :-
      match_pattern_dist([100|LPatterns],Lmots).
  
  match_pattern_dist([],_).
  match_pattern_dist([N,Pattern|Lpatterns],Lmots) :-
      within_dist(N,Pattern,Lmots,Lmots_rem),
      match_pattern_dist(Lpatterns,Lmots_rem).
  
  within_dist(_,Pattern,Lmots,Lmots_rem) :-
      prefixrem(Pattern,Lmots,Lmots_rem).
  within_dist(N,Pattern,[_|Lmots],Lmots_rem) :-
      N > 1, Naux is N-1,
      within_dist(Naux,Pattern,Lmots,Lmots_rem).
  
  sublist(SL,L) :-
      prefix(SL,L), !.
  sublist(SL,[_|T]) :- sublist(SL,T).
  
  sublistrem(SL,L,Lr) :-
      prefixrem(SL,L,Lr), !.
  sublistrem(SL,[_|T],Lr) :- sublistrem(SL,T,Lr).
  
  prefixrem([],L,L).
  prefixrem([H|T],[H|L],Lr) :- prefixrem(T,L,Lr).
  
  
  
  % ----------------------------------------------------------------%
  
  nb_lutins(4).
  nb_equipes(4).
  
  mclef(commence,10).
  mclef(equipe,5).
  mclef(quipe,5).
  
  % --------------------------------------------------------------- %
  
  regle_rep(commence,1,
   [ qui, commence, le, jeu ],
   [ "par convention, c est au joueur en charge des lutins verts de commencer la partie." ] ).
  
  % ----------------------------------------------------------------% 
  
  regle_rep(equipe,5,
    [ [ combien ], 3, [ lutins ], 5, [ equipe ] ],
    [ chaque, equipe, compte, X, lutins ]) :- 
  
         nb_lutins(X).
  
  regle_rep(quipe,5,
    [ [ combien ], 3, [ lutin ], 5, [ quipe ] ],
    [ "chaque equipe compte ", X_in_chars, "lutins" ]) :- 
  
         nb_lutins(X),
         write_to_chars(X,X_in_chars).
  
  write_to_chars(4,"4 ").
  


  /* --------------------------------------------------------------------- */
  /*                                                                       */
  /*        PRODUIRE_REPONSE : ecrit la liste de strings                   */
  /*                                                                       */
  /* --------------------------------------------------------------------- */
  
  transformer_reponse_en_string(Li,Lo) :- flatten_strings_in_sentences(Li,Lo).
  
  flatten_strings_in_sentences([],[]).
  flatten_strings_in_sentences([W|T],S) :-
      string_as_list(W,L1),
      flatten_strings_in_sentences(T,L2),
      append(L1,L2,S).
  
  % Pour SWI-Prolog
  string_as_list(W,L) :- string_to_list(W,L).
  
  
  % Pour tau-Prolog
  % string_as_list(W,W).
  
  
  /*    /!\ ci-après différent du code javascript
  */



/* --------------------------------------------------------------------- */
/*                                                                       */
/*                         BOUCLE PRINCIPALE                             */
/*                                                                       */
/* --------------------------------------------------------------------- */
fin(L) :- member(fin,L).


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


