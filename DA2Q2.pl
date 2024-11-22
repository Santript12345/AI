:- use_module(library(csv)).
:- use_module(library(http/http_server)).
:- use_module(library(http/http_parameters)).

% Dynamic predicate to store student data
:- dynamic student/4.

% Load data from CSV file
load_data(File) :-
    retractall(student(_, _, _, _)), % Clear existing data
    csv_read_file(File, Rows, [functor(student), arity(4)]),
    maplist(assert, Rows).

% Eligibility Rules
eligible_for_scholarship(Student_ID) :-
    student(Student_ID, _, Attendance, CGPA),
    Attendance >= 75,
    CGPA >= 9.0.

permitted_for_exam(Student_ID) :-
    student(Student_ID, _, Attendance, _),
    Attendance >= 75.

% REST API Handler
:- http_handler(root(check), handle_request, []).

% Handle Requests
handle_request(Request) :-
    ( http_parameters(Request, [id(StudentID, [integer])]) ->
        % Query for specific StudentID
        ( student(StudentID, Name, Attendance, CGPA) ->
            ( eligible_for_scholarship(StudentID) ->
                Status = "Eligible for Scholarship and Exam"
            ; permitted_for_exam(StudentID) ->
                Status = "Eligible for Exam Only"
            ; Status = "Not Eligible"
            ),
            format('Content-type: text/plain~n~n'),
            format('~w (~w): Attendance = ~w, CGPA = ~w, Status = ~w~n',
                [StudentID, Name, Attendance, CGPA, Status])
        ; % If StudentID not found
            format('Content-type: text/plain~n~n'),
            format('Student ID ~w not found~n', [StudentID])
        )
    ; % Query for all students if no StudentID is provided
        findall(
            [StudentID, Name, Attendance, CGPA, Status],
            (
                student(StudentID, Name, Attendance, CGPA),
                ( eligible_for_scholarship(StudentID) ->
                    Status = "Eligible for Scholarship and Exam"
                ; permitted_for_exam(StudentID) ->
                    Status = "Eligible for Exam Only"
                ; Status = "Not Eligible"
                )
            ),
            Results
        ),
        format('Content-type: text/plain~n~n'),
        print_results(Results)
    ).

% Print results for all students
print_results([]).
print_results([[StudentID, Name, Attendance, CGPA, Status] | Rest]) :-
    format('~w (~w): Attendance = ~w, CGPA = ~w, Status = ~w~n',
        [StudentID, Name, Attendance, CGPA, Status]),
    print_results(Rest).
