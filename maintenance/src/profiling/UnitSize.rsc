module profiling::UnitSize

import Domain;
import profiling::ProfilingUtil;

public Profile profileUnitSize(ProjectAnalysis project) {
	RiskProfile riskProfile = ();
	for(file <- project.files, class <- file.classes, method <- class.methods) {
		riskProfile[getUnitSizeRisk(method.LOC)] ? 0 += method.LOC;
	}
	return convertToProfile(riskProfile, project.LOC);
}

private Risk getUnitSizeRisk(int unitSize) {
	if (unitSize <= 20) return low();
	if (unitSize <= 50) return moderate();
	if (unitSize <= 100) return high();	
	return veryHigh();
}
