module metrics::java::Complexity

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import List;
import Set;
import IO;
import Type;
import String;
import Node;

public int methodComplexity(loc m, M3 model) {
	Declaration t = getMethodASTEclipse(m, model=model);
	if (\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl) := t) {
		return complexityOfStatement(impl);
	}
	
	return 0;
}

public int complexityOfStatement(Statement statement) {
	int i = 1;
	visit (statement) {
		case \foreach(Declaration parameter, Expression collection, Statement body) : 
			i += 1;
		case \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body) : 
			i += 1;
		case \for(list[Expression] initializers, list[Expression] updaters, Statement body) : 
			i += 1;
		case \while(Expression condition, Statement body) : 
			i += 1;
		case \if(Expression condition, Statement thenBranch) : 
			i += 1;
		case \infix(_,/^||$/,_) : 
			i += 1;
		case \infix(_,/^&&$/,_) : 
			i += 1;
		case \if(Expression condition, Statement thenBranch, Statement elseBranch) : 
			i += 1;
		case \case(Expression expression) : 
			i += 1;
		case \catch(Declaration exception, Statement body) : 
			i += 1;
		case \conditional(Expression expression, Expression thenBranch, Expression elseBranch) : 
			i += 1; 
	}
	return i;
}

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