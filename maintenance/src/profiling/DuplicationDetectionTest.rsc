module profiling::DuplicationDetectionTest

import profiling::DuplicationDetection;
import Domain;

public FileAnalysis fileAnalysis1 = fileAnalysis(6, [], [
	effectiveLine(1, "A1"),
	effectiveLine(2, "A2"),
	effectiveLine(3, "A3"),
	effectiveLine(4, "A4"),
	effectiveLine(5, "A5"),
	effectiveLine(6, "A6")
], |file://foo1|);

public FileAnalysis fileAnalysis2 = fileAnalysis(9,[], [
	effectiveLine(1, "A1"),
	effectiveLine(2, "A2"),
	effectiveLine(3, "A3"),
	effectiveLine(4, "A4"),
	effectiveLine(5, "A5"),
	effectiveLine(6, "A6")
], |file://foo2|);

public FileAnalysis fileAnalysis3 = fileAnalysis(5,[], [
	effectiveLine(1, "A1"),
	effectiveLine(2, "A2"),
	effectiveLine(3, "B3"),
	effectiveLine(4, "B4"),
	effectiveLine(5, "B5")
], |file://foo3|);

public FileAnalysis fileAnalysis4 = fileAnalysis(5,[], [
	effectiveLine(1, "A1"),
	effectiveLine(2, "A2"),
	effectiveLine(3, "B3"),
	effectiveLine(4, "B4"),
	effectiveLine(5, "B5")
], |file://foo4|);

test bool testDuplicationCalculationWithMultipleFileAnalysisses() {
	output = computeDuplications(projectAnalysis(0, [fileAnalysis1,fileAnalysis2,fileAnalysis3,fileAnalysis4]));
	return aggregateDuplications(output) == (
	  fileAnalysis1:[0,1,2,3,4,5],
	  fileAnalysis2:[0,1,2,3,4,5]
	);
}

test bool testDupliationOnDifferentContent() {
	output = computeDuplications(projectAnalysis(0, [fileAnalysis2,fileAnalysis3]));
	return aggregateDuplications(output) == ();
}

test bool testDupliationOnMatchingLinesButTooShortSize() {
	output = computeDuplications(projectAnalysis(0, [fileAnalysis3,fileAnalysis4]));
	return aggregateDuplications(output) == ();
}

test bool testDupliationOnEmptyProjectFiles() {
	output = computeDuplications(projectAnalysis(0, []));
	return aggregateDuplications(output) == ();
}

