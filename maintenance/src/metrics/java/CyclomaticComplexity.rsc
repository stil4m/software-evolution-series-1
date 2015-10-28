module metrics::java::CyclomaticComplexity

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import List;
import Set;
import IO;
import Type;
import String;
import Node;

public void calculateCyclomaticComplexity(M3 v) {
	set[loc] cs = classes(v);
	
	for(c <- cs) {
		if(endsWith(c.path, "ControlLoopWithComment")) {
			println(c.path);
			ms = methods(v, c);
			for(m <- ms) {
				Declaration t = getMethodASTEclipse(m, model=v);
				println("  <m.file>");
			}
		}
	}
}