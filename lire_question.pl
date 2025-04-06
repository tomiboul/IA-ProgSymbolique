:- module(lire_question,[lire_question/1]).


  /* --------------------------------------------------------------------- */
  /*                                                                       */
  /*          CONVERSION D'UNE QUESTION DE L'UTILISATEUR EN                */
  /*                        LISTE DE MOTS                                  */
  /*                                                                       */
  /* --------------------------------------------------------------------- */
  
% lire_question(L_Mots)
% Pour tau-Prolog avec Javascript
lire_question(LMots) :- read_atomics(LMots).
  
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
  % lower_case(+C,?L)
  %   If ASCII code C is an upper-case letter, then L is the
  %   corresponding lower-case letter. Otherwise L=C.
  
lower_case(X,Y) :-
    X >= 65,
    X =< 90,
    Y is X + 32, !.

lower_case(X,X).


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
  % remove_initial_blanks(+X,?Y)
  %   Removes whitespace characters from the
  %   beginning of string X, giving string Y.
  
remove_initial_blanks([C|Chars],Result) :-
    my_char_type(C,whitespace), !,
    remove_initial_blanks(Chars,Result).

remove_initial_blanks(X,X).   % if previous clause did not succeed.


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
  % string_to_atomic(+String,-Atomic)
  %  Converts String into the atom or number of
  %  which it is the written representation.
  
string_to_atomic([C|Chars],Number) :-
    string_to_number([C|Chars],Number), !.

string_to_atomic(String,Atom) :- atom_codes(Atom,String).
% assuming previous clause failed.


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
  