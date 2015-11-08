module profiling::UnitTestCoverage

import Domain;
import IO;
import util::Math;
import List;
import Set;

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

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
public Profile profileUnitTestCoverage(ProjectAnalysis project, M3 m3Model) {
	set[FileAnalysis] nonTestFiles = { file | file <- project.files, !file.containsTestClass};
	set[loc] testMethods = { method.location | file <- project.files, file.containsTestClass, class <- file.classes, method <- class.methods};
	
	RiskProfile riskProfile = ();
	for (FileAnalysis file <- nonTestFiles) {
		if (!isEmpty([ method | ClassAnalysis class <- file.classes, method <- class.methods])) { 	
			riskProfile[calculateCoverageRisk(file, m3Model, testMethods)] ? 0 += file.LOC;
		}
	}
	
	int nonTestLOC = (0 | it + file.LOC | file <- nonTestFiles);
	return convertToProfile(riskProfile, nonTestLOC);
}


private Risk calculateCoverageRisk(FileAnalysis file, M3 m3Model, set[loc] testMethods) {
	//set[loc] methods = { method.location | class <- file.classes, method <- class.methods};
	//int totalInvocationCount = ( 0 | it + 1 | <lhs,rhs> <- m3Model@methodInvocation, lhs in testMethods, rhs in methods);
	//int totalComplexity = ( 0 | it + method.cc | class <- file.classes, method <- class.methods);
	//return getCoverageRisk(totalInvocationCount, totalComplexity);	//OR
	set[loc] testableMethods = { method.location | class <- file.classes, method <- class.methods, isTestable(method.location, m3Model)};
	int numberOfInvokedTestableMethods = size({rhs | <lhs,rhs> <- m3Model@methodInvocation, lhs in testMethods, rhs in testableMethods});
	if(size(testableMethods) == 0 ) {
		return low();
	}
	return getCoverageRisk(numberOfInvokedTestableMethods, size(testableMethods));
}

private Risk getCoverageRisk(int invocationCount, int complexity) {
	real coverage = toReal(invocationCount) / complexity;
	
	if (coverage <= .4) return veryHigh();
	if (coverage <= .6) return high();
	if (coverage <= .8) return moderate();	
	return low();
}

private set[Modifier] methodModifiers(loc method, M3 model) {
	return { m | <lhs, m>  <- model@modifiers, lhs == method};
}

private bool isTestable(loc method, M3 m3Model) {
	set[Modifier] modifiers = methodModifiers(method, m3Model);
	return \public() in modifiers || \protected() in modifiers; 
}
