:- use_module(library(assoc)).

levenshtein(Str1, Str2, Distance) :-
    string_chars(Str1, L1),
    string_chars(Str2, L2),
    length(L1, N),
    length(L2, M),
    empty_assoc(Empty),
    init_matrix(N, M, L1, L2, Empty, Assoc),
    get_assoc((N, M), Assoc, Distance).

% Initialisation + remplissage de la matrice
init_matrix(N, M, L1, L2, AssocIn, AssocOut) :-
    % Initialiser première colonne
    init_rows(0, N, AssocIn, A1),
    % Initialiser première ligne
    init_cols(0, M, A1, A2),
    % Remplir le reste de la matrice
    fill_matrix(1, N, 1, M, L1, L2, A2, AssocOut).

% Initialisation de D[i,0] = i
init_rows(I, N, Assoc, Assoc) :- I > N, !.
init_rows(I, N, AssocIn, AssocOut) :-
    put_assoc((I,0), AssocIn, I, A2),
    I1 is I + 1,
    init_rows(I1, N, A2, AssocOut).

% Initialisation de D[0,j] = j
init_cols(J, M, Assoc, Assoc) :- J > M, !.
init_cols(J, M, AssocIn, AssocOut) :-
    put_assoc((0,J), AssocIn, J, A2),
    J1 is J + 1,
    init_cols(J1, M, A2, AssocOut).

% Remplissage de la matrice D[i,j]
fill_matrix(I, N, _, _, _, _, Assoc, Assoc) :- I > N, !.
fill_matrix(I, N, J0, M, L1, L2, AssocIn, AssocOut) :-
    fill_row(I, J0, M, L1, L2, AssocIn, A2),
    I1 is I + 1,
    fill_matrix(I1, N, J0, M, L1, L2, A2, AssocOut).

% Remplissage d’une ligne
fill_row(_, J, M, _, _, Assoc, Assoc) :- J > M, !.
fill_row(I, J, M, L1, L2, AssocIn, AssocOut) :-
    I1 is I - 1,
    J1 is J - 1,
    nth1(I, L1, C1),
    nth1(J, L2, C2),
    ( C1 == C2 -> Cost = 0 ; Cost = 1 ),
    get_assoc((I1, J), AssocIn, Del),
    get_assoc((I, J1), AssocIn, Ins),
    get_assoc((I1, J1), AssocIn, Sub),
    MinCost is min(min(Del + 1, Ins + 1), Sub + Cost),
    put_assoc((I,J), AssocIn, MinCost, A2),
    J2 is J + 1,
    fill_row(I, J2, M, L1, L2, A2, AssocOut).

