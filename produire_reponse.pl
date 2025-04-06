:- module(produire_reponse,[produire_reponse/2]).
:- use_module(library(isub)).
:- use_module(library(readutil)).
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
    


/*##########################################################################################################################*/
/*##########################################################################################################################*/
/*######################## je sais pas a quoi sert exactement cette partie du code a jacquet ################################*/
/*##########################################################################################################################*/
/*##########################################################################################################################*/


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
 
 
 
 