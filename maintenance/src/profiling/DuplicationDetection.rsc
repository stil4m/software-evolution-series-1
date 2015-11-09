module profiling::DuplicationDetection


import Domain;
import IO;
import List;
import DateTime;
import Map;
import Set;
import Type;
import String;

alias LineRef = tuple[FileAnalysis, int];
alias LineRefs = set[LineRef];
alias LineDB = map[str,LineRefs];

data DupTree = Node(str key, LineRefs refs, list[DupTree] children, int knownDepth); 

private int DUPLICATION_LENGTH = 6;

public set[LineRefs] computeDuplications(ProjectAnalysis project) {
	LineDB db = buildDb(project);
	db = filterByOccurences(2, db);
	
	return ({} | analyzeKey(key, db, it)[1] | key <- db);
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
			db = assocMap(db,trim(effectiveLine.content),<file,index>);
			index += 1;
		}
	}
	return db;
}

private tuple[bool,set[LineRefs],LineRefs] analyzeKey(str key, LineDB db, set[LineRefs] duplications) 
	= computeDupTree(key, db[key], duplications, 1);

private tuple[bool, set[LineRefs], LineRefs] computeDupTree(str key, LineRefs refs, set[LineRefs] duplications, int currentDepth) {
	bool deepEnough = currentDepth >= DUPLICATION_LENGTH;
	
	//Just return if we know the answer
	if (refs in duplications) {
		return <true, duplications, refs>;
	}
	
	list[LineRefs] childrenSets;
	map[str,LineRefs] nextGroups = groupByNextEffectiveLine(refs);
	<childrenSets, duplications> = getDeepEnoughChildrenSets(nextGroups, duplications, currentDepth);
	
	if (deepEnough) {
		duplications += {refs};
		return <true, duplications, refs>;
	} else if (!isEmpty(childrenSets)) {
		children = toSet(childrenSets);
		duplications += children;
		return <size(childrenSets) != 0, duplications, union(children)>;
	} else {
		return <false, duplications, {}>;
	}
}

private tuple[list[LineRefs], set[LineRefs]] getDeepEnoughChildrenSets(map[str,LineRefs] nextGroups,set[LineRefs] duplications,  int currentDepth) {
 	childrenSets = for (y <- nextGroups, size(nextGroups[y]) > 1) {
		<subDeepEnough, duplications, subChildren> = computeDupTree(y, nextGroups[y], duplications, currentDepth+1);
		if (subDeepEnough) {
			append {<f,ln-1> | <f,ln> <- subChildren};
		}
	}
	return <childrenSets, duplications>;
}
private map[str,LineRefs] groupByNextEffectiveLine(LineRefs refs) =
	( () | assocMap(it, trim(f.lines[c+1].content), <f,c+1>) | <f,c> <- refs, hasNextLine(f,c));
	
private map[&T,set[&S]] assocMap(map[&T,set[&S]] m, &T t, &S s) {
	if (m[t]?) {
		return m[t] += s;
	} else {
		m[t] = {s};
		return m;
	}
}

private bool hasNextLine(FileAnalysis f, int ln) = ln + 1 < size(f.lines);
