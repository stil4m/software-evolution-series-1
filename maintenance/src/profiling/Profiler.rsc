module profiling::Profiler

import Domain;
import IO;
import DateTime;
import lang::java::jdt::m3::Core;

import profiling::Complexity;
import profiling::UnitSize;
import profiling::UnitTesting;
import profiling::Volume;
import profiling::Duplications;

public map[str,Profile] profile(ProjectAnalysis project, M3 model) {
	map[str,Profile] result = ();
	
	println("<printDateTime(now())> Profiling \> volume...");
	result += ("volume" : profileVolume(project));
	println("<printDateTime(now())> Profiling \> unit complexity...");
	result += ("complexity_per_unit" : profileComplexity(project));
	println("<printDateTime(now())> Profiling \> duplication...");
	result += ("duplication" : profileDuplication(project));	
	println("<printDateTime(now())> Profiling \> unit size...");
	result += ("unit_size" : profileUnitSize(project));
	println("<printDateTime(now())> Profiling \> unit testing...");
	result += ("unit_testing" : profileUnitTesting(project, model));
	
	return result;
}