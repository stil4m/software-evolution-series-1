module metrics::java::UnitComplexity

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import IO;
import List;

public void computeUnitComplexity(v) {
	rel[loc,loc] containments = v@containment;
	
	set[loc] methods = {s | <s,_> <- containments, s.scheme == "java+method"} +
		{s | <_,s> <- containments, s.scheme == "java+method"};
		
	for(m <- methods) {
		//decl = iprintln(getMethodASTEclipse(m, model=v));
		iprintln(size(readFileLines(m)));
		//visit (decl) {
			//case block:
				//vis
		//} 
		//return;
	}
	//println(methods);
}
