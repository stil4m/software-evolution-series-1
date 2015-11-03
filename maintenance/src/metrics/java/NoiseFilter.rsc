module metrics::java::NoiseFilter

import IO;
import String;

alias InludeResult = tuple[bool,bool];

public lrel[int,str] filterLines(list[str] input) {
	bool inComment = false;
	int i = 1;
	return for (line <- input) {
		<res,inComment> = includeLine(line, inComment);
		if (res) {
			append <i,line>;
		}
		i += 1;
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


test bool includeLine1() = includeLine(" ", false) == <false, false>;
test bool includeLine2() = includeLine(" ", true) == <false, true>;
test bool includeLine3() = includeLine("", true) == <false, true>;
test bool includeLine4() = includeLine("//comment", true) == <false, true>;
test bool includeLine5() = includeLine("//comment", false) == <false, false>;
test bool includeLine6() = includeLine("int i; //comment", false) == <true, false>;
test bool includeLine7() = includeLine("int i; //comment", true) == <false, true>;
test bool includeLine8() = includeLine("int i; /*", false) == <true, true>;
test bool includeLine9() = includeLine("int i; /*", true) == <false, true>;
test bool includeLine10() = includeLine("/*", false) == <false, true>;
test bool includeLine11() = includeLine("/*", true) == <false, true>;
test bool includeLine12() = includeLine("*/", false) == <true, false>;
test bool includeLine13() = includeLine("*/", true) == <false, false>;
test bool includeLine14() = includeLine("abc */", false) == <true, false>;
test bool includeLine15() = includeLine("abc */", true) == <false, false>;
test bool includeLine16() = includeLine("*/ x + y", false) == <true, false>;
test bool includeLine17() = includeLine("*/ x + y", true) == <true, false>;
test bool includeLine18() = includeLine("/* foo */", false) == <false, false>;
test bool includeLine19() = includeLine("    /**	List of Columns */", false) == <false, false>;
test bool includeLine20() = includeLine("\" /* \"", false) == <true, false>;

test bool filterLines1() = filterLines(["//abc"]) == [];
test bool filterLines2() = filterLines(["foo", "//abc", "bar"]) == [<0,"foo">,<2,"bar">];
test bool filterLines3() = filterLines(["/*", "foo", "*/"]) == [];
test bool filterLines4() = filterLines(["// /*", "foo", "*/"]) == [<1,"foo">, <2,"*/">];
test bool filterLines5() = filterLines(["/*", "*", "*/ /* */", "a"]) == [<3,"a">];
test bool filterLines6() = filterLines(["/* lets make a party*/    if(true){","    //eyy","	/*","	 * ","	 */ /* */","   }","  }","}"]) 
									== [<0,"/* lets make a party*/    if(true){">,<5,"   }">, <6,"  }">,<7,"}">];
									
test bool filterLines7() = filterLines(["    /**	List of Columns */","    final Expressions columnExpressions; "]) 
									== [<1,"    final Expressions columnExpressions; ">];
									


