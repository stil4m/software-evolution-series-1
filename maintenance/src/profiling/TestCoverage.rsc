module profiling::TestCoverage

import Domain;
import IO;
import util::Math;

import lang::java::jdt::m3::Core;

import profiling::ProfilingUtil;
// We choose to do the coverage on file basis:
// File:
// 	Pros: 
//		- You can relate it to the LOC
//		- Allow you to include the complexity of private methods
//  Cons: 
//		- You are adding up the complexity. e.g. non complexmethod with lots of test could compensate for complex methods with no tests.
//
// (Alternative): Method:
//	Pros: 
//		- Very specific
//	Cons:
//		- How should you treat private methods
//
public Profile analyzeTestCoverage(ProjectAnalysis project, M3 m3Model) {
	set[FileAnalysis] nonTestFiles = {file | file <- project.files, !file.containsTestClass};
	set[loc] testMethods = { method.location | file <- project.files, file.containsTestClass, class <- file.classes, method <- class.methods};
	
	RiskProfile riskProfile = ();
	for(file <- nonTestFiles) {
		riskProfile[calculateCoverageRisk(file, m3Model, testMethods)] ? 0 += file.LOC;
	}
	
	iprintln(riskProfile);
	
	int nonTestLOC = (0 | it + file.LOC | file <- nonTestFiles);
	return convertToProfile(riskProfile, nonTestLOC);
}


private Risk calculateCoverageRisk(FileAnalysis file, M3 m3Model, set[loc] testMethods) {
	set[loc] methods = { method.location | class <- file.classes, method <- class.methods};
	int totalInvocationCount = ( 0 | it + 1 | <lhs,rhs> <- m3Model@methodInvocation
									, lhs in testMethods
									, rhs in methods);
	
	int totalComplexity = ( 0 | it + method.cc | class <- file.classes, method <- class.methods);
	
	iprintln("<totalInvocationCount> : <totalComplexity>");
	return getCoverageRisk(totalInvocationCount, totalComplexity);
}


private set[Modifier] methodModifiers(loc method, M3 model) {
	return { m | <lhs, m>  <- model@modifiers, lhs == method};
}
private bool isTestable(loc method, M3 m3Model) {
	set[Modifier] modifiers = methodModifiers(method, m3Model);
	return \public() in modifiers || \protected() in modifiers; 
}

private Risk getCoverageRisk(int invocationCount, int complexity) {
	real coverage = toReal(invocationCount) / complexity;
	
	if (coverage <= 40) return veryHigh();
	if (coverage <= 60) return high();
	if (coverage <= 80) return moderate();	
	return low();
} 