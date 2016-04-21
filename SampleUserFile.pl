%To Run: Go to the folder this file is saved in and run the command:
%		 /usr/local/bin/swipl -f SampleUserFile.pl 

:- consult(sourceCode).

setPreferences :-
% make it so they only need to write these 3 lines, its okay if its more complicated to run
	rateProf('Williams', 10),
	rateClass('MATH030G', 5),
	rateSection('MATH035','HM-03', 100),
	generateSchedule.