module profiling::UnitTestQuality

import Domain;
import List;
import IO;

import profiling::ProfilingUtil;

data FileTestQuality = fileTestQuality(
	int asserts,
	int verifies,
	int total,
	int methods,
	real averagePerMethod
);

public Profile profileUnitTestQuality(ProjectAnalysis project) 
{
	int testLOC = 0;
	
	RiskProfile riskProfile = ();
	for(FileAnalysis file <- project.files, file.containsTestClass) {
		testLOC += file.LOC;
		FileTestQuality fileTestQuality = qualityOfFile(file);
		
		riskProfile[getRisk(fileTestQuality.averagePerMethod)] ? 0 += file.LOC;
	}
	
	return convertToProfile(riskProfile, testLOC);
}

public Risk getRisk(real average) {
	if (average <= .6) return veryHigh();
	if (average <= .8) return high();
	if (average <= 1) return moderate();	
	return low();
}

public FileTestQuality qualityOfFile(FileAnalysis fileAnalysis) {
	int asserts = (0 | it + 1 | effectiveLine <- fileAnalysis.lines, /\s*assert/ := effectiveLine.content);
	int verifies = (0 | it + 1 | effectiveLine <- fileAnalysis.lines, /\s*verify/ := effectiveLine.content);
	int testMethods = (0 | it + size(class.methods) | class <- fileAnalysis.classes);
	int total = asserts+verifies;
	
	real averagePerMethod = testMethods == 0 ? 0.0 : 1.0 * total / testMethods; 
	return fileTestQuality(asserts,verifies,total, testMethods, averagePerMethod);
}

