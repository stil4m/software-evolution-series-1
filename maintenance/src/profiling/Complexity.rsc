module profiling::Complexity

import Domain;
import profiling::ProfilingUtil;

public Profile profileComplexity(ProjectAnalysis project) {
	RiskProfile riskProfile = ();
	for(file <- project.files, class <- file.classes, method <- class.methods) {
		riskProfile[getCCRisk(method.cc)] ? 0 += method.LOC;
	}
	
	return convertToProfile(riskProfile, project.LOC);
}

private Risk getCCRisk(int unitSize) {
	if (unitSize <= 10) {
	 	return low();
	} else if (unitSize <= 20) {
		return moderate();
	} else if (unitSize <= 50) { 
		return high();	
	} else {
		return veryHigh();
	}
}