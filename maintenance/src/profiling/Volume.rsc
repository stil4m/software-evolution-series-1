module profiling::Volume

import Domain;

public Profile profileVolume(ProjectAnalysis project) {
	if (project.LOC < 66000) {
		return plusPlus();
	} else if (project.LOC < 246000) {
		return plus();
	} else if (project.LOC < 665000) {
		return neutral();
	} else if (project.LOC < 1310000) {
		return minus();
	} else {
		return minusMinus();
	}
}