:- use_module(library(isub)).
:- use_module(library(readutil)).

rules("Les règles du jeu Pontu sont les suivantes : ...").


chat("Bonjour", "Bonjour, comment puis-je vous aider ?").
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
    findall(Similarity-Response, (
        chat(Phrase, Response),
        isub(Phrase, Input, Similarity, [true, true, 2])
    ), Similarities),
    sort(Similarities, SortedSimilarities),
    reverse(SortedSimilarities, [BestSimilarity-BestResponse|_]),
    (   BestSimilarity > 0.3
    ->  Answer = BestResponse
    ;   Answer = "Je ne sais pas"
    ).

chatbot :-
    repeat,
    write('Vous: '),
    read_line_to_string(user_input, Input),
    (   Input = "Terminé"
    ->  write('ChatJaiPété: Au revoir!'), nl, !
    ;   answer(Input, Answer),
        write('ChatJaiPété: '), write(Answer), nl,
        fail
    ).