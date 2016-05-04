% Run in terminal with the command: /usr/local/bin/swipl -f sourceCode.pl

:- use_module(library(clpfd)).
:- dynamic prof/2, section/3, courseTitle/2, day/3, timeBlock/3, minCourseLoad/1, maxCourseLoad/1.
:- initialization(main).

%###################################################################################################################
/*This section of code reads in the Scheduler App generated class list and sets up the fact database*/
main :-
	write_ln("Please input your list of classes as generated by the scheduler app and click enter. "),
	read([First | Rest]),
	addClasses([First | Rest]),
	write_ln(''),
	write_ln("Please input the name of the file in which your program is written inside quotation marks and followed by a period. "),
	read(FileName),
	write_ln(''),
	write_ln("Please input the number of schedules you would like to generate followed by a period. "),
	read(Num),
	write_ln(''),
	generateSchedules(FileName, Num).

%Takes in input list of classes from scheduler app and passes each class to addClass.
addClasses([]).
addClasses([First | Rest]):-
	addClass(First),
	addClasses(Rest).

%Builds the fact database by insuring that all class titles, sections, professors, and classes are added.
addClass([Title, Section, Units, StartDate, EndDate, Profs, Times]):-
	addCourseTitle(Title),
	assert(section(Title, Section, 0)),
	addProfs(Profs), 
	assert(class([Title, Section, Units, StartDate, EndDate, Profs, Times], 0)).

addProfs([]).
%This avoids duplication of professors
addProfs([X | Rest]):-
	prof(X, _),
	addProfs(Rest).
%Will only run if the professor is not already in the database.
addProfs([X | Rest]):-
	assert(prof(X, 0)),
	addProfs(Rest).

%avoids duplicate courseTitles
addCourseTitle(Title):-
	courseTitle(Title, _).
addCourseTitle(Title):-
	assert(courseTitle(Title, 0)).


%###################################################################################################################
/*This section of code allows the user to specify their preferences for their schedule.
The default rating for everything is zero, so a negative rating indicates that adding a particular,
class, professor, section, day, or time would actually decrease your enjoyment of a particular
schedule and a positive rating indicates you would enjoy a schedule with that thing better than you
would enjoy a schedule without it. There is no set ranking system so that users can make use of the scale
that makes the most sense to them.*/

%This change a professors rating from the default of 0. It will modify the value of any class sections the professor teaches.
rateProf(Name, Value):- 
	prof(Name, _),
	retract(prof(Name, _)),
	assert(prof(Name, Value)). 
rateProf(Name, _):-
	\+prof(Name, _),
	write_ln(""),
	write("ERROR: '"),
	write(Name),
	write("' is not a valid professors name, check your spelling, check your class input list, "),
	write_ln("and make sure you put the professors last name in quotation marks. ").


%This change a classes rating from the default of 0. It will modify the value of all sections of the class.
rateClass(Title, Value):- 
	courseTitle(Title, _),
	retract(courseTitle(Title, _)),
	assert(courseTitle(Title, Value)).
rateClass(Title, _):-
	\+courseTitle(Title, _),
	write_ln(""),
	write("ERROR: '"),
	write(Title),
	write("' is not a valid class title, check your spelling, check your class input list, "),
	write_ln("and make sure you put the class title in quotation marks. ").

%This change the rating of a specific section of a class from the default of 0. Only affects this section.
rateSection(Title, Section, Value):- 
	section(Title, Section, _),
	retract(section(Title, Section, _)),
	assert(section(Title, Section, Value)).
rateSection(Title, Section, _):-
	\+section(Title, Section, _),
	write_ln(""),
	write("ERROR: "),
	write([Title, Section]),
	write(" is not a valid class title and section combination, check your spelling, check your class input list, "),
	write_ln("and make sure you put them both in quotation marks. ").


%Modifies the value of any class sections that meet on this day.
rateDay(Day, Val):-
	day(Day, N, _),
	retract(day(Day, N, _)),
	assert(day(Day, N, Val)).
rateDay(Day, _):-
	\+day(Day, _, _),
	write_ln(""),
	write("ERROR: "),
	write(Day),
	write(" is not a valid day of the week, check your spelling, and make sure you use the full word "),
	write_ln("(e.g. 'Wednesday') and place it in quotation marks. ").


/*Allows the user to specify their preference (or more likely their dislike) of classes which occur within
a certain time period. Such as 8 AM to 10 AM, Takes times in military time with minutes as decimals. 
(EX, 13.75 = 1:45 PM */
rateTimeBlock(Start, End, Val):-
	Start >= 0,
	24 >= End,
	End >= Start,
	assert(timeBlock(Start, End, Val)).

rateTimeBlock(Start, End, _):-
	Start < 0,
	End >= Start,
	write_ln(""),
	write("ERROR: "),
	write(Start),
	write(" is not a valid start time for a block. Times should be military times between 0 and 24, "),
	write_ln("with minutes represented as fractions of hours in decimal form. (e.g. 1:45 PM = 13.75").
