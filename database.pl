:- dynamic prof/2, section/3, courseTitle/2, day/3, timeBlock/3, maxCourseLoad/1, minCourseLoad/1.

%###################################################################################################################
/* Sets up the database based on the users input list of classes*/

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