module Maintenance

import lang::java::jdt::m3::Core;
import metrics::java::CyclomaticComplexity;
import metrics::java::UnitSize;
import metrics::java::LOC;
import metrics::Constants;
import Domain;
import List;
import Type;
import Set;
import IO;
import String;

public value main() {
	m3Model = createM3FromEclipseProject(|project://hello-world-java|);

	//model = createM3FromEclipseFile(|project://hello-world-java/src/nl/mse/complexity/Ternary.java|);	
	//iprintln(createM3FromEclipseFile(|project://hello-world-java/src/nl/mse/complexity/Ternary.java|));
	
	//iprintln(getMethodASTEclipse((head(toList(methods(model)))), model = model));
	
	//return 1;
	return analyseProject(m3Model);
}

public ProjectAnalysis analyseProject(M3 model) {
	set[loc] compilationUnits = { x| <x,_> <- model@containment, isCompilationUnit(x)};
	
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
		// TODO, figure out why we cant do it with the [].
		result += [ analyseClass(class, model)];
	}
	
	return <size(lines),result, lines, cu>;
}

public ClassAnalysis analyseClass(loc cl, M3 model) {
	list[MethodAnalysis] result = [];
	
	for(method <- methods(model,cl)) {
		result += analyseMethod(method, model);	
	}

	return result;
}

public MethodAnalysis analyseMethod(loc m, M3 model) {
	// TODO improve this.
	int unitSize = relevantLineCount(m);
	int complexity = calculateComplexityForMethod(m, model);

	return <unitSize, complexity,m>;
}