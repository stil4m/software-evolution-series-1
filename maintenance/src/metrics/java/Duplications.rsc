module metrics::java::Duplications

 
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
//alias Duplications = set[LineRefs];

data DupTree = Node(str key, LineRefs refs, list[DupTree] children, int knownDepth); 

private int DUPLICATION_LENGTH = 6;

public void computeDuplications(ProjectAnalysis p) {
	
	LineDB db = ();
	for(FileAnalysis f <- p) {
		<_, _, lines, _> = f;
		int index = 0;
		for (<c,s> <- lines) {
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
		println("<printDateTime(now())> Analyze key <keyIndex>/<dbSize>");  
		<depth, newDuplications> = analyzeKey(k, db, duplications);
		duplications = newDuplications;
	}
	for (d <- duplications) {
		println("Found duplication");
		for(<fs, ln> <- d) {
			<LOC,classes,lines,location> = fs;
			println("\>\> <ln> - <location.file> `<lines[ln]>` <size(lines)>");
			//iprintln(lines);
		}
		//iprintln(d);
		//return;
	}
}

public tuple[bool,set[LineRefs]] analyzeKey(str key, LineDB db, set[LineRefs] duplications) {
	<result, t> = computeDupTree(key, db[key], db, duplications, 1);
	if (result) {
		println("<printDateTime(now())> Duplicate Line: <key>");
	}
	return <result, t>;
}

public tuple[bool, set[LineRefs]] computeDupTree(str key, LineRefs refs, LineDB db, set[LineRefs] duplications, int currentDepth) {
	bool deepEnough = currentDepth >= DUPLICATION_LENGTH;
	
	//Just return if we know the answer
	if (refs in duplications) {
		return <true, duplications>;
	}
	
	map[str,LineRefs] x = ();
	for (<f,c> <- withNextLine(refs)) {
		<_, _, lines, _> = f;
		<n,nextKey> = lines[c+1];
		println("`<lines[c]>` -\> `<lines[c+1]>`");
		//println(refs);
		x = assocMap(x,nextKey,<f,c+1>);
	}
	
	set[LineRefs] childrenSets;
	childrenSets = for (y <- x, size(x[y]) > 1) {
		<subDeepEnough, duplications> = computeDupTree(y, x[y], db, duplications, currentDepth+1);
		if (subDeepEnough) {
			//append { <fs,n-1> | <fs,n> <- x[y]};
			append x[y];
		}
	}
	
	if (deepEnough) {
		duplications += {refs};
		return <true, duplications>;
	} else if (!isEmpty(childrenSets)) {
		set[LineRefs] chil = { c | c <- childrenSets};
		
		//LineRefs r = ;
		result = union(chil);
		println(size(result));
		if (size(result) == 4) {
		println("");
		println("");
		println("");
			iprintln(chil);
		println("");
		println("");
		println("");
			iprintln(result);
			println("");
			println("");
			println("");
		}
		duplications += chil; 
		return <size(childrenSets) != 0, duplications>;
	} else {
		return <false, duplications>;
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

private LineRefs withNextLine(LineRefs refs) = {<f,i> | <f,i> <- refs, fileAnalysisHasLine(f, i+1)};

private bool fileAnalysisHasLine(FileAnalysis f, int ln) {
	<_, _, lines, _> = f;
	return ln < size(lines);
}