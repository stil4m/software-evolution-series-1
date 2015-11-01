module metrics::java::Duplications

 
import Domain;
import IO;
import List;
import DateTime;
import Map;

alias LineRefs = lrel[FileAnalysis, int];
alias LineDB = map[str,LineRefs];

data DupTree = Node(str key, LineRefs refs, list[DupTree] children, int knownDepth); 

private int DUPLICATION_LENGTH = 6;

public void computeDuplications(ProjectAnalysis p) {
	
	LineDB db = ();
	for(FileAnalysis f <- p) {
		<_, _, lines, _> = f;
		int index = 0;
		int max = size(lines) - (DUPLICATION_LENGTH - 1);
			
		for (<c,s> <- lines) {
			db = assocMap(db,s,<f,index>);
			index += 1;
			if (index == max) {
				break;
			}
		}
	}
	
	db = (k : db[k] | k <- db, size(db[k]) >= 2);
	int dbSize = size(db);
	int keyIndex = 0;
	map[str,int] depthDb = ();
	for ( k <- db) {
		keyIndex += 1;
		println("<printDateTime(now())> Analyze key <keyIndex>/<dbSize>");  
		int depth = analyzeKey(k, db, depthDb);
		depthDb[k] = depth;
	}
	
	depthDb = ( k : depthDb[k] | k <- depthDb, depthDb[k] >= DUPLICATION_LENGTH);
}

public int analyzeKey(str key, LineDB db, map[str,int] depthDb) {
	DupTree t = computeDupTree(key, db[key], db, depthDb);
	println("<printDateTime(now())> Duplicate Line: <key>");
	int depth = depthForTree(t);
	return depth;
}

public int depthForTree(DupTree t) {
	if ( Node(_,_,children, known) := t) {
		if (known == -1) {
			return 1 + max(0 + [depthForTree(s) | s <- children]);
		} else {
			return known;
		}
	} else {
		return 1;
	}	
}

public DupTree computeDupTree(str key, LineRefs refs, LineDB db, map[str,int] depthDb) {
	map[str,lrel[FileAnalysis,int]] x = ();
	
	if (depthDb[key]? && refs == db[key]) {
		return Node(key, refs, [], depthDb[key]);  
	}
	for (<f,c> <- withNextLine(refs)) {
		<_, _, lines, _> = f;
		<n,nextKey> = lines[c+1];
		x = assocMap(x,nextKey,<f,c+1>);
	}
	children = for (y <- x) {
		if (size(x[y]) > 1) {
			append computeDupTree(y, x[y], db, depthDb);
		}
	}
	return Node(key, refs, children, -1);
}

private map[&T,list[&S]] assocMap(map[&T,list[&S]] m, &T t, &S s) {
	if (m[t]?) {
		return m[t] += s;
	} else {
		m[t] = [s];
		return m;
	}
}

private LineRefs withNextLine(LineRefs refs) = [<f,i> | <f,i> <- refs, fileAnalysisHasLine(f, i+1)];

private bool fileAnalysisHasLine(FileAnalysis f, int ln) {
	<_, _, lines, _> = f;
	return ln < size(lines);
}