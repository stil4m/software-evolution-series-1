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
	} else if (\constructor(str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl) := t) {
		return complexityOfStatement(impl);
	}
	
	return 0;
}

int complexityOfStatement(Statement statement) {
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
		case \infix(_,/^\|\|$/,_) : 
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