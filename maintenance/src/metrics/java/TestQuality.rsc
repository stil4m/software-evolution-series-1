module metrics::java::TestQuality

import Domain;
import List;
import IO;

data FileTestQuality = fileTestQuality(
	int asserts,
	int verifies,
	int total,
	int methods,
	real averagePerMethod
);

public FileTestQuality qualityOfFile(FileAnalysis fileAnalysis) {
	int asserts = (0 | it + 1 | effectiveLine <- fileAnalysis.lines, /\s*assert/ := effectiveLine.content);
	int verifies = (0 | it + 1 | effectiveLine <- fileAnalysis.lines, /\s*verify/ := effectiveLine.content);
	int testMethods = (0 | it + size(class.methods) | class <- fileAnalysis.classes);
	int total = asserts+verifies;
	
	real averagePerMethod = testMethods == 0 ? 0.0 : 1.0 * total / testMethods; 
	return fileTestQuality(asserts,verifies,total, testMethods, averagePerMethod);
}