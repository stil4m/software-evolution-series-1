module profiling::ProfilingUtil

import util::Math;
import Domain;

public Profile convertToProfile(RiskProfile riskProfile, int totalLOC) {
	real moderate = toReal(riskProfile[moderate()] ? 0) / totalLOC;
	real high = toReal(riskProfile[high()] ? 0) / totalLOC;
	real veryHigh = toReal(riskProfile[veryHigh()] ? 0) / totalLOC;
	
	if (moderate <= 0.25 && high == 0 && veryHigh == 0) return plusPlus();
	if (moderate <= 0.3 && high <= 0.05 && veryHigh == 0) return plus();
	if (moderate <= 0.4 && high <= 0.1 && veryHigh == 0) return neutral();
	if (moderate <= 0.5 && high <= 0.15 && veryHigh <= 0.05) return minus();
	return minusMinus();
}