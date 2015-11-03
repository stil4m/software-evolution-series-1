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
	writeFile(l, toJSON(json, true));
}

private map[str,value] profileToInt(plusPlus(d)) = profileValue(5,d);
private map[str,value] profileToInt(plus(d)) = profileValue(4,d);
private map[str,value] profileToInt(neutral(d)) = profileValue(3,d);
private map[str,value] profileToInt(minus(d)) = profileValue(2,d);
private map[str,value] profileToInt(minusMinus(d)) = profileValue(1,d);

private map[str,value] profileValue(int risk, ProfileData d) {
	d["rating"] = risk;
	return d;
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