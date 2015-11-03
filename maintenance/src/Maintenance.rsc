module Maintenance

import lang::java::jdt::m3::Core;
import metrics::java::CyclomaticComplexity;
import metrics::java::LOC;
import Domain;
import Export;
import profiling::Profiler;

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
	m3Model = createM3FromEclipseProject(|project://hsqldb|);
	//m3Model = createM3FromEclipseProject(|project://hello-world-java|);
	doAnalysis(m3Model);
	return "OK";
}

public void doAnalysis(M3 m3Model) {
	println("<printDateTime(now())> Start analysis");
	ProjectAnalysis p = analyseProject(m3Model);
	
	println("<printDateTime(now())> Start Profiling");
	map[str,Profile] projectProfile = profile(p);
	
	println("<printDateTime(now())> Export to file");
	
	exportToFile(p, projectProfile, exportPath);
	println("<printDateTime(now())> Done");
}

public ProjectAnalysis analyseProject(M3 model) {
	set[loc] compilationUnits = { x| <x,_> <- model@containment, isCompilationUnit(x)
		//, /src\/org\/hsqldb\/[A-Z]/ := x.path //Will decrease the unit size to around 20%
	};
	println("<printDateTime(now())> Compilation unit size: <size(compilationUnits)>");
	list[FileAnalysis] files = [analyseFile(c, model) | c <- compilationUnits];
	int totalLoc = (0 | it + file.LOC | file <- files);
	return projectAnalysis(totalLoc, files);
}

public FileAnalysis analyseFile(loc cu, M3 model) {
	lrel[int,str] lines = [<c,trim(s)> | <c,s> <- relevantLines(cu)];
	
	set[loc] classes = {x | <cu1, x> <- model@containment, cu1 == cu, isClass(x)};
	list[ClassAnalysis] classAnalysisses = [*analyseClass(class, model, false) | class <- classes];
	
	return fileAnalysis(size(lines), classAnalysisses, lines, cu);
}

public list[ClassAnalysis] analyseClass(loc cl, M3 model, bool inner) {
	list[MethodAnalysis] methods = [analyseMethod(method, model) | method <- methods(model,cl)];
	
	list[ClassAnalysis] result = [classAnalysis(methods, inner, cl)];
	result += [*analyseClass(nestedClass, model, true) | nestedClass <- nestedClasses(model,cl)];
	
	return result;
}

public MethodAnalysis analyseMethod(loc m, M3 model) = methodAnalysis(
	relevantLineCount(m), // TODO improve this. 
	calculateComplexityForMethod(m, model), 
	m
);