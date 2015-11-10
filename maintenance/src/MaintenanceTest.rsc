module MaintenanceTest

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import Maintenance;
import Domain;
import TestUtil;

public Declaration getAst(str compilationUnitName) = createAstFromFile(getCompilationUnit(compilationUnitName), false, javaVersion="1.6");

test bool shouldAnalyseInnerClassesSeparately() =
	[
	  classAnalysis([], false, |java+class:///nl/mse/complexity/InnerClass|),
	  classAnalysis([methodAnalysis(9, 2, false, |java+method:///nl/mse/complexity/InnerClass/Inner1/clone()|)], true, |java+class:///nl/mse/complexity/InnerClass/Inner1|),
	  classAnalysis([methodAnalysis(9, 6, false, |java+method:///nl/mse/complexity/InnerClass/Inner2/clone()|)], true, |java+class:///nl/mse/complexity/InnerClass/Inner2|)
	] == analyseClass(getClass("InnerClass"), getTestM3(), false, {}, getAst("InnerClass.java"));
	
test bool shouldAnalyseMethodWithInnerClassCorrectly() = [classAnalysis([methodAnalysis(19,4,false,_)], false, _)] := 
		analyseClass(getClass("MethodWithAnonymousClass"),getTestM3(), false, {}, getAst("MethodWithAnonymousClass.java"));

