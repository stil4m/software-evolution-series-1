module metrics::java::TestQuality

import Domain;

data FileTestQuality = fileTestQuality(
	int asserts,
	int verifies,
	int total
);

public FileTestQuality qualityOfFile(FileAnalysis fileAnalysis) {
	//int asserts = 0, verifies = 0;
	int asserts = (0 | it + 1 | effectiveLine <- fileAnalysis.lines, /\s*assert/ := effectiveLine.content);
	int verifies = (0 | it + 1 | effectiveLine <- fileAnalysis.lines, /\s*verify/ := effectiveLine.content);
	return fileTestQuality(asserts,verifies,asserts+verifies);
}