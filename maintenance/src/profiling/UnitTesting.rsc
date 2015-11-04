module profiling::UnitTesting

import Domain;
import IO;
import util::Math;

public Profile profileUnitTesting(ProjectAnalysis project) {
	int totalLOC = project.LOC;
	list[FileAnalysis] testFiles = [file | file <- project.files, file.containsTestClass];
	int totalTestLOC = (0 | it + file.LOC | file <- testFiles);
	
	int testMethodCount = (0 | it + 1 | file <- testFiles, class <- file.classes, method <- class.methods);
	
	ProfileData profileData = ("Test volume" : totalTestLOC,
								"Test method count": testMethodCount,
								"Test volume percentage" : getTestRate(totalTestLOC, totalLOC),
								"Testable methods" : 0,
								"Methods tested": 0);
								
	iprintln(profileData);
									
	return plusPlus(profileData);
}

private real getTestRate(int testLOC, int totalLOC) = toReal(testLOC) / totalLOC;