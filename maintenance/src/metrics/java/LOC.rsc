module metrics::java::LOC

import IO;
import List;
import lang::java::jdt::m3::Core;
import metrics::java::NoiseFilter;
import String;

public void runLOC() {
	v = createM3FromEclipseProject(|project://smallsql0.21_src|);
	println("Number of lines: <calculateLOC(v)>");
}
public int calculateLOC(M3 v) {
	rel[loc,loc] containments = v@containment;
	set[loc] compilationUnits = {s | <s,_> <- containments, s.scheme == "java+compilationUnit"};
	return sum([relevantLines(s) | s <- compilationUnits]);
}

public int relevantLines(loc l) {
	list[str] lin = filterLines(readFileLines(l));
	int res = size(lin);
	return res;
}