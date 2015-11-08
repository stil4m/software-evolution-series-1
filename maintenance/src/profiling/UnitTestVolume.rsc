module profiling::UnitTestVolume

import util::Math;

import Domain;

public Profile profileUnitTestVolume(ProjectAnalysis project) {
	set[FileAnalysis] testFiles = {file | file <- project.files, file.containsTestClass};
	
	// These are the methods in the test files that are prefixed with "test"
	int testCount = (0 | it + 1 | file <- testFiles, class <- file.classes, method <- class.methods, method.isTest);
	
	int totalTestLOC = (0 | it + file.LOC | file <- testFiles);
	ProfileData profileData = ("test_volume" : totalTestLOC,
								"unit_test_count": testCount);
	
	return createTestVolumeProfile(project.LOC, totalTestLOC, profileData);
}

private Profile createTestVolumeProfile(int totalLOC, int totalTestLOC, ProfileData profileData) {
	real testVolumePercentage = toReal(totalTestLOC) / totalLOC;

	if (testVolumePercentage <= 0.10) return minusMinus(profileData);
	if (testVolumePercentage <= 0.20) return minus(profileData);	
	if (testVolumePercentage <= 0.30) return neutral(profileData);
	if (testVolumePercentage <= 0.40) return plus(profileData);	
	return plusPlus(profileData);
}