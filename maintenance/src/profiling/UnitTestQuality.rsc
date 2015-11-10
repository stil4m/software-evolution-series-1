module profiling::UnitTestQuality

import Domain;
import List;
import IO;

import profiling::ProfilingUtil;

public Profile profileUnitTestQuality(ProjectAnalysis project) {
	RiskProfile riskProfile = ();
	for(FileAnalysis file <- project.files, file.containsTestClass) {
		testUnitSize = ( 0 | it + method.LOC | class <- file.classes, method <- class.methods, isTestMethod(method));
		
		Risk risk = getRisk(averageAssertCountPerMethod(file));
		riskProfile[risk] ? 0 += testUnitSize;
	}
	
	int totalTestVOLUME = (0 | it + file.LOC | file <- project.files, file.containsTestClass);
	return convertToProfile(riskProfile, totalTestVOLUME);
}

public Risk getRisk(real average) {
	if (average < 1) return veryHigh();
	if (average == 1.) return moderate();	
	return low();
}

public real averageAssertCountPerMethod(FileAnalysis fileAnalysis) {
	int asserts = (0 | it + 1 | effectiveLine <- fileAnalysis.lines, isTestContext(effectiveLine.content));
	int testMethods = (0 | it + size([method | method <- class.methods, isTestMethod(method)]) | class <- fileAnalysis.classes);
	return testMethods == 0 ? 0.0 : 1.0 * asserts / testMethods; 
}

private bool isTestMethod(method) {
	return isTestContext(method.location.file) || /^\s*test/ := method.location.file;
}

private bool isTestContext(str s) {
	return /^\s*assert/ := s 
		|| /^\s*verify/ := s
		|| /^\s*check/ := s
		|| /\s*fail/ := s;
}