module metrics::java::Complexity

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import List;
import Set;
import IO;
import Type;
import String;
import Node;

public map[loc,int] methodComplexity(set[loc] classMethods, M3 model, Declaration declaration) {
	map[str,loc] absMethodLocations = ( replaceFirst("<rhs>", rhs.scheme, "") : lhs | <lhs, rhs> <- model@declarations, lhs in classMethods);
	map[loc,int] result = ();
	
	visit (declaration) {
		case x: \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl) : {
			result += handleMethodNode(x@src, absMethodLocations, impl);
		}	
		case x: \constructor(str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl): {
			result += handleMethodNode(x@src, absMethodLocations, impl);
		}
	}
	iprintln(result);
	return result;
}

private map[loc, int] handleMethodNode(loc src, map[str,loc] absMethodLocations, Statement impl) {
	str key = replaceFirst("<src>", src.scheme, "");
	if(absMethodLocations[key]?) {
		return (absMethodLocations[key]: complexityOfStatement(impl));
	}
	return ();
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