module profiling::UnitTesting

import Domain;
import IO;
import DateTime;
import util::Math;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import profiling::ProfilingUtil;
import profiling::UnitTestCoverage;
import profiling::UnitTestVolume;
import profiling::UnitTestQuality;

public Profile profileUnitTesting(ProjectAnalysis project, M3 m3Model) {
	Profile unitTestCoverage = profileUnitTestCoverage(project, m3Model);
	Profile unitTestVolume = profileUnitTestVolume(project);
	Profile unitTestQuality = profileUnitTestQuality(project);
	result = mergeProfiles([
		<"unit_test_coverage", unitTestCoverage>, 
		<"unit_test_volume", unitTestVolume>, 
		<"unit_test_quality", unitTestQuality>
	]);
	
	return result;
}

