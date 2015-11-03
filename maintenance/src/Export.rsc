module Export


import Domain;
import IO;
import lang::json::IO;
import List;

public void exportToFile(ProjectAnalysis p, map[str,Profile] profile, loc l) {
	value json = (
		"project" : projectAsMap(p),
		"profile" : (k : profileToInt(profile[k]) | k <- profile)
	);
	iprintln(json);
	writeFile(l, toJSON(json, true));
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
	return (
		"location" : "<f.location.path>",
		"lineCount" : "<f.LOC>",
		"classes" : [classAsMap(c) | c <- f.classes]
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
	return (
		"size" : methodAnalysis.LOC,
		"complexity" : methodAnalysis.cc,
		"location" : methodAnalysis.location.path
	);
}