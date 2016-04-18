:- use_module(library(clpfd)).

schedule :-
	%print name, prof, day, 
	%retrieves list of all possible courseSchedules and prints the in descending value order, will modify later to only print subset in nicer form.
	findall([X, Va], class(X, Va), AllCourses),
	findall((PossibleSchedules, Value), legalSchedule(AllCourses, PossibleSchedules, Value), Schedules),
	sort(2, @>=, Schedules, Sorted),
	write(Sorted).

% can add test that schedule is in range of credits later, currently, no more than 6 classes allowed, limit placed in subseq.
legalSchedule(AllCourses, MySchedule, Value):-
	subseq(AllCourses,MySchedule, 0),
	noRepeatClasses(MySchedule),
	noTimeConflicts(MySchedule),
	scheduleVal(MySchedule, Value).

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
	



class(['CHEM023A','HM-01',3,'08/30/2016','12/16/2016',['Van Hecke','Johnson','Vosburg','Hawkins'],[[0,9,9.833333333333334,'HM Campus, Shanahan Center, 2460'],[2,9,9.833333333333334,'HM Campus, Shanahan Center, 2460'],[4,9,9.833333333333334,'HM Campus, Shanahan Center, 2460']]],12).
%class(['CHEM023A','HM-02',3,'08/30/2016','12/16/2016',['Van Hecke','Johnson','Vosburg','Hawkins'],[[0,10,10.833333333333334,'HM Campus, Shanahan Center, 2454'],[2,10,10.833333333333334,'HM Campus, Shanahan Center, 2454'],[4,10,10.833333333333334,'HM Campus, Shanahan Center, 2454']]],11).
%class(['CHEM023A','HM-03',3,'08/30/2016','12/16/2016',['Van Hecke','Johnson','Vosburg','Hawkins'],[[0,9,9.833333333333334,'HM Campus, Shanahan Center, 1480'],[2,9,9.833333333333334,'HM Campus, Shanahan Center, 1480'],[4,9,9.833333333333334,'HM Campus, Shanahan Center, 1480']]],10).
%class(['CHEM023A','HM-04',3,'08/30/2016','12/16/2016',['Van Hecke','Johnson','Vosburg','Hawkins'],[[0,9,9.833333333333334,'HM Campus, Shanahan Center, B450'],[2,9,9.833333333333334,'HM Campus, Shanahan Center, B450'],[4,9,9.833333333333334,'HM Campus, Shanahan Center, B450']]],4).
%class(['CL 057','HM-02',0,'01/17/2017','05/14/2017',['McFadden'],[[2,13.25,16.5,'HM Campus, Olin Science Center, B141']]],5).
class(['CL 057','HM-07',0,'01/17/2017','05/14/2017',['Wang'],[[2,13.25,16.166666666666668,'HM Campus, Norman F. Sprague Center, LSC']]],9).
class(['CL 057','HM-08',0,'01/17/2017','05/14/2017',['Hickerson'],[[0,13.25,16.166666666666668,'HM Campus, Parsons Engineering Bldg, B181']]],8).
class(['CL 057','HM-09',0,'01/17/2017','05/14/2017',['Van Heuvelen'],[]],8).
%class(['ENGR079','HM-02',3,'08/30/2016','12/16/2016',['Staff'],[[0,10,10.833333333333334,'HM Campus, Shanahan Center, 2440'],[2,10,10.833333333333334,'HM Campus, Shanahan Center, 2440']]],9).
%class(['ENGR079','HM-03',3,'08/30/2016','12/16/2016',['Staff'],[[0,10,10.833333333333334,'HM Campus, Shanahan Center, 3460'],[2,10,10.833333333333334,'HM Campus, Shanahan Center, 3460']]],10).
%class(['MATH030G','HM-02',1.5,'08/30/2016','10/14/2016',['dePillis'],[[1,9.583333333333334,10.833333333333334,'HM Campus, Shanahan Center, 3460'],[3,9.583333333333334,10.833333333333334,'HM Campus, Shanahan Center, 3460']]],11).
class(['MATH030G','HM-03',1.5,'08/30/2016','10/14/2016',['Staff'],[[1,8.166666666666666,9.416666666666666,'HM Campus, Shanahan Center, B450'],[3,8.166666666666666,9.416666666666666,'HM Campus, Shanahan Center, B450']]],1).
%class(['MATH035','HM-03',1.5,'10/19/2016','12/16/2016',['Williams'],[[1,8.166666666666666,9.416666666666666,'HM Campus, Shanahan Center, B450'],[3,8.166666666666666,9.416666666666666,'HM Campus, Shanahan Center, B450']]],13).
%class(['MATH035','HM-04',1.5,'10/19/2016','12/16/2016',['Williams'],[[1,9.583333333333334,10.833333333333334,'HM Campus, Shanahan Center, B450'],[3,9.583333333333334,10.833333333333334,'HM Campus, Shanahan Center, B450']]],14).

%This code will generate the better schedule between 2 possibilities.
%C #= max(X,Y), rate(a,X), rate(b,Y).
%C = Y, Y = 2,
%X = 1.