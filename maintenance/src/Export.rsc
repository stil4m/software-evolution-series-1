module Export


import Domain;
import IO;
import lang::json::IO;
import List;

public void exportToFile(ProjectAnalysis p, map[str,Profile] profile, loc l) {
	writeFile(l, toJSON((
		"project" : projectAsMap(p),
		"profile" : (k : profileToInt(profile[k]) | k <- profile)
	), true));
}

public int profileToInt(Profile p) {
	if (p == plusPlus()) return 5;
	if (p == plus()) return 4;
	if (p == neutral()) return 3;
	if (p == minus()) return 2;
	return 1;
}
public map[str,value] projectAsMap(ProjectAnalysis p) {
	return (
		"loc" : p.LOC,
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