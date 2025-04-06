:- use_module(library(isub)).
:- use_module(library(readutil)).

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
   
   
/* --------------------------------------------------------------------- */
/*                                                                       */
/*             Transform questions into a list of words                  */
/*                                                                       */
/* --------------------------------------------------------------------- */
% read_atomics(-ListOfAtomics)
%  Reads a line of input, removes all punctuation characters, and converts
%  it into a list of atomic terms, e.g., [this,is,an,example].

read_atomics(ListOfAtomics) :-
   read_lc_string(String),
   clean_string(String,Cleanstring),
   extract_atomics(Cleanstring,ListOfAtomics).


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

produire_reponse(_,[S1,S2,S3,S4]) :-
   S1 = "Je ne sais pas, je n ai actuellement pas encore la réponse.",
   S2 = "Les étudiants vont m aider, vous le verrez.",
   S3 = "Je n ai pas compris la question, est ce que vous pourriez la reformuler ? ".



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
  /*          CONVERSION D'UNE QUESTION DE L'UTILISATEUR EN                */
  /*                        LISTE DE MOTS                                  */
  /*                                                                       */
  /* --------------------------------------------------------------------- */
  
  % lire_question(L_Mots)
  
  % Pour tau-Prolog avec Javascript
  lire_question(LMots) :- read_atomics(LMots).
  
  % Pour bot en ligne
  
  
  /*****************************************************************************/
  % my_char_type(+Char,?Type)
  %    Char is an ASCII code.
  %    Type is whitespace, punctuation, numeric, alphabetic, or special.
  
  my_char_type(46,period) :- !.
  my_char_type(X,alphanumeric) :- X >= 65, X =< 90, !.
  my_char_type(X,alphanumeric) :- X >= 97, X =< 123, !.
  my_char_type(X,alphanumeric) :- X >= 48, X =< 57, !.
  my_char_type(X,whitespace) :- X =< 32, !.
  my_char_type(X,punctuation) :- X >= 33, X =< 47, !.
  my_char_type(X,punctuation) :- X >= 58, X =< 64, !.
  my_char_type(X,punctuation) :- X >= 91, X =< 96, !.
  my_char_type(X,punctuation) :- X >= 123, X =< 126, !.
  my_char_type(_,special).
  
  
  /*****************************************************************************/
  % lower_case(+C,?L)
  %   If ASCII code C is an upper-case letter, then L is the
  %   corresponding lower-case letter. Otherwise L=C.
  
  lower_case(X,Y) :-
      X >= 65,
      X =< 90,
      Y is X + 32, !.
  
  lower_case(X,X).
  
  
  /*****************************************************************************/
  % read_lc_string(-String)
  %  Reads a line of input into String as a list of ASCII codes,
  %  with all capital letters changed to lower case.
  
  read_lc_string(String) :-
      get0(FirstChar),
      lower_case(FirstChar,LChar),
      read_lc_string_aux(LChar,String).
  
      read_lc_string_aux(10,[]) :- !.  % end of line
  
  read_lc_string_aux(-1,[]) :- !.  % end of file
  
  read_lc_string_aux(LChar,[LChar|Rest]) :- read_lc_string(Rest).
  
  
  /*****************************************************************************/
  % extract_word(+String,-Rest,-Word) (final version)
  %  Extracts the first Word from String; Rest is rest of String.
  %  A word is a series of contiguous letters, or a series
  %  of contiguous digits, or a single special character.
  %  Assumes String does not begin with whitespace.
  
  extract_word([C|Chars],Rest,[C|RestOfWord]) :-
      my_char_type(C,Type),
      extract_word_aux(Type,Chars,Rest,RestOfWord).
  
      extract_word_aux(special,Rest,Rest,[]) :- !.
  % if Char is special, don't read more chars.
  
  extract_word_aux(Type,[C|Chars],Rest,[C|RestOfWord]) :-
      my_char_type(C,Type), !,
  extract_word_aux(Type,Chars,Rest,RestOfWord).
  
  extract_word_aux(_,Rest,Rest,[]).   % if previous clause did not succeed.
  
  
  /*****************************************************************************/
  % remove_initial_blanks(+X,?Y)
  %   Removes whitespace characters from the
  %   beginning of string X, giving string Y.
  
  remove_initial_blanks([C|Chars],Result) :-
      my_char_type(C,whitespace), !,
  remove_initial_blanks(Chars,Result).
  
  remove_initial_blanks(X,X).   % if previous clause did not succeed.
  
  
  /*****************************************************************************/
  % digit_value(?D,?V)
  %  Where D is the ASCII code of a digit,
  %  V is the corresponding number.
  
  digit_value(48,0).
  digit_value(49,1).
  digit_value(50,2).
  digit_value(51,3).
  digit_value(52,4).
  digit_value(53,5).
  digit_value(54,6).
  digit_value(55,7).
  digit_value(56,8).
  digit_value(57,9).
  
  
  /*****************************************************************************/
  % string_to_number(+S,-N)
  %  Converts string S to the number that it
  %  represents, e.g., "234" to 234.
  %  Fails if S does not represent a nonnegative integer.
  
  string_to_number(S,N) :-
      string_to_number_aux(S,0,N).
  
      string_to_number_aux([D|Digits],ValueSoFar,Result) :-
      digit_value(D,V),
      NewValueSoFar is 10*ValueSoFar + V,
  string_to_number_aux(Digits,NewValueSoFar,Result).
  
  string_to_number_aux([],Result,Result).
  
  
  /*****************************************************************************/
  % string_to_atomic(+String,-Atomic)
  %  Converts String into the atom or number of
  %  which it is the written representation.
  
  string_to_atomic([C|Chars],Number) :-
      string_to_number([C|Chars],Number), !.
  
  string_to_atomic(String,Atom) :- atom_codes(Atom,String).
  % assuming previous clause failed.
  
  
  /*****************************************************************************/
  % extract_atomics(+String,-ListOfAtomics) (second version)
  %  Breaks String up into ListOfAtomics
  %  e.g., " abc def  123 " into [abc,def,123].
  
  extract_atomics(String,ListOfAtomics) :-
      remove_initial_blanks(String,NewString),
      extract_atomics_aux(NewString,ListOfAtomics).
  
      extract_atomics_aux([C|Chars],[A|Atomics]) :-
      extract_word([C|Chars],Rest,Word),
      string_to_atomic(Word,A),       % <- this is the only change
  extract_atomics(Rest,Atomics).
  
  extract_atomics_aux([],[]).
  
  
  /*****************************************************************************/
  % clean_string(+String,-Cleanstring)
  %  removes all punctuation characters from String and return Cleanstring
  
  clean_string([C|Chars],L) :-
      my_char_type(C,punctuation),
      clean_string(Chars,L), !.
  clean_string([C|Chars],[C|L]) :-
      clean_string(Chars,L), !.
  clean_string([C|[]],[]) :-
      my_char_type(C,punctuation), !.
  clean_string([C|[]],[C]).
  
  
  /*****************************************************************************/
  % read_atomics(-ListOfAtomics)
  %  Reads a line of input, removes all punctuation characters, and converts
  %  it into a list of atomic terms, e.g., [this,is,an,example].
  
  read_atomics(ListOfAtomics) :-
      read_lc_string(String),
      clean_string(String,Cleanstring),
      extract_atomics(Cleanstring,ListOfAtomics).
  
  
  
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


