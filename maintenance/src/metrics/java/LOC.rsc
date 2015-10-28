module metrics::java::LOC

import IO;
import List;
import lang::java::jdt::m3::Core;
import metrics::java::NoiseFilter;
import String;

//1) This file is not included in the createM3...:
// ./integration/extAuthWithSpring/src/org/hsqldb/sample/SpringExtAuth.java
// This is why the LOC will be 102 lines less than sloccount.

//2) Sloccount has a bug that it will yield a lower line count when analyzing the root folder
//   instead of the src/org folder. When sloccount is executed with `.` it yields `164950`. for the src/org folder
//   When it is executed with `src/org` it yields `168212`
 
public void runLOC() {
	v = createM3FromEclipseProject(|project://hsqldb|);
	println("Number of lines: <calculateLOC(v)>");
}

public int calculateLOC(M3 v) {
	rel[loc,loc] containments = v@containment;
	set[loc] compilationUnits = {s | <s,_> <- containments, s.scheme == "java+compilationUnit"};
	
	lrel[int,loc] result = sort([<relevantLines(s), s> | s <- compilationUnits]);
	return sum([0] + [s | <s,l> <- result]);
}



public int relevantLines(loc l) {
	list[str] lin = filterLines(readFileLines(l));
	int res = size(lin);
	return res;
}