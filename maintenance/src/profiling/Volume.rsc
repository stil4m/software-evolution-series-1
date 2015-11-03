module profiling::Volume

import Domain;

public Profile profileVolume(ProjectAnalysis project) {
	if (project.LOC < 66000) return plusPlus();
	if (project.LOC < 246000) return plus();
	if (project.LOC < 665000) return neutral();
	if (project.LOC < 1310000) return minus();
	return minusMinus();
}