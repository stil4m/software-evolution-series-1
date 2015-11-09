module profiling::UnitTestCoverage

import Domain;
import IO;
import util::Math;
import List;
import Set;

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import profiling::ProfilingUtil;

public Profile profileUnitTestCoverage(ProjectAnalysis project, M3 m3Model) {
	set[FileAnalysis] nonTestFiles = { file | file <- project.files, !file.containsTestClass};
	set[loc] testMethods = { method.location | file <- project.files, file.containsTestClass, class <- file.classes, method <- class.methods};
	
	RiskProfile riskProfile = ();
	for (FileAnalysis file <- nonTestFiles) {
		fileUnitSize = (0 | it + method.LOC | class <- file.classes, method <- class.methods);
	
		if (!isEmpty([ method | ClassAnalysis class <- file.classes, method <- class.methods, isTestable(method.location, m3Model)])) {
			Risk risk = calculateCoverageRisk(file, m3Model, testMethods);
			riskProfile[risk] ? 0 += fileUnitSize;
		}
	}
	
	int totalTestVOLUME = (0 | it + file.LOC | file <- project.files, file.containsTestClass);
	return convertToProfile(riskProfile, project.LOC - totalTestVolume);
}

private Risk calculateCoverageRisk(FileAnalysis file, M3 m3Model, set[loc] testMethods) {
	set[MethodAnalysis] methods = { method | class <- file.classes, method <- class.methods};
	set[loc] methodLocs = {method.location | method <- methods};
	rel[loc,loc] invocations = { <lhs,rhs> | <lhs,rhs> <- m3Model@methodInvocation, lhs in testMethods, rhs in methodLocs};
	map[loc, int] methodComplexityMap = (() | it + (method.location : method.cc) | method <- methods); 
	
	list[real] coverages = [];
	for(method <- methods, isTestable(method.location, m3Model)){
		//Exclude recursive call
		set[loc] invokedMethods = { <lhs,rhs> | <lhs,rhs> <- invocations+, lhs == method.location, rhs != method.location};
		int invokedComplexity = (0 | it + methodComplexityMap[invokedMethod] | invokedMethod <- invokedMethods); 
		
		int requiredNumberOfInvocations = method.cc + invokedComplexity - size(invokedMethods);
		int invocationCount = ( 0 | it + 1 | <lhs,rhs> <- invocations, rhs == method.location);
		real coverage = toReal(invocationCount) / requiredNumberOfInvocations;
		
		//Preven outliers 
		coverages += min(coverage, 1.0); 
	}
	
	real fileCoverage = sum(coverages) / size(coverages); 
	return getCoverageRisk(fileCoverage);}

private Risk getCoverageRisk(real coverage) {
	if (coverage <= .3) return veryHigh();
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
