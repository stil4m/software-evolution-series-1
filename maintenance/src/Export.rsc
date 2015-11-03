module Export


import Domain;
import IO;
import lang::json::IO;
import List;

public void exportToFile(ProjectAnalysis p, loc l) {
	writeFile(l, toJSON(projectAsMap(p), true));
}

public map[str,value] projectAsMap(ProjectAnalysis p) {
	return (
		"files" : [fileAsMap(f) | f <- p.files]
	);
}

private map[str,value] fileAsMap(FileAnalysis f) {
	<lineCount, classAnalysisses, lines, location> = f;
	return (
		"location" : "<location.path>",
		"lineCount" : "<lineCount>",
		"classes" : [classAsMap(c) | c<- classAnalysisses]
	);
}

private value classAsMap(ClassAnalysis classAnalysis) {
	return (
		"methodCount" : size(classAnalysis.methods),
		"inner" : classAnalysis.inner,
		"methods" : [methodAsMap(m) | m <- classAnalysis.methods]
	);
}

private value methodAsMap(MethodAnalysis methodAnalysis) {
	<methodSize,cc,location> = methodAnalysis;
	return (
		"size" : methodSize,
		"complexity" : cc,
		"location" : location.file
	);
}