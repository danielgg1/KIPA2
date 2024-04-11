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

% Declare dynamic predicates for user input / keeping tracked of asked questions and current questions.
:- dynamic asked/1.
:- dynamic file/1.
:- dynamic enoughmaterialpresent/1.
:- dynamic type/1.
:- dynamic earlierbehavior/1.
:- dynamic violence/1.
:- dynamic severe/1.
:- dynamic earlierwarnings/1.
:- dynamic currentquestion/1.

% The first question to ask is question number 1.
currentquestion(1).

%%%%%%%%%%%%%%%%%% Mapping functions, map choice to value.
% If the answer is invalid, the user is notified about invalid input.
% 'fail' predicate causes backtracking so question is asked again

% Var 1: type
map(type, "1", complaint).
map(type, "2", warning).
map(type, "3", improvementprocedure).
map(type, "4", agreementofdismissal).
map(type, "0", somethingelse).
map(type, _, invalid) :- 
    writeln("Invalid input. Please only type in one of the specific numbers (e.g. '1')."),
    fail.

% Var 2: earlierbehavior
map(earlierbehavior, "1", yes).
map(earlierbehavior, "0", no).
map(earlierbehavior, _, invalid) :- 
    writeln("Invalid input. Please only type in one of the specific numbers (e.g. '1')."),
    fail.

% Var 3: violence
map(violence, "1", yes).
map(violence, "0", no).
map(violence, _, invalid) :- 
    writeln("Invalid input. Please only type in one of the specific numbers (e.g. '1')."),
    fail.

% Var 4: severe
map(severe, "1", yes).
map(severe, "0", no).
map(severe, _, invalid) :- 
    writeln("Invalid input. Please only type in one of the specific numbers (e.g. '1')."),
    fail.

% Var 5: occupationaldisability
map(occupationaldisability, "1", yes).
map(occupationaldisability, "0", no).
map(occupationaldisability, _, invalid) :- 
    writeln("Invalid input. Please only type in one of the specific numbers (e.g. '1')."),
    fail.

% Var 5: evidencefiring
map(evidencefiring, "1", yes).
map(evidencefiring, "0", no).
map(evidencefiring, _, invalid) :- 
    writeln("Invalid input. Please only type in one of the specific numbers (e.g. '1')."),
    fail.

% Var 6: monthsabsent
map(monthsabsent, Number, yes) :-
    Number > 2.
map(monthsabsent, Number, no) :-
    Number < 3.

%%%%%%%%%%%%% Knowledge Rules


case("You are advised to fire the employee without compensation of transition.") :-
    type(agreementofdismissal),
    monthsabsent > 2.

case("You are advised to give the employee maximum compensation of transition.") :-
    type(agreementofdismissal),
    monthsabsent(no),
    occupationaldisability(yes).

case("You are advised to give the employee maximum compensation of transition") :-
    type(agreementofdismissal),
    monthsabsent(yes),
    evidencefiring(no).

case("You are advised to give the employee no compensation of transition") :-
    type(agreementofdismissal),
    evidencefiring(yes).


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
case("This task is not suitable for you as a juridical advisor. You are advised to redirect it to one of your colleagues.") :-
    type(somethingelse).


%%%%%%%%%%%%%% UI.
% Windows users: the predicate tty_clear (clear the screen) is not supported on Windows.
% Replace all occurrences of this predicate with write("\e[2J")

menu :-
    % Generate the welcome menu.

    repeat,
    nl,
    writeln("Welcome to the knowledge system. Enter what you want me to do."),
    writeln("1. Suggest advice for a new case."),
    writeln("0. Exit"),
    writeln("Please write your answer as just a single number, e.g. '1' or '0'. After entering the number, please hit enter."),
    read_line_to_string(user_input, Choice),
    nl,
    choice(Choice),
    Choice == "0".

choice("1") :-
    % Ask questions and try to determine an answer.

    repeat,
    currentquestion(QNumber),
    question(QNumber, Answer),
    nextquestion(QNumber, Answer, NewQNumber),
    retract(currentquestion(QNumber)),
    asserta(currentquestion(NewQNumber)),
    

    % Give recommendation if possible.
    case(Advice),
    write("\e[2J"),
    writeln("The system advices you with the following message:"),
    nl,
    format("~w", Advice),
    nl,
    clearvariables,

    % commitment operator: go back to menu when conclusion is reached.
    !.


choice("0") :-
    % User wants to exit the system.

    writeln("Thank you for using the system. Bye!").

choice(_) :-
    % The user has entered invalid input in the menu.
    write("\e[2J"),
    writeln("Please enter only one of the given choices: 1 or 0.").


%%%%%%%%%%%%%%%%%%% Question- and question order predicates
% predicate 'nextquestion' is used to determine the next question based on the answer given.



nextquestion(1, complaint, 2).
nextquestion(1, warning, 4).
nextquestion(1, agreementofdismissal, 6).
nextquestion(1, improvementprocedure, finished).
nextquestion(1, somethingelse, finished).

nextquestion(2, yes, finished).
nextquestion(2, no, 3).

nextquestion(3, yes, finished).
nextquestion(3, no, finished).

