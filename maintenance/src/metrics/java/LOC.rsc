module metrics::java::LOC

import List;
import metrics::java::NoiseFilter;
import Domain;
import IO;

//1) This file is not included in the createM3...:
// ./integration/extAuthWithSpring/src/org/hsqldb/sample/SpringExtAuth.java
// This is why the LOC will be 102 lines less than sloccount.

//2) Sloccount has a bug that it will yield a lower line count when analyzing the root folder
//   instead of the src/org folder. When sloccount is executed with `.` it yields `164950`. for the src/org folder
//   When it is executed with `src/org` it yields `168212`
public int relevantLineCount(loc l) {
	int res = size(relevantLines(l));
	return res;
}

public list[EffectiveLine] relevantLines(loc l) {
	return filterLines(readFileLines(l));
}