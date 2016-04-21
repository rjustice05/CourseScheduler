%To Run: Go to the folder this file is saved in and run the command:
%		 /usr/local/bin/swipl -f SampleUserFile.pl 

:- consult(sourceCode).

setPreferences :-
% make it so they only need to write these 3 lines, its okay if its more complicated to run
	rateProf('Wang', 10),
	rateClass('MATH030G', 5),
	generateSchedule.