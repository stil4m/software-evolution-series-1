module Maintenance

import DateTime;
import IO;
import List;
import Set;
import String;

import lang::java::jdt::m3::Core;

import metrics::java::TestQuality;
import metrics::java::TestMethods;
import metrics::java::Complexity;
import metrics::java::LOC;
import profiling::Profiler;
import Domain;
import Export;

public loc exportPath = |project://maintenance/export.json|;

public value mainFunction() {
	datetime modelStart = now();
	println("<printDateTime(modelStart)> Obtaining M3 Model");
	
	//m3Model = createM3FromEclipseProject(|project://smallsql0.21_src|);
	//m3Model = createM3FromEclipseProject(|project://hsqldb|);
	m3Model = createM3FromEclipseProject(|project://hello-world-java|);
	
	Duration d = now() - modelStart; 
	println("Creating m3 took <d.minutes> minutes, <d.seconds> seconds, <d.milliseconds> milliseconds");
	
	sonar(m3Model);
	return "OK";
}

public void sonar(M3 m3Model) {
	datetime analysisStart = now();
	println("<printDateTime(analysisStart)> Start analysis");
	ProjectAnalysis p = analyseProject(m3Model);
	
	convertProject(p,m3Model);
	
	println("<printDateTime(now())> Start Profiling");
	map[str,Profile] projectProfile = profile(p);
	
	datetime analysisEnd = now();
	Duration d = analysisEnd - analysisStart; 
	println("Analysis and profiling took <d.minutes> minutes, <d.seconds> seconds, <d.milliseconds> milliseconds");
	
	println("<printDateTime(now())> Export to file");
	
	exportToFile(p, projectProfile, exportPath, (
		"start" : analysisStart,
		"end": analysisEnd
	));
	println("<printDateTime(now())> Done");
	
	for(f <- p.files) {
		println(qualityOfFile(f));
	}
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
	list[EffectiveLine] lines = [effectiveLine(l.number, trim(l.content)) | l <- relevantLines(cu)];
	
	set[loc] classes = {x | <cu1, x> <- model@containment, cu1 == cu, isClass(x)};
	list[ClassAnalysis] classAnalysisses = [*analyseClass(class, model, false, allTestClasses) | class <- classes];
	
	bool containsTestClass = any(ClassAnalysis cl <- classAnalysisses , cl.location in allTestClasses);	
	return fileAnalysis(size(lines), classAnalysisses, lines, containsTestClass, cu);
}

public list[ClassAnalysis] analyseClass(loc cl, M3 model, bool inner, set[loc] allTestClasses) {
	bool isTestClass = cl in allTestClasses;
	list[MethodAnalysis] methods = [analyseMethod(method, model, isTestClass) | method <- methods(model,cl)];
	list[ClassAnalysis] result = [classAnalysis(methods, inner, cl)];
	
	return result + [*analyseClass(nestedClass, model, true, allTestClasses) | nestedClass <- nestedClasses(model,cl)];
}

public MethodAnalysis analyseMethod(loc m, M3 model, bool inTestClass) = methodAnalysis(relevantLineCount(m), methodComplexity(m, model), inTestClass && isTestMethod(m), m);

//In JUnit3 methods should Start with "test"
private bool isTestMethod(loc m) = startsWith(m.file, "test");
