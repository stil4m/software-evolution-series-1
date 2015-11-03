module MaintenanceTest

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import Set;
import List;
import String;
import IO;
import metrics::java::LOC;
import metrics::java::CyclomaticComplexity;
import Maintenance;
import Domain;

public M3 v = createM3FromEclipseProject(|project://hello-world-java|);

public loc getCompilationUnit(str name) = head(toList({s | <s,_> <- v@containment, s.scheme == "java+compilationUnit", s.file == name}));

public loc getClass(str className) = head(toList({s | s <- classes(v), s.scheme == "java+class", s.file==className}));

public loc getMethod(str className, str methodName) {
	set[loc] methods = {*methods(v,s) | s <- classes(v), s.scheme == "java+class", s.file==className};
	
	for (method <- methods) {
		if (startsWith(method.file,methodName)) {
			return method;		
		}
	}
	
	throw("Unknown method \<<methodName>\> in class \<<className>\>");
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
test bool testCyclometicComplexity2() = getCyclomaticComplexity("Ternary", "ternaryFoo") == 3 ;
test bool testCyclometicComplexity3() = getCyclomaticComplexity("ComplexMethod", "foo") == 6 ;

test bool testShouldAnalyseInnerClasses() {
	return 
	[
	  classAnalysis([],false,|java+class:///nl/mse/complexity/InnerClass|),
	  classAnalysis([methodAnalysis(9,2,|java+method:///nl/mse/complexity/InnerClass/Inner1/clone()|)],true,|java+class:///nl/mse/complexity/InnerClass/Inner1|),
	  classAnalysis([methodAnalysis(9,6,|java+method:///nl/mse/complexity/InnerClass/Inner2/clone()|)],true,|java+class:///nl/mse/complexity/InnerClass/Inner2|)
	] == analyseClass(getClass("InnerClass"),v, false);
}
	
test bool testShouldAnalyseMethodWithInnerClassCorrectly() = [classAnalysis([methodAnalysis(19,4,_)], false,_)] := analyseClass(getClass("MethodWithAnonymousClass"),v, true);

