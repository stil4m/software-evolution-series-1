module profiling::Duplications

import profiling::DuplicationDetection;
import Domain;
import IO;
import List;
import util::Math;


public Profile profileDuplication(ProjectAnalysis projectAnalysis)  {
	set[LineRefs] duplications = computeDuplications(projectAnalysis);
	map[FileAnalysis,list[int]] fileDuplications = aggregateDuplications(duplications);
	
	list[map[str,value]] duplicationFiles = [ ("path": f.location.path, "lines" : fileDuplications[f]) | f <- fileDuplications];
	int totalDuplications = (0 | it + size(fileDuplications[k]) | k <- fileDuplications);
	
	map[str,value] fileDuplicationData = (
		"files" : duplicationFiles,
		"count" : totalDuplications 
	);
	
	real duplicationPercentage = toReal(totalDuplications) / projectAnalysis.LOC;

	if (duplicationPercentage <= 0.03) return plusPlus(fileDuplicationData);
	if (duplicationPercentage <= 0.05) return plus(fileDuplicationData);	
	if (duplicationPercentage <= 0.10) return neutral(fileDuplicationData);
	if (duplicationPercentage <= 0.20) return minus(fileDuplicationData);	
	return minusMinus(fileDuplicationData);
}