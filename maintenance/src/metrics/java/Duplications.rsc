module metrics::java::Duplications

 
import Domain;
import IO;
import List;

alias LineRefs = lrel[FileAnalysis, int];
alias LineDB = map[str,LineRefs];

data DupTree = Node(str key, LineRefs refs, list[DupTree] children); 

public void computeDuplications(ProjectAnalysis p) {
	
	LineDB db = ();
	
	for(FileAnalysis f <- p) {
		<_, _, lines, _> = f;
		int index = 0;	
		for (<c,s> <- lines) {
			if (db[s]?) {
				db[s] += <f, index>;
			} else {
				db[s] = [<f, index>];
			}
			index += 1;
		}
	}
	
	for ( k <- db) {
		analyzeKey(k, db);
	}
}

public void analyzeKey(str key, LineDB db) {
	DupTree t = computeDupTree(key, db[key]);
	println("Key: <key>");
	println("  Depth <depthForTree(t)>");
}

public int depthForTree(DupTree t) {
	if ( Node(_,_,children) := t) {
		return 1 + max(0 + [depthForTree(s) | s <- children]);
	} else {
		return 1;
	}	
}

public DupTree computeDupTree(str key, LineRefs refs) {
	map[str,lrel[FileAnalysis,int]] x = ();
	
	for (<f,c> <- withNextLine(refs)) {
		<_, _, lines, _> = f;
		<n,nextKey> = lines[c+1];
		if (x[nextKey]?) {
			x[nextKey] += <f,c+1>;
		} else {
			x[nextKey] = [<f,c+1>];
		}
	}
	children = for (y <- x) {
		if (size(x[y]) > 1) {
			append computeDupTree(y, x[y]);
		}
	}
	return Node(key, refs, children);
}

private LineRefs withNextLine(LineRefs refs) = [<f,i> | <f,i> <- refs, fileAnalysisHasLine(f, i+1)];

private bool fileAnalysisHasLine(FileAnalysis f, int ln) {
	<_, _, lines, _> = f;
	return ln < size(lines);
}