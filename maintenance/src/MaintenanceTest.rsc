module MaintenanceTest

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import Set;
import List;
import String;
import IO;
import metrics::java::LOC;
import metrics::java::UnitSize;
import metrics::java::CyclomaticComplexity;
import metrics::Constants;

public M3 v = createM3FromEclipseProject(|project://hello-world-java|);

public loc getCompilationUnit(str name) = head(toList({s | <s,_> <- v@containment, s.scheme == "java+compilationUnit", s.file == name}));

public loc getMethod(str className, str methodName) {
	set[loc] methods = {*methods(v,s) | s <- classes(v), s.scheme == "java+class", s.file==className};
	
	for (method <- methods) {
		if (startsWith(method.file,methodName)) {
			return method;		
		}
	}
}

public int getRelevantLines(str name) = relevantLineCount(getCompilationUnit(name));

test bool testFileLineCount1() = getRelevantLines("CommentSameLine.java") == 6;
test bool testFileLineCount2() = getRelevantLines("ControlLoop.java") == 10;
test bool testFileLineCount3() = getRelevantLines("ControlLoopWithComment.java") == 10;
test bool testFileLineCount4() = getRelevantLines("Empty.java") == 3;
test bool testFileLineCount5() = getRelevantLines("EmptyWithComment.java") == 3;
test bool testFileLineCount6() = getRelevantLines("MethodComment.java") == 6;
test bool testFileLineCount7() = getRelevantLines("Robot.java") == 9;
test bool testFileLineCount8() = getRelevantLines("SimplePojo.java") == 5;
test bool testFileLineCount9() = getRelevantLines("WithMethod.java") == 6;
test bool testFileLineCount10() = getRelevantLines("A4.java") == 9;


public int getCyclomaticComplexity(str className, str methodName) = calculateComplexityForMethod(getMethod(className,methodName),v);

test bool testCyclometicComplexity1() = getCyclomaticComplexity("DoWhileStatement", "doSomething") == 2;
test bool testCyclometicComplexity2() = getCyclomaticComplexity("Ternary", "ternaryFoo") == 2 ;

