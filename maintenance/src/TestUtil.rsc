module TestUtil

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import Set;
import List;
import String;
import IO;

public M3 v = createM3FromEclipseProject(|project://hello-world-java|);

public loc getCompilationUnit(str name) = head(toList({s | <s,_> <- v@containment, s.scheme == "java+compilationUnit", s.file == name}));

public loc getClass(str className) = head(toList({s | s <- classes(v), s.scheme == "java+class", s.file==className}));

public loc getMethod(str className, str methodName) {
	set[loc] methods = {*methods(v,s) | s <- classes(v), s.scheme == "java+class", s.file==className};
	return head([method | method <- methods, startsWith(method.file,methodName)]);
}