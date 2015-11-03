module metrics::java::LOCTest

import metrics::java::LOC;
import TestUtil;

public int getRelevantLineCount(str name) = relevantLineCount(getCompilationUnit(name));

test bool testFileLineCount1() = getRelevantLineCount("CommentSameLine.java") == 6;
test bool testFileLineCount2() = getRelevantLineCount("ControlLoop.java") == 10;
test bool testFileLineCount3() = getRelevantLineCount("ControlLoopWithComment.java") == 10;
test bool testFileLineCount4() = getRelevantLineCount("Empty.java") == 3;
test bool testFileLineCount5() = getRelevantLineCount("EmptyWithComment.java") == 3;
test bool testFileLineCount6() = getRelevantLineCount("MethodComment.java") == 6;
test bool testFileLineCount7() = getRelevantLineCount("Robot.java") == 9;
test bool testFileLineCount8() = getRelevantLineCount("SimplePojo.java") == 5;
test bool testFileLineCount9() = getRelevantLineCount("WithMethod.java") == 6;
test bool testFileLineCount10() = getRelevantLineCount("A4.java") == 9;