module metrics::java::CyclomaticComplexity

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import List;
import Set;
import IO;
import Type;
import String;
import Node;

//http://gmetrics.sourceforge.net/gmetrics-CyclomaticComplexityMetric.html
public void runCC() {
	v =  createM3FromEclipseProject(|project://hello-world-java|);
	calculateCyclomaticComplexity(v);
}

public void calculateCyclomaticComplexity(M3 v) {
	set[loc] cs = classes(v);
	
	for(c <- cs) {
		println(c.path);
		ms = methods(v, c);
		for(m <- ms) {
			Declaration t = getMethodASTEclipse(m, model=v);
			if (\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl) := t) {
				println(complexityOfStatement(impl));
			}
		}
	}
}

private int complexityOfStatement(Statement statement) {
	int i = 1;
	visit (statement) {
		case \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body) : {
			i += 1;
		}
		case \for(list[Expression] initializers, list[Expression] updaters, Statement body) : {
			i += 1;
		}
		case \while(Expression condition, Statement body) : {
			i += 1;
		}
		case \if(Expression condition, Statement thenBranch) : {
			i += 1;
		}
		case /^\|\|$/ : {
			i += 1;
		}
		case /^&&$/ : {
			i += 1;
		}
		case \if(Expression condition, Statement thenBranch, Statement elseBranch) : {
			i += 1;
		}
		case \case(Expression expression) : {
			i += 1;
		}
		case \catch(Declaration exception, Statement body) : {
			i += 1;
		}
	}
	return i;
}