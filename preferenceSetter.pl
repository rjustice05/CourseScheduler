:- ensure_loaded(database).

readInFile(FileName):-
	open(FileName,read, FileDescriptor),
	read(FileDescriptor, Term),
	call(Term),
	minCourseLoad(Min),
	maxCourseLoad(Max),
	verifyMinMax(Min, Max).


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
	retract(section(Title, Name, _)),
	assert(section(Title, Name, Value)).
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