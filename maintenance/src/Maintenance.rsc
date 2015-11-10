module Maintenance

import DateTime;
import IO;
import List;
import Set;
import String;
import Set;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import metrics::java::Complexity;
import metrics::java::LOC;
import profiling::Profiler;
import Domain;
import Export;

public loc exportPath = |project://maintenance/export.json|;

//public loc projectLoc = |project://smallsql0.21_src|;
public loc projectLoc = |project://hsqldb|;
//public loc projectLoc = |project://hello-world-java|;

public value mainFunction() {
	datetime modelStart = now();
	println("<printDateTime(modelStart)> Obtaining M3 Model");
	
	m3Model = createM3FromEclipseProject(projectLoc);
	
	Duration d = now() - modelStart; 
	println("Creating m3 took <d.minutes> minutes, <d.seconds> seconds, <d.milliseconds> milliseconds");
	
	sonar(m3Model);
	return "OK";
}

public void sonar(M3 m3Model) {
	datetime analysisStart = now();
	println("<printDateTime(analysisStart)> Start analysis");
	ProjectAnalysis p = analyseProject(m3Model);
	
	println("<printDateTime(now())> Start Profiling");
	map[str,Profile] projectProfile = profile(p, m3Model);
	
	datetime analysisEnd = now();
	Duration d = analysisEnd - analysisStart; 
	println("Analysis and profiling took <d.minutes> minutes, <d.seconds> seconds, <d.milliseconds> milliseconds");
	
	println("<printDateTime(now())> Export to file");
	
	exportToFile(p, projectProfile, exportPath, (
		"start" : analysisStart,
		"end": analysisEnd
	), projectLoc);
	
	println("<printDateTime(now())> Done");
	
}

public ProjectAnalysis analyseProject(M3 model) {
	set[loc] compilationUnits = { x| <x,_> <- model@containment, isCompilationUnit(x)};
	// Detect JUnit3 test classes 
	set[loc] allTestClasses = {x | <x,y> <- toList(model@extends)+, /TestCase/ := y.file};
	
	list[FileAnalysis] files = [analyseFile(c, model, allTestClasses) | c <- compilationUnits];
	
	int totalLoc = (0 | it + file.LOC | file <- files);
	return projectAnalysis(totalLoc, files);
}

public FileAnalysis analyseFile(loc cu, M3 model, set[loc] allTestClasses) {
	list[EffectiveLine] lines = relevantLines(cu);

	Declaration declaration = createAstFromFile(cu, false, javaVersion="1.7");
	
	set[loc] classes = {x | <cu1, x> <- model@containment, cu1 == cu, isClass(x)};
	list[ClassAnalysis] classAnalysisses = [*analyseClass(class, model, false, allTestClasses, declaration) | class <- classes];
	
	bool containsTestClass = any(ClassAnalysis cl <- classAnalysisses , cl.location in allTestClasses);	
	return fileAnalysis(size(lines), classAnalysisses, lines, containsTestClass, cu);
}

public list[ClassAnalysis] analyseClass(loc cl, M3 model, bool inner, set[loc] allTestClasses, Declaration declaration) {
	bool isTestClass = cl in allTestClasses;
	
	set[loc] classMethods = methods(model,cl);
	map[loc,int] complexityPerMethod = methodComplexity(classMethods, model, declaration);
	
	list[MethodAnalysis] methods = [analyseMethod(method, model, isTestClass, complexityPerMethod[method]? 0) | method <- classMethods];
	list[ClassAnalysis] result = [classAnalysis(methods, inner, cl)];
	
	return result + [*analyseClass(nestedClass, model, true, allTestClasses, declaration) | nestedClass <- nestedClasses(model,cl)];
}

public MethodAnalysis analyseMethod(loc m, M3 model, bool inTestClass, int complexity) =
		methodAnalysis(relevantLineCount(m), complexity, inTestClass && isTestMethod(m), m);

//In JUnit3 methods should Start with "test"
private bool isTestMethod(loc m) = startsWith(m.file, "test");
