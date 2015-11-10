module profiling::UnitTestCoverage

import Domain;
import IO;
import util::Math;
import List;
import Set;
import DateTime;

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import profiling::ProfilingUtil;

public Profile profileUnitTestCoverage(ProjectAnalysis project, M3 m3Model) {
	set[FileAnalysis] nonTestFiles = { file | file <- project.files, !file.containsTestClass};
	set[loc] testMethods = { method.location | file <- project.files, file.containsTestClass, class <- file.classes, method <- class.methods};
	map[loc,set[Modifier]] modifierMap = toMap(m3Model@modifiers);
	
	RiskProfile riskProfile = ();
	for (FileAnalysis file <- nonTestFiles) {
		fileUnitSize = (0 | it + method.LOC | class <- file.classes, method <- class.methods);
	
		set[MethodAnalysis] testableMethods = { method | ClassAnalysis class <- file.classes, method <- class.methods, isTestable(modifierMap[method.location]? {})};
		if (!isEmpty(testableMethods)) {
			Risk risk = calculateCoverageRisk(testableMethods, file, m3Model, testMethods);
			riskProfile[risk] ? 0 += fileUnitSize;
		}
	}
	
	int totalTestVolume = (0 | it + file.LOC | file <- project.files, file.containsTestClass);
	return convertToProfile(riskProfile, project.LOC - totalTestVolume);
}

private Risk calculateCoverageRisk(set[MethodAnalysis] testableMethods, FileAnalysis file, M3 m3Model, set[loc] testMethods) {
	set[loc] methodLocs = {};
	map[loc, int] methodComplexityMap = ();
	for (method <- testableMethods) {
		methodLocs += method.location;
		methodComplexityMap[method.location] = method.cc;
	}
	
	rel[loc,loc] invocations = { <lhs,rhs> | <lhs,rhs> <- m3Model@methodInvocation, lhs in testMethods, rhs in methodLocs};
	
	real totalCoverage = (0. | it + computeMethodCoverage(method, invocations, methodComplexityMap) | method <- testableMethods);	
	real fileCoverage = totalCoverage / size(testableMethods); 
	return getCoverageRisk(fileCoverage);}

private real computeMethodCoverage(MethodAnalysis method, rel[loc,loc] invocations, map[loc, int]  methodComplexityMap) {
	set[loc] invokedMethods = { <lhs,rhs> | <lhs,rhs> <- invocations+, lhs == method.location, rhs != method.location};
	int invokedComplexity = (0 | it + methodComplexityMap[invokedMethod] | invokedMethod <- invokedMethods); 
	
	int requiredNumberOfInvocations = method.cc + invokedComplexity - size(invokedMethods);
	int invocationCount = ( 0 | it + 1 | <_,rhs> <- invocations, rhs == method.location);
	real coverage = requiredNumberOfInvocations == 0 ? 0. : toReal(invocationCount) / requiredNumberOfInvocations;
	return min(coverage, 1.0);
}

private Risk getCoverageRisk(real coverage) {
	if (coverage <= .3) return veryHigh();
	if (coverage <= .6) return high();
	if (coverage <= .8) return moderate();	
	return low();
}

private bool isTestable(set[Modifier] modifiers) = \public() in modifiers || \protected() in modifiers;
