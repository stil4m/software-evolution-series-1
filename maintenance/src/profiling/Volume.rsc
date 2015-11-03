module profiling::Volume

import Domain;

public Profile profileVolume(ProjectAnalysis project) {
	ProfileData d = ("size":project.LOC);
	if (project.LOC < 66000) return plusPlus(d);
	if (project.LOC < 246000) return plus(d);
	if (project.LOC < 665000) return neutral(d);
	if (project.LOC < 1310000) return minus(d);
	return minusMinus(d);
}