module metrics::java::LOC

import IO;
import List;
import lang::java::jdt::m3::Core;
import metrics::java::NoiseFilter;

public int calculateLOC(M3 v) {
	rel[loc,loc] containments = v@containment;
	set[loc] compilationUnits = {s | <s,_> <- containments, s.scheme == "java+compilationUnit"};
	return sum([relevantLines(s) | s <- compilationUnits]);
}

public int relevantLines(loc l) {
	return size(filterLines(readFileLines(l)));
}