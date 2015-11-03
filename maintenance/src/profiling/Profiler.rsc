module profiling::Profiler

import Domain;
import IO;

import profiling::Complexity;
import profiling::UnitSize;
import profiling::Volume;
import profiling::Duplications;

public map[str,Profile] profile(ProjectAnalysis project) {
	map[str,Profile] result = ();
	
	result += ("volume" : profileVolume(project));
	result += ("complexity_per_unit" : profileComplexity(project));
	result += ("duplication" : profileDuplication(project));	
	result += ("unit_size" : profileUnitSize(project));
	
	return result;
}