module TestExtractor

import IO;
import String;
import Type;
import List;
import Set;
import Domain;
import util::Maybe;

import lang::java::jdt::m3::Core;

// The extraction is based on JUnit3
public ProjectAnalysis extractTest(ProjectAnalysis project, M3 model) {
	
	// All testClasses should extend a class called TestCase (JUnit3);
	set[loc] allTestClasses = {x | <x,y> <- toList(model@extends)+, /TestCase/ := y.file};
	println("TestClasses:");  
	iprintln(allTestClasses);
	
	list[FileAnalysis] fileAnalysis= [ x | file <- project.files, just(x) := convertFileAnalysis(file, model, allTestClasses)];
	
	//Recalculate LOC to testLOC
	int totalLOC = (0 | it + file.LOC | file <- fileAnalysis);
	
	iprintln(project.LOC);
	iprintln(totalLOC);
	
	return projectAnalysis(totalLOC, fileAnalysis);
} 

public Maybe[FileAnalysis] convertFileAnalysis(FileAnalysis file, M3 model, set[loc] allTestClasses) {
	// Test classes in this file: 
	list[ClassAnalysis] testClasses = [convertClassAnalysis(class) | ClassAnalysis class <- file.classes, class.location in allTestClasses];
	
	if(isEmpty(testClasses)) {
		return nothing();
	}
	
	return just(fileAnalysis(file.LOC, testClasses, file.lines, file.location));
} 

public ClassAnalysis convertClassAnalysis(ClassAnalysis class) {
	list[MethodAnalysis] testMethods = [method | method <- class.methods, isTestMethod(method)];
	
	return classAnalysis(testMethods, class.inner, class.location);
}

//In JUnit3 methods should Start with "test"
public bool isTestMethod(MethodAnalysis method) = startsWith(method.location.file, "test");