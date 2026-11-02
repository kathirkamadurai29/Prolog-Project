% Student Performance Analysis System
% Record format: student(Id, Name, [Subject1, Subject2, Subject3, Subject4, Subject5]).
% Marks are out of 100. A student passes when every subject mark is at least 40.

:- dynamic student/3.

student(1001, 'Aarav Sharma', [85, 78, 92, 74, 88]).
student(1002, 'Maya Patel', [91, 86, 89, 94, 90]).
student(1003, 'Noah Wilson', [42, 55, 38, 61, 49]).
student(1004, 'Isha Gupta', [33, 47, 39, 52, 41]).

start :-
    writeln('=== Student Performance Analysis System ==='),
    menu.

menu :-
    nl,
    writeln('1. Show all student results'),
    writeln('2. Analyze one student by ID'),
    writeln('3. Show class summary'),
    writeln('0. Exit'),
    write('Choose an option: '),
    flush_output,
    read_line_to_string(user_input, Input),
    (   number_string(Choice, Input)
    ->  handle_choice(Choice)
    ;   writeln('Please enter a valid menu number.'), menu
    ).

handle_choice(0) :- writeln('Goodbye!').
handle_choice(1) :- show_all_results, menu.
handle_choice(2) :- analyze_by_id, menu.
handle_choice(3) :- class_summary, menu.
handle_choice(_) :- writeln('Invalid option.'), menu.

average(Marks, Average) :-
    sum_list(Marks, Total),
    length(Marks, Count),
    Count > 0,
    Average is Total / Count.

grade(Average, 'A') :- Average >= 90, !.
grade(Average, 'B') :- Average >= 80, !.
grade(Average, 'C') :- Average >= 70, !.
grade(Average, 'D') :- Average >= 60, !.
grade(Average, 'E') :- Average >= 50, !.
grade(_, 'F').

result_status(Marks, 'PASS') :-
    forall(member(Mark, Marks), Mark >= 40), !.
result_status(_, 'FAIL').

analyze_student(Id, Name, Marks) :-
    average(Marks, Average),
    grade(Average, Grade),
    result_status(Marks, Status),
    format('~nStudent ID: ~w~nName: ~w~nMarks: ~w~nAverage: ~2f~nGrade: ~w~nResult: ~w~n',
           [Id, Name, Marks, Average, Grade, Status]).

show_all_results :-
    writeln(''),
    writeln('ID     Name                 Average  Grade  Result'),
    writeln('---------------------------------------------------'),
    forall(student(Id, Name, Marks), print_result_row(Id, Name, Marks)).

print_result_row(Id, Name, Marks) :-
    average(Marks, Average),
    grade(Average, Grade),
    result_status(Marks, Status),
    format('~w  ~w  ~2f     ~w      ~w~n', [Id, Name, Average, Grade, Status]).

analyze_by_id :-
    write('Enter student ID: '),
    flush_output,
    read_line_to_string(user_input, Input),
    (   number_string(Id, Input),
        student(Id, Name, Marks)
    ->  analyze_student(Id, Name, Marks)
    ;   writeln('No student found with that ID.')
    ).

class_summary :-
    findall(Average, (student(_, _, Marks), average(Marks, Average)), Averages),
    (   Averages = [_|_]
    ->  sum_list(Averages, Total),
        length(Averages, Count),
        ClassAverage is Total / Count,
        findall(1,
                (student(_, _, Marks), result_status(Marks, 'PASS')),
                PassingStudents),
        length(PassingStudents, PassingCount),
        FailingCount is Count - PassingCount,
        format('~nNumber of students: ~w~nClass average: ~2f~nPassing students: ~w~nFailing students: ~w~n',
               [Count, ClassAverage, PassingCount, FailingCount])
    ;   writeln('There are no student records to summarize.')
    ).
