module profiling::ProfilingUtil

import util::Math;
import Domain;

public Profile convertToProfile(RiskProfile riskProfile, int totalLOC) {
	real moderate = toReal(riskProfile[moderate()] ? 0) / totalLOC;
	real high = toReal(riskProfile[high()] ? 0) / totalLOC;
	real veryHigh = toReal(riskProfile[veryHigh()] ? 0) / totalLOC;
	
	map[str,value] riskData = riskProfileToMap(riskProfile);
	
	if (moderate <= 0.25 && high == 0 && veryHigh == 0) return plusPlus(riskData);
	if (moderate <= 0.3 && high <= 0.05 && veryHigh == 0) return plus(riskData);
	if (moderate <= 0.4 && high <= 0.1 && veryHigh == 0) return neutral(riskData);
	if (moderate <= 0.5 && high <= 0.15 && veryHigh <= 0.05) return minus(riskData);
	return minusMinus(riskData);
}

private map[str,value] riskProfileToMap(RiskProfile riskProfile) {
	return (stringListKey(riskKey) : riskProfile[riskKey] | riskKey <- riskProfile);
}

private str stringListKey(low()) = "low";
private str stringListKey(low()) = "moderate";
private str stringListKey(low()) = "high";
private str stringListKey(low()) = "very_high";