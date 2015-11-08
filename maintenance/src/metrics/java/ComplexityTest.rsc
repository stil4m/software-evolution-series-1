module metrics::java::ComplexityTest

import metrics::java::Complexity;
import lang::java::jdt::m3::AST;
import TestUtil;

public int getComplexity(str className, str methodName) = methodComplexity(getMethod(className,methodName),v);

test bool shouldGetComplexity1() = getComplexity("DoWhileStatement", "doSomething") == 2;
test bool shouldGetComplexity2() = getComplexity("Ternary", "ternaryFoo") == 3;
test bool shouldGetComplexity3() = getComplexity("ComplexMethod", "foo") == 6;
test bool shouldGetComplexity4() = getComplexity("Constructor", "") == 1;

test bool complexityOfAssert() = complexityOfStatement(\assert(\this())) == 1;
test bool complexityOfAssertWithMessage() = complexityOfStatement(\assert(\this(), \null())) == 1;
test bool complexityOfBlock() = complexityOfStatement(\block([])) == 1;
test bool complexityOfBreak() = complexityOfStatement(\break()) == 1;
test bool complexityOfBreakWithLabel() = complexityOfStatement(\break("label")) == 1;
test bool complexityOfContinue() = complexityOfStatement(\continue()) == 1;
test bool complexityOfContinueWithLabel() = complexityOfStatement(\continue("label")) == 1;
test bool complexityOfDo() = complexityOfStatement(\do(\empty(),\null())) == 1;
test bool complexityOfEmpty() = complexityOfStatement(\empty()) == 1;
test bool complexityOfForEach() = complexityOfStatement(\foreach(\typeParameter("int",[]),\null(),\empty())) == 2;
test bool complexityOfFor() = complexityOfStatement(\for([],\null(),[],\empty())) == 2;
test bool complexityOfForWithoutCondition()  = complexityOfStatement(\for([],[],\empty())) == 2;
test bool complexityOfIf() = complexityOfStatement(\if(\null(),\empty())) == 2;
test bool complexityOfIfElse() = complexityOfStatement(\if(\null(),\empty(),\empty())) == 2;
test bool complexityOfLabel() = complexityOfStatement(\label("foo",\empty())) == 1;
test bool complexityOfReturn() = complexityOfStatement(\return(\null())) == 1;
test bool complexityOfReturnVoid() = complexityOfStatement(\return()) == 1;
test bool complexityOfSwitch() = complexityOfStatement(\switch(\null(),[])) == 1;
test bool complexityOfCase() = complexityOfStatement(\case(\null())) == 2;
test bool complexityOfDefaultCase() = complexityOfStatement(\defaultCase()) == 1;
test bool complexityOfSynchronized() = complexityOfStatement(\synchronizedStatement(\null(),\empty())) == 1;
test bool complexityOfThrow() = complexityOfStatement(\throw(null())) == 1;
test bool complexityOfTry() = complexityOfStatement(\try(\empty(),[])) == 1;
test bool complexityOfTryWithFinaly() = complexityOfStatement(\try(\empty(),[], \empty())) == 1;
test bool complexityOfCatch() = complexityOfStatement(\catch(\typeParameter("Exception", []), \empty())) == 2;
test bool complexityOfDeclarationStatement() = complexityOfStatement(\declarationStatement(\package("pack"))) == 1;
test bool complexityOfWhile() = complexityOfStatement(\while(\null(),\empty())) == 2;
test bool complexityOfExpressionStatement() = complexityOfStatement(\expressionStatement(\null())) == 1;
test bool complexityOfConstructorCallWithExpression() = complexityOfStatement(\constructorCall(false,\null(),[])) == 1;
test bool complexityOfConstructorCall() = complexityOfStatement(\constructorCall(false,[])) == 1;

test bool complexityOfConditional() = complexityOfStatement(\expressionStatement(\conditional(\null(),\null(),\null()))) == 2;
test bool complexityOfOr() = complexityOfStatement(\expressionStatement(\infix(\null(), "||",\null()))) == 2;
test bool complexityOfAnd() = complexityOfStatement(\expressionStatement(\infix(\null(),"&&",\null()))) == 2;