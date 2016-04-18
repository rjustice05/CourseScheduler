 %:-  module(ModuleName, 
  %                     List_of_Predicates_to_be_Exported).
:- use_module(library(clpfd)).
:- dynamic prof/2, section/3, courseTitle/2.
:- initialization(main).

%###################################################################################################################
/*This section of code reads in the Scheduler App generated class list and sets up the fact database*/
main :-
	write_ln("Please input you list of classes as generated by the scheduler app and click enter. "),
	read([First | Rest]),
	addClasses([First | Rest]).

addClasses([]).

addClasses([First | Rest]):-
	addClass(First),
	addClasses(Rest).

addClass([Title, Section, Units, StartDate, EndDate, Profs, Times]):-
	addCourseTitle(Title),
	assert(section(Title, Section, 0)),
	%if a professor is already in the database this will make 2 copies, 
	%but they will have the same rating and the extra copies will be deleted if they are given a new rating.
	addProfs(Profs), 
	assert(class([Title, Section, Units, StartDate, EndDate, Profs, Times], 0)).

addProfs([]).
%This avoids duplication of professors
addProfs([X | Rest]):-
	prof(X,_),
	addProfs(Rest).

addProfs([X | Rest]):-
	assert(prof(X, 0)),
	addProfs(Rest).

addCourseTitle(Title):-
	courseTitle(Title, _).

addCourseTitle(Title):-
	assert(courseTitle(Title, 0)).

%###################################################################################################################
/*This section of code allows the user to specify their preferences for their schedule.*/
rateProf(Name, Value):- 
	prof(Name, _),
	retract(prof(Name, _)),
	assert(prof(Name, Value)). 

rateClass(Title, Value):- 
	courseTitle(Title, _),
	retract(courseTitle(Title, _)),
	assert(courseTitle(Title, Value)).

rateSection(Title, Section, Value):- 
	section(Title, Section, _),
	retract(section(Title, Name, _)),
	assert(section(Title, Name, Value)).



%###################################################################################################################
% Methods to computes the  total value a class would add to the user's schedule
classValues([]).

classValues([[C1, V1] | RC]):-
	classValue(C1, V1),
	classValues(RC).

classValue([Title, Section, Units, StartDate, EndDate, Profs, Times], _):-
	retract(class([Title, Section, Units, StartDate, EndDate, Profs, Times], _)),
	courseTitle(Title, A),
	section(Title, Section, B),
	sumProfValue(Profs, C),
	Value is A + B + C,
	assert(class([Title, Section, Units, StartDate, EndDate, Profs, Times], Value)).

sumProfValue([], 0).

sumProfValue([Prof1 | RestProfs], Value):- 
	sumProfValue(RestProfs, VRest),
	prof(Prof1, V1),
	Value is V1 + VRest.

%###################################################################################################################
/* This section of code, called by typing 'generateSchedule.' prints out the schedules generated for a user*/
generateSchedule :-
	findall([OriginalX, OriginalVa], class(OriginalX, OriginalVa), Classes),
	classValues(Classes),
	findall([X, Va], class(X, Va), AllCourses),
	findall([MySchedule, Value], (subseq(AllCourses,MySchedule, 0), noRepeatClasses(MySchedule), noTimeConflicts(MySchedule),scheduleVal(MySchedule, Value)), Schedules),
	sort(2, @>=, Schedules, Sorted),
	write_ln("                   Done                                                "),
	writeSchedules(Sorted, 1).

writeSchedules([], _).

writeSchedules([ [H, Va]| Rest], N):-
	write("Schedule Number: "),
	write(N),
	write(" has a preference value of "),
	write_ln(Va),
	writeSchedule(H),
	M is N +1,
	writeSchedules(Rest, M).

writeSchedule([]):-
	write_ln("").

writeSchedule([[[Title, Section | _], Value]| Rest]):-
	write(Title),
	write(" "),
	write(Section),
	write(" "),
	write_ln(Value),
	writeSchedule(Rest).

% Testig functions
write_Helper([]).
write_Helper([[T, S | _]| Rest]):-
	write_ln([T,S]),
	write_Helper(Rest).



%###################################################################################################################
%print name, prof, day, 
%retrieves list of all possible courseSchedules and prints the in descending value order, will modify later to only print subset in nicer form.


% can add test that schedule is in range of credits later, currently, no more than 6 classes allowed, limit placed in subseq.

%returns all possible combinations of between 1 and 6 courses, will be modified to have variable max classes or credit based max 
subseq([],[], N):-
	N > 0.
subseq([_ | RestCourses], MyClasses, N) :-
	subseq(RestCourses, MyClasses, N).
subseq([Class | RestCourses], [Class | RestMyClasses], N) :-
	N < 6,
	subseq(RestCourses, RestMyClasses, N+1).

%Checks that no class has been added multiple times to a schedule.
%Could use is_set(NameList) instead of last 3 lines of code?
noRepeatClasses(ClassList):-
	classNameList(ClassList, NameList),
    setof(X, member(X, NameList), Set), 
    length(Set, Len), 
    length(NameList, Len).

% Get the title of every course in a schedule
classNameList([], []).
classNameList([[[H|_]|_]|Rest], [H | RNames]):-
	classNameList(Rest, RNames).


noTimeConflicts(MySchedule):-
	classStartAndEnd(MySchedule, [FirstClassTL | RestClassTL]),
	classConflict(FirstClassTL, RestClassTL).

%Currently considers all classes to be full semester long, will be fixed later to read start/end dates.
classStartAndEnd([], []).
classStartAndEnd([[[_, _, _, _, _, _, Times], _] | Rest ], [Times | RTimes]):-
	classStartAndEnd(Rest, RTimes).

%Checks if any two classes in a list conflict.
classConflict(_, []).
classConflict(Class1, [Class2 | Rest]):-
	singleClassConflict(Class1, Class2),
	classConflict(Class1, Rest),
	classConflict(Class2, Rest).

%Check if two courses have overlapping class times.
singleClassConflict([], _).
singleClassConflict([C1T1 | RestC1], C2):-
	singleTimeSlot(C1T1, C2),
	singleClassConflict(RestC1, C2).

%Checks if one class time overlaps with any of another courses class times.
singleTimeSlot(_, []).
singleTimeSlot(C1T1, [C2T1 | RestC2]):-
	singleTimeConflict(C1T1,C2T1),
	singleTimeSlot(C1T1, RestC2).


% Checks if 2 class times overlap
singleTimeConflict([D1, S1, E1 | _],[D2, S2, E2 | _]):-
	D1 \= D2;
	(S1 < S2, E1 < S2);
	(S2< S1, E2 < S1).

%Generates a singal schedules value
scheduleVal([], 0).
scheduleVal([ [_, CVal] | MySchedule], Value):-
	Value #= CVal + ValRest,
	scheduleVal(MySchedule, ValRest).


