module profiling::Duplications

import profiling::DuplicationDetection;
import Domain;
import IO;
import List;
import util::Math;


public Profile profileDuplication(ProjectAnalysis projectAnalysis)  {
	set[LineRefs] duplications = computeDuplications(projectAnalysis);
	map[FileAnalysis,list[int]] fileDuplications = aggregateDuplications(duplications);
	
	int totalDuplications = (0 | it + size(fileDuplications[k]) | k <- fileDuplications);
	
	real duplicationPercentage = toReal(totalDuplications) / projectAnalysis.LOC;

	if (duplicationPercentage <= 0.03) return plusPlus();
	if (duplicationPercentage <= 0.05) return plus();	
	if (duplicationPercentage <= 0.10) return neutral();
	if (duplicationPercentage <= 0.20) return minus();	
	return minusMinus();
}