nextquestion(4, yes, finished).
nextquestion(4, no, 5).

nextquestion(5, _, finished).

nextquestion(6, yes, finished).
nextquestion(6, no, 7).

nextquestion(7, yes, finished).
nextquestion(7, no, 8).

nextquestion(8, _, finished).

% Questions

question(1, Answer) :- 
    % Question 3 about type.
    repeat,

    \+asked(type),
    writeln("What is the type of case?"),
    writeln("1. Complaint."),
    writeln("2. Warning."),
    writeln("3. Improvement procedure."),
    writeln("4. Agreement of dismissal."),
    writeln("0. Something else than above."),
    writeln("Please write your answer as just a single number, e.g. '1' or '0'. After entering the number, please hit enter."),
    read_line_to_string(user_input, Input),
    nl,
    map(type, Input, Answer),
    assertz(type(Answer)),
    assertz(asked(type)),
    !.


question(2, Answer) :-
    % Question 4 about earlierbehavior.
    repeat,

    \+asked(earlierbehavior),
    writeln("Has the employee had problematic behavior earlier in his/her career at Municipality Amsterdam?"),
    writeln("1. Yes."),
    writeln("0. No."),
    writeln("Please write your answer as just a single number, e.g. '1' or '0'. After entering the number, please hit enter."),
    read_line_to_string(user_input, Input),
    nl,
    map(earlierbehavior, Input, Answer),
    assertz(earlierbehavior(Answer)),
    assertz(asked(earlierbehavior)),
    !.

question(3, Answer) :-
    % Question 5 about violence.
    repeat,

    \+asked(violence),
    writeln("Is the complaint about violence on the workplace?"),
    writeln("1. Yes."),
    writeln("0. No."),
    writeln("Please write your answer as just a single number, e.g. '1' or '0'. After entering the number, please hit enter."),
    read_line_to_string(user_input, Input),
    nl,
    map(violence, Input, Answer),
    assertz(violence(Answer)),
    assertz(asked(violence)),
    !.

question(4, Answer) :-
    % Question 6 about severe.
    repeat,

    \+asked(severe),
    writeln("Is the warning severe?"),
    writeln("1. Yes."),
    writeln("0. No."),
    writeln("Please write your answer as just a single number, e.g. '1' or '0'. After entering the number, please hit enter."),
    read_line_to_string(user_input, Input),
    nl,
    map(severe, Input, Answer),
    assertz(severe(Answer)),
    assertz(asked(severe)),
    !.

question(5, Answer) :-
    % Question 7 about earlierwarnings.
    repeat,

    \+asked(earlierwarnings),
    writeln("How many warnings has the employee had already?"),
    writeln("Please only enter a number."),
    writeln("Please write your answer as just a single number, e.g. '1' or '0'. After entering the number, please hit enter."),
    read_line_to_string(user_input, Input),
    nl,
    atom_number(Input, Answer),
    assertz(earlierwarnings(Answer)),
    assertz(asked(earlierwarnings)),
    !.

question(6, Answer) :-
    % Question 8 about occupationaldisability.
    repeat,

    \+asked(occupationaldisability),
    writeln("Does the employee have an occupational disability?"),
    writeln("1. Yes."),
    writeln("0. No."),
    writeln("Please write your answer as just a single number, e.g. '1' or '0'. After entering the number, please hit enter."),
    read_line_to_string(user_input, Input),
    nl,
    map(occupationaldisability, Input, Answer),
    assertz(occupationaldisability(Answer)),
    assertz(asked(occupationaldisability)),
    !.

question(7, Answer) :- 
    % Question 9 about monthsabsent.
    repeat,

    \+asked(monthsabsent),
    writeln("How many months has the employee been absent?"),
    writeln("Please only enter a number."),
    writeln("Please write your answer as just a single number, e.g. '1' or '0'. After entering the number, please hit enter."),
    read_line_to_string(user_input, Input),
    nl,
    atom_number(Input, Number),
    map(monthsabsent, Number, Answer),
    assertz(monthsabsent(Answer)),
    assertz(asked(monthsabsent)),
    !.

question(8, Answer) :- 
    % Question 10 about evidencefiring.
    repeat,

    \+asked(evidencefiring),
    writeln("Is there enough juridical evidence to fire the employee?"),
    writeln("1. Yes."),
    writeln("0. No."),
    writeln("Please write your answer as just a single number, e.g. '1' or '0'. After entering the number, please hit enter."),
    read_line_to_string(user_input, Input),
    nl,
    map(evidencefiring, Input, Answer),
    assertz(evidencefiring(Answer)),
    assertz(asked(evidencefiring)),
    !.



clearvariables :-
    % Clear all variables to prepare for a new system run.

    retractall(currentquestion(_)),
    asserta(currentquestion(1)),

    retractall(asked(_)),
    retractall(file(_)),
    retractall(enoughmaterialpresent(_)),
    retractall(type(_)),
    retractall(earlierbehavior(_)),
    retractall(violence(_)),
    retractall(severe(_)),
    retractall(earlierwarnings(_)).

% Call the menu predicate to generate the welcome menu at start of system run.
:- menu.