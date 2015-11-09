module profiling::UnitTestQuality

import Domain;
import List;
import IO;

import profiling::ProfilingUtil;

public Profile profileUnitTestQuality(ProjectAnalysis project) {
	int testLOC = 0;
	
	RiskProfile riskProfile = ();
	for(FileAnalysis file <- project.files, file.containsTestClass) {
		testLOC += file.LOC;
		real averageAssertCountPerMethod = averageAssertCountPerMethod(file);
		
		Risk risk = getRisk(averageAssertCountPerMethod);
		riskProfile[risk] ? 0 += file.LOC;
	}
	
	return convertToProfile(riskProfile, testLOC);
}

public Risk getRisk(real average) {
	if (average <= .6) return veryHigh();
	if (average <= .8) return high();
	if (average <= 1) return moderate();	
	return low();
}

public real averageAssertCountPerMethod(FileAnalysis fileAnalysis) {
	int asserts = (0 | it + 1 | effectiveLine <- fileAnalysis.lines,
		/\s*assert/ := effectiveLine.content 
		|| /\s*verify/ := effectiveLine.content
		|| /\s*check/ := effectiveLine.content
		|| /\s*fail/ := effectiveLine.content);
	
	int testMethods = (0 | it + size(class.methods) | class <- fileAnalysis.classes);
	
	return testMethods == 0 ? 0.0 : 1.0 * asserts / testMethods; 
}