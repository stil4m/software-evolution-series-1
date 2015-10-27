module metrics::java::LOC

import IO;
import List;
import lang::java::jdt::m3::Core;

public int calculateLOC(M3 v) {
	rel[loc,loc] containments = v@containment;
	
	set[loc] compilationUnits = {s | <s,_> <- containments, s.scheme == "java+compilationUnit"};
	
	return sum([size(readFileLines(s)) | s <- compilationUnits]);
}