rateTimeBlock(Start, End, _):-
	End > 24,
	End >= Start,
	write_ln(""),
	write("ERROR: "),
	write(End),
	write(" is not a valid end time for a block. Times should be military times between 0 and 24, "),
	write_ln("with minutes represented as fractions of hours in decimal form. (e.g. 1:45 PM = 13.75").
rateTimeBlock(Start, End, _):-
	End < Start,
	write_ln(""),
	write("ERROR: "),
	write([Start, End]),
	write(" Valid blocks have a start time smaller than their end time. Times should be military times between 0 and 24, "),
	write_ln("with minutes represented as fractions of hours in decimal form. (e.g. 1:45 PM = 13.75").

%Specify the range of course credits you want in any possible schedules that are generated.
%Default min and max course load are the min and max courseloads to be a full time student (12-18)
setMaxCourseLoad(N):-
	N > 0,
	retract(maxCourseLoad(_)),
	assert(maxCourseLoad(N)),
	N < 28.
setMaxCourseLoad(N):-
	0 >= N,
	write_ln(""),
	write("ERROR: "),
	write_ln("You cannot generate schedules with a Maximum of less than 1 credit. "),
	false.
setMaxCourseLoad(N):-
	N >= 28,
	write_ln(""),
	write("WARNING: Taking a course load with a maximum of "),
	write(N),
	write(" credits, could cause sleep deprivation, depression, and permanent damage to your mental, "),
	write_ln("emotional, physical, and spiritual well being.").

setMinCourseLoad(N):-
	N >0,
	retract(minCourseLoad(_)),
	assert(minCourseLoad(N)).
setMinCourseLoad(N):-
	0 >= N,
	write_ln(""),
	write("ERROR: "),
	write_ln("You cannot generate schedules with a Minimum of less than 1 credit. "),
	false.
setMinCourseLoad(N):-
	write_ln(""),
	write("WARNING: Taking a course load with a minimum of "),
	write(N),
	write(" credits, could cause sleep deprivation, depression, and permanent damage to your mental, "),
	write_ln("emotional, physical, and spiritual well being.").


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
	sumDayValue(Times, D),
	sumTimeValue(Times, E),
	Value is A + B + C + D + E,
	assert(class([Title, Section, Units, StartDate, EndDate, Profs, Times], Value)).

sumProfValue([], 0).
sumProfValue([Prof1 | RestProfs], Value):- 
	sumProfValue(RestProfs, VRest),
	prof(Prof1, V1),
	Value is V1 + VRest.

sumDayValue([], 0).
sumDayValue([[D1 | _] | RestT], Value):-
	sumDayValue(RestT, VRest),
	day(_, D1, V1),
	Value is V1 + VRest.

%Computes values for any class ENTIRELY within a rated timeBlock
sumTimeValue([], 0).
sumTimeValue([[_, SClass, EClass | _] | RestT], Value):-
	sumTimeValue(RestT, VRest),
	timeBlock(Start, End, V1),
	SClass >= Start,
	End >= EClass,
	Value is V1 + VRest, !.
%For classes which are not entirely inside a rated timeBlock
sumTimeValue([[_ | _] | RestT], Value):-
	sumTimeValue(RestT, Value).


%###################################################################################################################
/* This section of code, called by typing 'generateSchedule.' prints out the schedules generated for a user*/
generateSchedules(FileName, Num):-
	readInFile(FileName),
	findall([OriginalX, OriginalVa], class(OriginalX, OriginalVa), Classes),
	classValues(Classes),
	findall([X, Va], class(X, Va), AllCourses),
	findall([MySchedule, Value, Units], (validSchedule(AllCourses, MySchedule, Value, Units)), Schedules),
	sort(2, @>=, Schedules, Sorted),
	write_ln(""),
	writeSchedules(Sorted, 0, Num).
	
readInFile(FileName):-
	open(FileName,read, FileDescriptor),
	read(FileDescriptor, Term),
	call(Term),
	minCourseLoad(Min),
	maxCourseLoad(Max),
	verifyMinMax(Min, Max).

verifyMinMax(Min, Max):-
	Max >= Min.
verifyMinMax(Min, Max):-
	write_ln(""),
	write("Error: Your minimum course load of "),
	write(Min),
	write(" must be less than or equal to your maximum course load of "),
	write_ln(Max).

validSchedule(AllCourses, MySchedule, Value, Units):-
	subseq(AllCourses, MySchedule, 0, Units),
	noRepeatClasses(MySchedule),
	noTimeConflicts(MySchedule),
	scheduleVal(MySchedule, 0, Value).

writeSchedules(_, Num, Num).
writeSchedules(_, _, NumToPrint):-
	NumToPrint < 0,
	write_ln("Please input a positive number of schedules to generate"),
	write_ln("").
