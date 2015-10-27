module metrics::java::NoiseFilter

/**

*/

alias InludeResult = tuple[bool,bool];

public list[str] filterLines(list[str] input) {
	bool inComment = false;
	return for (line <- input) {
		<res,inComment> = includeLine(line, inComment);
		if (res) {
			append line;
		}
	}
}

 public InludeResult includeLine(s, inComment) {
 	if (inComment) {
 		if (/^[^\*\/]*\*\/\s*$/ := s) {
 			return <false, false>;	
 		}
 		if (/^[^\*\/]*\*\// := s) {
 			return <true, false>;
		}
		return <false, true>;
 	}
 	if (/^\s*($|\/\/)/ := s) {
 		return <false, inComment>;
 	}
 	if (/^\s*\/\*/ := s) {
 		return <false, true>;
 	}
 	if (/\/\*/ := s) {
 		return <true, true>;
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

test bool filterLines1() = filterLines(["//abc"]) == [];
test bool filterLines2() = filterLines(["foo", "//abc", "bar"]) == ["foo","bar"];
test bool filterLines3() = filterLines(["/*", "foo", "*/"]) == [];
test bool filterLines4() = filterLines(["// /*", "foo", "*/"]) == ["foo", "*/"];
