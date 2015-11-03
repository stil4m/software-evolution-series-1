module metrics::java::CodeDuplication

import List;
import IO;
import lang::java::jdt::m3::Core;
import metrics::java::CyclomaticComplexity;
import metrics::java::UnitSize;
import metrics::java::LOC;
import metrics::Constants;
import Domain;
import List;
import Type;
import Set;
import IO;
import String;


//in: CU 
public value detectDuplication(lrel[int,str] q, lrel[int, str] source) {
	str currentScanLine = "";
	
	int matchingLines = 0;
	int currentLineIndex = 0;
	int currentScanIndex = 0;
	int maxMatchingLines = 0;
	
	bool end = false;
	
	
	while (currentLineIndex < size(q)) {
		currentLine = q[currentLineIndex];
		
		for (<ln2, content2> <- source) {
			iprintln("cli <currentLineIndex>, csi <currentScanIndex>");
			
			if(currentScanIndex == size(q))
			{
				iprinlnt("breaking at <currentLineIndex>");
				break;			
			}
		
			currentScanLine = q[currentScanIndex][1];
			
			if (currentScanLine == content2) {
				matchingLines += 1;
				currentScanIndex +=1;
				iprintln("We have a match: <matchingLines> out of <maxMatchingLines>");
			} else {
				matchingLines = 0;
				currentScanIndex = currentLineIndex;
			}
			
			if (matchingLines > maxMatchingLines)
			{
				maxMatchingLines = matchingLines;
			}
			
		}
		
		if (maxMatchingLines >= 6) {
			iprintln("lines <currentLine[0]> - <q[currentLineIndex + (maxMatchingLines - 1)][0]> match" );
			currentLineIndex += maxMatchingLines;
		} else {
			currentLineIndex += 1;
		}
		
		matchingLines = 0;
		maxMatchingLines = 0;
		currentScanIndex = currentLineIndex;
	}
 	
 	return 1;
}

test bool detectDuplication() {
	loc fileA = |project://hello-world-java/src/nl/mse/dup/DuplicateFoo1.java|;
	lrel[int,str] lines = [ <c,trim(s)> | <c,s> <- relevantLines(fileA)];
	
	loc fileB = |project://hello-world-java/src/nl/mse/dup/DuplicateFoo2.java|;
	lrel[int,str] lines2 = [ <c,trim(s)> | <c,s> <- relevantLines(fileB)];
	
	detectDuplication(lines, lines2);
	
	return true;
}

test bool simple() {
	lrel[int,str] a = [<0,"a">,<1,"b">,<2,"c">,<3,"d">,<4,"e">,<5,"f">,<6,"g">,<7,"h">];
	lrel[int,str] b = [<0,"a">,<1,"b">,<2,"c">,<3,"d">,<4,"e">,<5,"f">,<6,"g">];
	detectDuplication(a, b);
	
	return true;
}
