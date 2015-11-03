module Maintenance

import lang::java::jdt::m3::Core;
import metrics::java::CyclomaticComplexity;
import metrics::java::UnitSize;
import metrics::java::Duplications;
import metrics::java::LOC;
import metrics::Constants;
import Domain;
import Export;

import List;
import Type;
import Set;
import IO;
import String;
import DateTime;

public loc exportPath = |project://maintenance/export.json|;

public value mainFunction() {
	println("<printDateTime(now())> Obtain M3 Model");
	//m3Model = createM3FromEclipseProject(|project://smallsql0.21_src|);
	//m3Model = createM3FromEclipseProject(|project://hsqldb|);
	m3Model = createM3FromEclipseProject(|project://hello-world-java|);
	doAnalysis(m3Model);
	return "OK";
}

public int getTotalLoc(ProjectAnalysis p) {
	int totalLOC = 0;
	for(fileAnalysis <- p) {
		totalLOC += fileAnalysis[0];	
	}
	return totalLOC;
}

public void doAnalysis(M3 m3Model) {
	println("<printDateTime(now())> Start analysis");
	ProjectAnalysis p =  analyseProject(m3Model);
	
	println("<printDateTime(now())> Did analysis. Find some duplications!!!");
	
	set[LineRefs] duplications = computeDuplications(p);
	println("Duplication size: <size(duplications)>");
	
	iprintln(aggregateDuplications(duplications));
}

public ProjectAnalysis analyseProject(M3 model) {
	set[loc] compilationUnits = { x| <x,_> <- model@containment, isCompilationUnit(x)
		//, /src\/org\/hsqldb\/[A-Z]/ := x.path //Will decrease the unit size to around 20%
	};
	println("<printDateTime(now())> Compilation unit size: <size(compilationUnits)>");
	list[FileAnalysis] files = [analyseFile(c, model) | c <- compilationUnits];
	int totalLoc = (0 | it + file.LOC | file <- files);
	return <totalLoc, files>;
}

public FileAnalysis analyseFile(loc cu, M3 model) {
	lrel[int,str] lines = [ <c,trim(s)> | <c,s> <- relevantLines(cu)];
	
	set[loc] classes = {x | <cu1, x> <- model@containment, cu1 == cu, isClass(x)};
	list[ClassAnalysis] classAnalysisses = [*analyseClass(class, model, false) | class <- classes];
	
	return <size(lines), classAnalysisses, lines, cu>;
}

public list[ClassAnalysis] analyseClass(loc cl, M3 model, bool inner) {
	list[MethodAnalysis] methods = [analyseMethod(method, model) | method <- methods(model,cl)];
	
	list[ClassAnalysis] result = [<methods, inner, cl>];
	result += [*analyseClass(nestedClass, model, true) | nestedClass <- nestedClasses(model,cl)];
	
	return result;
}

public MethodAnalysis analyseMethod(loc m, M3 model) = <
	relevantLineCount(m), // TODO improve this. 
	calculateComplexityForMethod(m, model), 
	m
>;