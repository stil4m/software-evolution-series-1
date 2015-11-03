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

public set[LineRefs] computeDuplications(ProjectAnalysis project) {
	LineDB db = buildDb(project);
	db = filterByOccurences(2, db);
	set[LineRefs] duplications = {};
	
	for ( key <- db) {
		<depth, newDuplications, _> = analyzeKey(key, db, duplications);
		duplications = newDuplications;
	}
	return duplications;
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

private LineDB filterByOccurences(int occurences, LineDB db) = (key : db[key] | key <- db, size(db[key]) >= occurences);

private LineDB buildDb(ProjectAnalysis project) {
	LineDB db = ();
	for(file <- project.files) {
		int index = 0;
		for (effectiveLine <- file.lines) {
			db = assocMap(db,effectiveLine.content,<file,index>);
			index += 1;
		}
	}
	return db;
}

private tuple[bool,set[LineRefs],LineRefs] analyzeKey(str key, LineDB db, set[LineRefs] duplications) {
	return computeDupTree(key, db[key], duplications, 1);
}

private tuple[bool, set[LineRefs], LineRefs] computeDupTree(str key, LineRefs refs, set[LineRefs] duplications, int currentDepth) {
	bool deepEnough = currentDepth >= DUPLICATION_LENGTH;
	
	//Just return if we know the answer
	if (refs in duplications) {
		return <true, duplications, refs>;
	}
	
	map[str,LineRefs] x = ();
	for (<f,c> <- withNextLine(refs)) {
		EffectiveLine line = f.lines[c+1];
		x = assocMap(x,line.content,<f,c+1>);
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
