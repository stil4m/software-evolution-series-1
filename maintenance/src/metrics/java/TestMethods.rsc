module metrics::java::TestMethods

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Set;

public set[loc] findTestedMethods(M3 m3Model) {
	set[loc] methodsInTestPackage = {}; //These include the non test annotated methods as wel
	
	set[loc] testableMethods = { lhs | <lhs,rhs> <- m3Model@declarations, isMethod(lhs), isTestable(lhs, m3Model), lhs notin methodsInTestPackage};
	
	set[loc] invokedMethods = { rhs | <lhs,rhs> <- m3Model@methodInvocation
									, lhs in methodsInTestPackage
									, rhs in testableMethods};
									
	return invokedMethods;
}

private set[Modifier] methodModifiers(loc method, M3 model) {
	return { m | <lhs, m>  <- model@modifiers, lhs == method};
}
private bool isTestable(loc method, M3 m3Model) {
	set[Modifier] modifiers = methodModifiers(method, m3Model);
	return \public() in modifiers || \protected() in modifiers; 
}
