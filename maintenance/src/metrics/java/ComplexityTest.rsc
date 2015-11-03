module metrics::java::ComplexityTest

import metrics::java::Complexity;
import TestUtil;

public int getComplexity(str className, str methodName) = methodComplexity(getMethod(className,methodName),v);

test bool shouldGetComplexity1() = getComplexity("DoWhileStatement", "doSomething") == 2;
test bool shouldGetComplexity2() = getComplexity("Ternary", "ternaryFoo") == 3 ;
test bool shouldGetComplexity3() = getComplexity("ComplexMethod", "foo") == 6 ;