module metrics::java::NoiseFilter

import String;
import Domain;

alias InludeResult = tuple[bool, bool];

public list[EffectiveLine] filterLines(list[str] input) {
	bool inComment = false;
	int lineNumber = 1;
	return for (line <- input) {
		<res,inComment> = includeLine(line, inComment);
		if (res) {
			append effectiveLine(lineNumber, line);
		}
		lineNumber += 1;
	}
}

public InludeResult includeLine(s, inComment) {
 	if (inComment) {
 		if (/^((?!\*\/).)*\*\/\s*$/ := s) {
 			return <false, false>;	
 		}
 		if (/^<match:((?!\*\/).)*\*\/>/ := s) {
 			return includeLine(replaceFirst(s, match, ""), false);
		}
		return <false, true>;
 	}
 	if (/^\s*($|\/\/)/ := s) {
 		return <false, false>;
 	}

	//Check if line has multi line opening at beginning of line
 	if (/<match:^\s*\/\*>/ := s) {
 		return includeLine(replaceFirst(s, match, ""), true);
 	}
 	
 	//Replace all string content with empty content to make sure "/*" does not occur
 	if (/"<inner:(\\|\"|((?!").))+>"/ := s) {
 		return includeLine(replaceFirst(s, inner, ""), false);
 	}
 	
 	//Check if line has opening after content
 	if (/<match:\/\*>/ := s) {
 		<_, v> = includeLine(replaceFirst(s, match, ""), true);
 		return <true, v>;
 	}
 	return <true, false>;
}