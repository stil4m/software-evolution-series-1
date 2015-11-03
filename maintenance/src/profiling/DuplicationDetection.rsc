module profiling::DuplicationDetection


import Domain;
import IO;
import List;
import DateTime;
import Map;
import Set;
import Type;

alias LineRef = tuple[FileAnalysis, int];
alias LineRefs = set[LineRef];
alias LineDB = map[str,LineRefs];

data DupTree = Node(str key, LineRefs refs, list[DupTree] children, int knownDepth); 

private int DUPLICATION_LENGTH = 6;

public set[LineRefs] computeDuplications(ProjectAnalysis p) {
	
	LineDB db = ();
	for(FileAnalysis f <- p.files) {
		int index = 0;
		for (<c,s> <- f.lines) {
			db = assocMap(db,s,<f,index>);
			index += 1;
		}
	}
	
	db = (k : db[k] | k <- db, size(db[k]) >= 2);
	int dbSize = size(db);
	int keyIndex = 0;
	set[LineRefs] duplications = {};
	for ( k <- db) {
		keyIndex += 1;
		<depth, newDuplications, _> = analyzeKey(k, db, duplications);
		duplications = newDuplications;
	}
	return duplications;
}

public tuple[bool,set[LineRefs],LineRefs] analyzeKey(str key, LineDB db, set[LineRefs] duplications) {
	return computeDupTree(key, db[key], duplications, 1);
}

public tuple[bool, set[LineRefs], LineRefs] computeDupTree(str key, LineRefs refs, set[LineRefs] duplications, int currentDepth) {
	bool deepEnough = currentDepth >= DUPLICATION_LENGTH;
	
	//Just return if we know the answer
	if (refs in duplications) {
		return <true, duplications, refs>;
	}
	
	map[str,LineRefs] x = ();
	for (<f,c> <- withNextLine(refs)) {
		<n,nextKey> = f.lines[c+1];
		x = assocMap(x,nextKey,<f,c+1>);
	}
	
	set[LineRefs] childrenSets;
	childrenSets = for (y <- x, size(x[y]) > 1) {
		<subDeepEnough, newDuplications, subChildren> = computeDupTree(y, x[y], duplications, currentDepth+1);
		duplications = newDuplications;
		if (subDeepEnough) {
			append {<f,ln-1> | <f,ln> <- subChildren};
		}
	}
	
	if (deepEnough) {
		duplications += {refs};
		return <true, duplications, refs>;
	} else if (!isEmpty(childrenSets)) {
		children = { c | c <- childrenSets};
		duplications += children;
		return <size(childrenSets) != 0, duplications, union(children)>;
	} else {
		return <false, duplications, {}>;
	}
}

private map[&T,set[&S]] assocMap(map[&T,set[&S]] m, &T t, &S s) {
	if (m[t]?) {
		return m[t] += s;
	} else {
		m[t] = {s};
		return m;
	}
}

private set[str] infoLineRefs(LineRefs l) {
	return {"(<ln> - <location.file>)" | <<_,_,_,location>,ln> <- l};
}
private LineRefs withNextLine(LineRefs refs) = {<f,i> | <f,i> <- refs, fileAnalysisHasLine(f, i+1)};

private bool fileAnalysisHasLine(FileAnalysis f, int ln) {
	return ln < size(f.lines);
}

public FileAnalysis fileAnalysis1 = fileAnalysis(6, [], [
	<1, "A1">,
	<2, "A2">,
	<3, "A3">,
	<4, "A4">,
	<5, "A5">,
	<6, "A6">
], |file://foo1|);

public FileAnalysis fileAnalysis2 = fileAnalysis(9,[], [
	<1, "A1">,
	<2, "A2">,
	<3, "A3">,
	<4, "A4">,
	<5, "A5">,
	<6, "A6">
], |file://foo2|);

public FileAnalysis fileAnalysis3 = fileAnalysis(5,[], [
	<1, "A1">,
	<2, "A2">,
	<3, "B3">,
	<4, "B4">,
	<5, "B5">
], |file://foo3|);

public FileAnalysis fileAnalysis4 = fileAnalysis(5,[], [
	<1, "A1">,
	<2, "A2">,
	<3, "B3">,
	<4, "B4">,
	<5, "B5">
], |file://foo4|);

test bool testDuplicationCalculation() {
	output = computeDuplications([fileAnalysis1,fileAnalysis2,fileAnalysis3,fileAnalysis4]);
	return aggregateDuplications(output) == (
	  |file://foo1|:[0,1,2,3,4,5],
	  |file://foo2|:[0,1,2,3,4,5]
	);
}

public map[FileAnalysis,list[int]] aggregateDuplications(set[LineRefs] duplications) {
	LineRefs s = union(duplications);
	map[FileAnalysis,set[int]] aggregate = ();
	for (<fileAnalysis, ln> <- s) {
		if (aggregate[fileAnalysis]?) {
			aggregate[fileAnalysis] += ln;
		} else {
			aggregate[fileAnalysis] = {ln};
		}
	}
	return ( k: sort(toList(aggregate[k])) | k <- aggregate );
}
