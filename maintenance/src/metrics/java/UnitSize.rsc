module metrics::java::UnitSize

import lang::java::jdt::m3::Core;
import metrics::java::LOC;
import metrics::MetricUtil;
import metrics::Constants;
import IO;

public Rating calculateUnitSize(M3 model) {
	set[loc] methods = { m | <m,_> <- model@containment, isMethod(m) };
	map[loc,int] methodSizes = ( methodLoc:relevantLines(methodLoc) | methodLoc <- methods );
	
	RiskProfile riskProfile = createRiskProfile(methodSizes);
	int totalLOC = calculateLOC(model);
	return riskProfileToRating(riskProfile,totalLOC);
}

public RiskProfile createRiskProfile(map[loc,int] unitSize) {
	RiskProfile riskProfile = (); 
	
	for(method <- unitSize) {
		Risk risk = getRiskProfile(unitSize[method]);
		riskProfile[risk] ? 0 += unitSize[method];
	}

	return riskProfile;
}

//0-20 = low
//21-50 = moderate
//51-100 = high
//>100 = very high
public Risk getRiskProfile(int unitSize) {
	if (unitSize <= 20) {
	 	return low();
	} else if (unitSize <= 50) {
		return moderate();
	} else if (unitSize <= 100) { 
		return high();	
	} else {
		return veryHigh();
	}
}

test bool getRiskProfileLow1() = getRiskProfile(0) == low();
test bool getRiskProfileLow2() = getRiskProfile(20) == low();
test bool getRiskProfileModerate1() = getRiskProfile(21) == moderate();
test bool getRiskProfileModerate2() = getRiskProfile(50) == moderate();
test bool getRiskProfileHigh1() = getRiskProfile(51) == high();
test bool getRiskProfileHigh2() = getRiskProfile(100) == high();
test bool getRiskProfileVeryHigh() = getRiskProfile(101) == veryHigh();