writeSchedules([], N, _):-
	write("There were only "),
	write(N),
	write_ln(" possible schedules.").
writeSchedules([ [H, Va, Units]| Rest], N, MaxPrintedSchedules):-
	N \= MaxPrintedSchedules,
	M is N +1,
	write("Schedule Number: "),
	write(M),
	write(" has "),
	write(Units),
	write(" units and a preference value of "),
	write_ln(Va),
	writeSchedule(H),
	writeSchedules(Rest, M, MaxPrintedSchedules).

writeSchedule([]):-
	write_ln("").
writeSchedule([[[Title, Section | _], Value]| Rest]):-
	write(Title),
	write(" "),
	write(Section),
	write(" "),
	write_ln(Value),
	writeSchedule(Rest).

%###################################################################################################################

%returns all possible combinations sets of courses between the min and max number of units.
subseq([], [], N, N):-
	minCourseLoad(X),
	N >= X,
	maxCourseLoad(Y),
	Y >= N.
subseq([_ | RestCourses], MyClasses, N, U) :-
	subseq(RestCourses, MyClasses, N, U).
subseq([Class | RestCourses], [Class | RestMyClasses], N, U) :-
	maxCourseLoad(Y),
	N < Y,
	unitsSum(Class, N, M),
	subseq(RestCourses, RestMyClasses, M, U).

unitsSum([[_, _, Units | _], _], N, M):-
	M is Units + N.

%Checks that no class has been added multiple times to a schedule.
noRepeatClasses(ClassList):-
	classNameList(ClassList, NameList),
    is_set(NameList).

% Get the title of every course in a schedule
classNameList([], []).
classNameList([[[H|_]|_]|Rest], [H | RNames]):-
	classNameList(Rest, RNames).

%generates list of list of class times. and passes to classConflict
noTimeConflicts(MySchedule):-
	classStartAndEnd(MySchedule, [FirstClassTL | RestClassTL]),
	classConflict(FirstClassTL, RestClassTL).

%returns a list of all class times in a given possible schedule which can then be checked for conflicts.
classStartAndEnd([], []).
classStartAndEnd([[[_, _, _, SDate, EDate, _, Times], _] | Rest ], [[SDate, EDate, Times] | RTimes]):-
	classStartAndEnd(Rest, RTimes).

%gets every 2 classes' lists of times and passes them to singleClassConflict or dateConflict to check if they conflict.
classConflict(_, []).
classConflict([S1, E1, Class1], [[ S2, E2, Class2]| Rest]):-
	singleClassConflict(Class1, Class2),
	classConflict([S1, E1, Class1], Rest),
	classConflict([S2, E2, Class2], Rest), !.
classConflict([S1, E1, Class1], [[ S2, E2, Class2]| Rest]):-
	dateConflict(S1, E2),
	classConflict([S1, E1, Class1] , Rest),
	classConflict([S2, E2, Class2], Rest), !.
classConflict([S1, E1, Class1], [[S2, E2, Class2]| Rest]):-
	dateConflict(S2, E1),
	classConflict([S1, E1, Class1], Rest),
	classConflict([S2, E2, Class2], Rest).

%Checks if the end month of one class is the start month of another class. (They are opposite half semester classes.)
dateConflict([M1 | _], [M2 | _]):-
	M1 = M2.

%passes each time block for class 1 and all of class 2's time blocks to singleTimeSlot
singleClassConflict([], _).
singleClassConflict([C1T1 | RestC1], C2):-
	singleTimeSlot(C1T1, C2),
	singleClassConflict(RestC1, C2).

%passes each time block for class 2 along with a specific time block of class 1 to singleTimeSlot
singleTimeSlot(_, []).
singleTimeSlot(C1T1, [C2T1 | RestC2]):-
	singleTimeConflict(C1T1, C2T1),
	singleTimeSlot(C1T1, RestC2).


% Checks if 2 class times overlap
singleTimeConflict([D1 | _], [D2 | _]):-
	D1 \= D2.
singleTimeConflict([D1, S1, E1 | _], [D2, S2 | _]):-
	D1 = D2,
	S1 < S2, 
	E1 < S2.
singleTimeConflict([D1, S1 | _], [D2, S2, E2 | _]):-
	D1 = D2,
	S2< S1, 
	E2 < S1.

%Generates a singal schedules value
scheduleVal([], CurVal, CurVal).
scheduleVal([ [_, CVal] | MySchedule], CurVal, Value):-
	NValue is CVal + CurVal,
	scheduleVal(MySchedule, NValue, Value).

%###################################################################################################################
%Initial Assertions which may be modified by the user.

day('Monday',0,0).
day('Tuesday',1,0).
day('Wednesday',2,0).
day('Thursday',3,0).
day('Friday',4,0).
day('Saturday',5,0).
day('Sunday',6,0).

maxCourseLoad(18).
minCourseLoad(12).