module MaintenanceTest

import Maintenance;
import Domain;
import TestUtil;

test bool shouldAnalyseInnerClassesSeparately() =
	[
	  classAnalysis([], false, |java+class:///nl/mse/complexity/InnerClass|),
	  classAnalysis([methodAnalysis(9, 2, false, |java+method:///nl/mse/complexity/InnerClass/Inner1/clone()|)], true, |java+class:///nl/mse/complexity/InnerClass/Inner1|),
	  classAnalysis([methodAnalysis(9, 6, false, |java+method:///nl/mse/complexity/InnerClass/Inner2/clone()|)], true, |java+class:///nl/mse/complexity/InnerClass/Inner2|)
	] == analyseClass(getClass("InnerClass"), v, false, {});
	
test bool shouldAnalyseMethodWithInnerClassCorrectly() = [classAnalysis([methodAnalysis(19,4,false,_)], false, _)] := analyseClass(getClass("MethodWithAnonymousClass"),v, false, {});

