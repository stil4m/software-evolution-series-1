module Maintenance

import lang::java::jdt::m3::Core;
import metrics::java::CyclomaticComplexity;
import metrics::java::UnitSize;
import metrics::java::Duplications;
import metrics::java::LOC;
import metrics::Constants;
import Domain;
import List;
import Type;
import Set;
import IO;
import String;
import DateTime;

public value mainFunction() {
	//m3Model = createM3FromEclipseProject(|project://smallsql0.21_src|);
	//m3Model = createM3FromEclipseProject(|project://hsqldb|);
	m3Model = createM3FromEclipseProject(|project://hello-world-java|);
	doAnalysis(m3Model);
	return "OK";
}

public void doAnalysis(M3 m3Model) {
	println("<printDateTime(now())> Start analysis");
	ProjectAnalysis p =  analyseProject(m3Model);
	
	println("<printDateTime(now())> Did analysis. Find some duplications!!!");
	//iprintln(p);
	computeDuplications(p);
}

public ProjectAnalysis analyseProject(M3 model) {
	set[loc] compilationUnits = { x| <x,_> <- model@containment, isCompilationUnit(x)
		//, /src\/org\/hsqldb\/[A-Z]/ := x.path //Will decrease the unit size to around 20%
	};
	println("<printDateTime(now())> Compilation unit size: <size(compilationUnits)>");
	ProjectAnalysis p = [];
	
	result = for(c <- compilationUnits) {
		//append analyseFile(c, model);
		p+= analyseFile(c, model);
	}
	
	return p;
}

public FileAnalysis analyseFile(loc cu, M3 model) {
	lrel[int,str] lines = [ <c,trim(s)> | <c,s> <- relevantLines(cu)];
	set[loc] classes = {x | <cu1, x> <- model@containment, cu1 == cu, isClass(x)};

	list[ClassAnalysis] result = [];
	
	for(class <- classes) {
		// TODO, figure out why we cant do it without the [].
		result += [ analyseClass(class, model)];
	}
	
	return <size(lines),result, lines, cu>;
}

public ClassAnalysis analyseClass(loc cl, M3 model) {
	list[MethodAnalysis] result = [];
	
	for(method <- methods(model,cl)) {
		result += analyseMethod(method, model);	
	}
	
	for(subcl <- nestedClasses(model, cl)) {
		result += analyseClass(subcl,model);
	}
	
	return result;
}

public MethodAnalysis analyseMethod(loc m, M3 model) {
	// TODO improve this.
	int unitSize = relevantLineCount(m);
	int complexity = calculateComplexityForMethod(m, model);

	return <unitSize, complexity,m>;
}