module metrics::java::NoiseFilterTest

import metrics::java::NoiseFilter;
import Domain;

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
test bool filterLines2() = filterLines(["foo", "//abc", "bar"]) == [effectiveLine(1,"foo"),effectiveLine(3,"bar")];
test bool filterLines3() = filterLines(["/*", "foo", "*/"]) == [];
test bool filterLines4() = filterLines(["// /*", "foo", "*/"]) == [effectiveLine(2,"foo"), effectiveLine(3,"*/")];
test bool filterLines5() = filterLines(["/*", "*", "*/ /* */", "a"]) == [effectiveLine(4,"a")];
test bool filterLines6() = filterLines(["/* lets make a party*/    if(true){","    //eyy","	/*","	 * ","	 */ /* */","   }","  }","}"]) 
									== [effectiveLine(1,"/* lets make a party*/    if(true){"),
										effectiveLine(6,"   }"), 
										effectiveLine(7,"  }"),
										effectiveLine(8,"}")];
									
test bool filterLines7() = filterLines(["    /**	List of Columns */","    final Expressions columnExpressions; "]) 
									== [effectiveLine(2,"    final Expressions columnExpressions; ")];