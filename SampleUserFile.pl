%To Run: Go to the folder this file is saved in and run the command:
%		 /usr/local/bin/swipl -f SampleUserFile.pl 

:- consult(sourceCode).
setPreferences :-
% make it so they only need to write these 3 lines, its okay if its more complicated to run
	rateProf('Levy', 10),
	rateProf('Lyzenga', 15),
	rateProf('Williams', 20),
	rateProf('Dodds', 100),
	rateClass('WRIT001', 5),
	rateClass('MATH030B', 5),
	rateClass('CHEM024', 5),
	rateSection('WRIT001', 'HM-01', 12),
	rateSection('ECON104', 'HM-01', 23),
	setMaxCourseLoad(17),
	setMinCourseLoad(14),
	rateDay('Monday', -10),
	rateDay('Friday', -20),
	numSchedulesToGenerate(10).
