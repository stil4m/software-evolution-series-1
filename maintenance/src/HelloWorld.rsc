module HelloWorld


import IO;

import lang::java::jdt::m3::Core;

public value foo() {
	v =  createM3FromEclipseProject(|project://hello-world-java|);
	rel[loc,loc] containments = v@containment;
	return v;
}


