:- module(chat, [reponse/2]).
:- use_module(library(isub)).
:- use_module(library(readutil)).
:- use_module(lire_question,[lire_question/1]).
:- use_module(ecrire_reponse,[ecrire_reponse/1]).
:- use_module(produire_reponse,[produire_reponse/2]).
:- use_module(levenshtein,[lev/3]).
%%:- use_module('../situation', [ajoutLutin/3, getScore/3, changevecteur/4, pontAProximite/4, ia/2, lutinLePlusEnDanger/6]).



rules('Les règles du jeu Pontu sont les suivantes : \n
   — le jeu sera joué par quatre joueurs (dont 2 IA), utilisant des lutins de couleur bleu, vert, rouge et jaune ;\n
   — les joueurs jouent tour à tour dans l’ordre suivant : d’abord les verts, puis les bleus, puis les jaunes puis les rouges ;\n
   — le plateau de jeu considéré est de taille 6 sur 6. Les cases seront numérotées selon les abscisses et ordonnées en prenant le coin inférieur gauche comme origine.\n
   Les ponts seront identifiés par les coordonnées des deux cases qu’ils joignent en donnant d’abord les coordonn´ees inférieures selon un ordre lexicographique.\n
   Exemple -> (2,3)–(2,4) et non (2,4)–(2,3).\n
   — chaque joueur dispose de quatre lutins ;\n
   — à tour de rˆole et dans l’ordre fix´e ci-dessus, chaque joueur place un lutin sur le plateau ;\n
   — quand tous les lutins sont plac´es, les joueurs d´eplacent tour `a tour un lutin selon l’ordre ci-dessus (en enlevant ou tournant un pont au passage);\n
   — le dernier joueur non ´elimin´e gagne la partie.\n
   ').

chat("Bonjour", "Bonjour, comment puis je vous aider ?").
chat("Pourquoi", "Parce que 🧏").
chat("Salut", "Salut, quoi de neuf ?").
chat("Wesh", "Wesh bien ou quoi ?").
chat("Ca va", "Bien et toi ?").
chat("Ok merci", "Avec plaisir de vous aider ! Si vous avez d autres questions n hesitez pas !").
%%chat("Hola", "No habla español").
chat("C est quoi les règles", Rules) :- rules(Rules).
chat("Explique moi les règles de pontu", Rules) :- rules(Rules).
chat("Règles de Pontu", Rules) :- rules(Rules).
chat("C est quoi Pontu ?", Rules) :- rules(Rules).
chat("C est quoi PontuXL ?", Rules) :- rules(Rules).
chat("Qu est-ce que Pontu ?", Rules) :- rules(Rules).
chat("C est quoi les règles du pontXL", Rules) :- rules(Rules).
chat("Les règles du pontXL", Rules) :- rules(Rules).

chat("Explique moi Pontu", Rules) :- rules(Rules).
chat("Comment jouer à Pontu ?", Rules) :- rules(Rules).
chat("Comment joue-t-on à Pontu ?", Rules) :- rules(Rules).
chat("Je veux jouer à pontu, explique les règles", Rules) :- rules(Rules).
chat("Je voudrais jouer à pontu, explique moi les règles du jeu", Rules) :- rules(Rules).
chat("Comment est-ce qu on joue à Pontu ?", Rules) :- rules(Rules).

chat("Qui commence le jeu ? ", "Par convention, c’est au joueur en charge des lutins verts de commencer la partie.").
chat("Combien de lutins compte chaque equipe ?", "4 lutins par équipes").
chat("Puis-je deplacer un lutin sur une case occupee par un autre lutin ?","Non, un seul lutin par case").
chat("Combien de lutins compte chaque equipe ?", "4 lutins par équipes").
chat("Quel pont puis-je retirer apres avoir deplace un lutin ?", "Il est permis de retirer le pont emprunte ou tout autre pont.").

chat("Comment on fait pour gagner ?", "Pour gagner il faut etre le dernier joueur à posséder des lutins déplacable sur le plateau").
chat("Comment on gagne", "Pour gagner il faut etre le dernier joueur à posséder des lutins déplacable sur le plateau").
chat("C est quoi l objectif ", Rules):- rules(Rules).
chat("C est quoi l objectif du jeu", Rules):- rules(Rules).
chat("C est quoi l objectif du PontuXL", Rules):- rules(Rules).
chat("C est quoi PontuXl ", Rules):- rules(Rules).
chat("C est quoi le temps d une partie", "il n y a pas vraiment de temps prédéfini, seul la survie importe").
chat("On peut avoir deux lutins sur la meme case", "Il est interdit d avoir 2 lutins sur la meme case").
chat("Pourquoi mon lutin est supprimé", "Ton lutin est supprimé car il n a plus aucun pont a pouvoir utilisé").
chat("Comment gagner", "Pour cela il faut anéantir tous les lutins adverses. Ils ne doivent plus avoir aucun pont à emprunter").
chat("La taille du plateau ", "Le plateau est de dimension 6x6").
chat("Que peut on faire avec les ponts", "Avec les ponts vous pouvez soit les supprimers soit les déplacer une fois apres avoir deplacer un de vos lutins").

/*
% partie intélligente du chatBot
chat("Je suis le joueur rouge quel coup je dois jouer", "").
chat("Je suis le joueur vert quel coup je dois jouer", "").
chat("Je suis le joueur jaune quel coup je dois jouer", "").
chat("Je suis le joueur bleu quel coup je dois jouer", "").

chat("Je joue pour les lutins verts. Quel lutin me conseillez-vous de deplacer et vers quelle case ?", "Je n ai pas encore la réponse car je suis pas encore assez intelligent").
chat("Je joue pour les lutins rouge. Quel lutin me conseillez-vous de deplacer et vers quelle case ?", "Je n ai pas encore la réponse car je suis pas encore assez intelligent").
chat("Je joue pour les lutins jaune. Quel lutin me conseillez-vous de deplacer et vers quelle case ?", "Je n ai pas encore la réponse car je suis pas encore assez intelligent").
chat("Je joue pour les lutins bleu. Quel lutin me conseillez-vous de deplacer et vers quelle case ?", "Je n ai pas encore la réponse car je suis pas encore assez intelligent").

chat("Je suis le joueur rouge quel coup je dois jouer", "").
chat("Je suis le joueur rouge quel coup je dois jouer", "").
chat("Je suis le joueur rouge quel coup je dois jouer", "").
chat("Je suis le joueur rouge quel coup je dois jouer", "").



reponseToStringLutin((ListeLutin, ListePont, OrdreJeu), JoueurActuel, ResultInString):-
   lutinLePlusEnDanger(Etat, )
   with_output_to(string(String),
        format("Le lutin a déplacé est le lutin (~w, ~w, ~w) car c est le lutin qui est le plus en danger", [Couleur, X, Y])
    ).


chat("", "").*/

get_Question_BD(ResultList) :-
   findall((Question, Reponse), chat(Question, Reponse), ResultList).


reponse(Question_User, Result):-
   get_Question_BD(Liste_Question_BD),
   answer_questions(Question_User, Liste_Question_BD,  Result).


answer_questions(Question_User,Liste_Question_BD, Result):- 
      findall(
         (Dist, Reponse), 
         (member((Question_BD,Reponse), Liste_Question_BD),lev(Question_User, Question_BD, Dist), Dist =< 10),
         ListeDist
      ),
      best(Question_User, ListeDist,  ResultR, ResultDist),
      ResultDist =< 10,
      Result = ResultR, !.

/*
answer_questions(Question_User,[(Q1, R1)|Reste], Result):- 
   lev(Question_User, Q1, Dist1),
   Dist1 < 11,
   \+ (
      member((Q2, _), Reste),
      lev(Question_User, Q2, Dist2),
      Dist2 < Dist1
   ),
   Result = R1, !.
   */
%%% cas ou le chatbot dit qu il ne sait pas
answer_questions(_,_, L_reponse):-
      produire_reponse(_,[L_reponse|Reste]). %%L_reponse , PAS MODIF , nom de jacquet (voir fct PontuXL pour comprendre)
      %%random_member(Result,L_reponse).


best(_, [(Dist, Question)], Question, Dist).

best(Question_User, [(Dist, Question)|ResteListe], ResultQ, ResultDist):-
   best(Question_User, ResteListe, NewResultQ, NewResultDist),
   (Dist < NewResultDist 
      -> ResultQ = Question, ResultDist = Dist
      ; 
      ResultQ = NewResultQ, 
      ResultDist = NewResultDist
   ).



/* --------------------------------------------------------------------- */
/*                                                                       */
/*                         BOUCLE PRINCIPALE                             */
/*                                                                       */
/* --------------------------------------------------------------------- */
listeDeFin(["fin", "Fin", "Stop", "stop", "bye", "Bye"]).

fin(Question_User) :-
   listeDeFin(X),
   member(Question_User,X).


pontuXL :- 
   nl, nl, nl,
   write('Bonjour, je suis PBot, le bot explicateur du jeu PontuXL.'), nl,
   write('En quoi puis-je vous etre utile ?'), 
   nl, nl, 

   repeat,
      write('\nVous : '), ttyflush,
      read_line_to_string(user_input, Question_User),

      (fin(Question_User) 
      -> write('ChatBot : Bye ! '), nl, ! ;
         reponse(Question_User, Result),
         write('ChatBot : '), write(Result)
      ),

   fin(Question_User).



/*
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
*/
:- pontuXL.

