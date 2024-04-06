/*
Fact types:
file(x): If the case includes a file.
enoughmaterialpresent(x): If the required materials to take legal action are all present
type(x): The type of case (complaint, warning, improvement procedure.)
earlierbehavior(x): If the employee has shown earlier problematic behaviour.
violence(x): If complaint is about violence on the workplace.
severe(x): If a warning is severe.
earlierwarnings(x): Amount of earlier warnings the employee has had.
*/

:- dynamic asked/1.
:- dynamic file/1.
:- dynamic enoughmaterialpresent/1.
:- dynamic type/1.
:- dynamic earlierbehavior/1.
:- dynamic violence/1.
:- dynamic severe/1.
:- dynamic earlierwarnings/1.

%%%%%%%%%%%%%%%%%% Mapping (letterlijk uit het koffie voorbeeld)
% Var 1: file
map(file, "1", yes).
map(file, "0", no).

% Var 2: enoughmaterialpresent
map(enoughmaterialpresent, "1", yes).
map(enoughmaterialpresent, "0", no).

% Var 3: type
map(type, "1", complaint).
map(type, "2", warning).
map(type, "3", improvementprocedure).
map(type, "0", somethingelse).

% Var 4: earlierbehavior
map(earlierbehavior, "1", yes).
map(earlierbehavior, "0", no).

% Var 5: violence
map(violence, "1", yes).
map(violence, "0", no).

% Var 6: severe
map(severe, "1", yes).
map(severe, "0", no).

%%%%%%%%%%%%% Knowledge Rules

% Rule 1
case("You are advised to ask for more info") :- 
    file(no).

% Rule 2
case("You are advised to ask for more info") :-
    enoughmaterialpresent(no).

% Rule 3
case("You are advised to go to court") :-
    type(complaint),
    earlierbehavior(yes).

% Rule 4
case("You are advised to go to court") :-
    type(complaint),
    violence(yes).

% Rule 5
case("You are advised to begin a mediation procedure") :-
    type(complaint),
    violence(no),
    earlierbehavior(no).

% Rule 6
case("You are advised to fire the employee") :-
    type(warning),
    severe(yes).

% Rule 7
case("You are advised to give the employee salary suspension") :-
    type(warning),
    earlierwarnings(X),
    X >= 3.

% Rule 8
case("You are advised to send the employee a warning letter") :-
    type(warning),
    severe(no),
    earlierwarnings(X),
    X < 3.

% Rule 9
case("You are advised to begin a mediation procedure") :-
    type(improvementprocedure).

% Rule 10
case("This task is not suitable.") :-
    type(somethingelse).


%%%%%%%%%%%%%% UI.
%% Note for Windows users: the predicate tty_clear (clear the screen) is not supported on Windows.
%% Replace all occurrences of this predicate with write("\e[2J")

menu :-
    % Predicate for generating the welcome menu.

    repeat,
    nl,
    writeln("Welcome to the knowledge system. Enter what you want me to do."),
    writeln("1. Suggest advice for a new case."),

    % Option 2: Clear preferences?

    writeln("0. Exit"),
    read_line_to_string(user_input, Choice),
    choice(Choice),
    Choice == "0".

choice("1") :-
    % ask questions.
    repeat,
    question,

    % give recommendation.
    case(Advice),
    write("\e[2J"),
    writeln("The system advices you with the following message:"),
    nl,
    format("~w", Advice),
    clearvariables,
    !.


choice("0") :-
    % User wants to exit the system.
    writeln("Thank you for using the system. Bye!").


% Questions in order (order can be altered.)

question :-
    % Question 1 about file.

    \+asked(file),
    writeln("Does the case include a file?"),
    writeln("1. Yes."),
    writeln("0. No."),
    read_line_to_string(user_input, Input),
    map(file, Input, F),
    assertz(file(F)),
    assertz(asked(file)).

question :-
    % Question 2 about enoughmaterialpresent.

    \+asked(enoughmaterialpresent),
    writeln("Is there enough material present to take legal action?"),
    writeln("1. Yes."),
    writeln("0. No."),
    read_line_to_string(user_input, Input),
    map(enoughmaterialpresent, Input, E),
    assertz(enoughmaterialpresent(E)),
    assertz(asked(enoughmaterialpresent)).


question :- 
    % Question 3 about type.

    \+asked(type),
    writeln("What is the type of case?"),
    writeln("1. Complaint."),
    writeln("2. Warning."),
    writeln("3. Improvement procedure."),
    writeln("0. Something else than above."),
    read_line_to_string(user_input, Input),
    map(type, Input, T),
    assertz(type(T)),
    assertz(asked(type)).


question :-
    % Question 4 about earlierbehavior.

    \+asked(earlierbehavior),
    writeln("Has the employee has problematic behavior earlier in his/her career at Municipality Amsterdam?"),
    writeln("1. Yes."),
    writeln("0. No."),
    read_line_to_string(user_input, Input),
    map(earlierbehavior, Input, E),
    assertz(earlierbehavior(E)),
    assertz(asked(earlierbehavior)).

question :-
    % Question 5 about violence.

    \+asked(violence),
    writeln("Is the complaint about violence on the workplace?"),
    writeln("1. Yes."),
    writeln("0. No."),
    read_line_to_string(user_input, Input),
    map(violence, Input, V),
    assertz(violence(V)),
    assertz(asked(violence)).

question :-
    % Question 6 about severe.

    \+asked(severe),
    writeln("Is the warning severe?"),
    writeln("1. Yes."),
    writeln("0. No."),
    read_line_to_string(user_input, Input),
    map(severe, Input, S),
    assertz(severe(S)),
    assertz(asked(severe)).

question :-
    % Question 7 about earlierwarnings.

    \+asked(earlierwarnings),
    writeln("How many warnings has the employee had already?"),
    writeln("Please enter a number."),
    read_line_to_string(user_input, Input),
    atom_number(Input, Number),
    assertz(earlierwarnings(Number)),
    assertz(asked(earlierwarnings)).

clearvariables :-
    % Clear all variables to prepare for a new system run.

    retractall(asked(_)),
    retractall(file(_)),
    retractall(enoughmaterialpresent(_)),
    retractall(type(_)),
    retractall(earlierbehavior(_)),
    retractall(violence(_)),
    retractall(severe(_)),
    retractall(earlierwarnings(_)).


:- menu.