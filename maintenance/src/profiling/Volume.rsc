module profiling::Volume

import Domain;

public Profile profileVolume(ProjectAnalysis project) {
	ProfileData d = ("size":project.LOC);
	if (project.LOC <= 66000) return plusPlus(d);
	if (project.LOC <= 246000) return plus(d);
	if (project.LOC <= 665000) return neutral(d);
	if (project.LOC <= 1310000) return minus(d);
	return minusMinus(d);
}


public Profile profileWithLoc(int n) = profileVolume(projectAnalysis(n, []));

test bool profileVolumePlusPlusMin() = profileWithLoc(1) == plusPlus(("size":1));
test bool profileVolumePlusPlusMax() = profileWithLoc(66000) == plusPlus(("size":66000));
test bool profileVolumePlusMin() = profileWithLoc(66001) == plus(("size":66001));
test bool profileVolumePlusMax() = profileWithLoc(246000) == plus(("size":246000));
test bool profileVolumeNeutralMin() = profileWithLoc(246001) == neutral(("size":246001));
test bool profileVolumeNeutralMax() = profileWithLoc(665000) == neutral(("size":665000));
test bool profileVolumeMinusMin() = profileWithLoc(665001) == minus(("size":665001));
test bool profileVolumeMinusMax() = profileWithLoc(1310000) == minus(("size":1310000));
test bool profileVolumeMinusMinus() = profileWithLoc(1310001) == minusMinus(("size":1310001));