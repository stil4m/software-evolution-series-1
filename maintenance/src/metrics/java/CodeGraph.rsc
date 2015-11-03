module metrics::java::LOC2

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import Set;
import IO;
import Type;
import String;
import Node;

import ParseTree;
import vis::Figure;
import vis::ParseTree;
import vis::Render;

import Prelude;
import analysis::graphs::Graph;
import demo::lang::Pico::Abstract;
import demo::lang::Pico::Load;
import vis::Figure;
import vis::KeySym;

public void locmain() {
	//calculateLOC(createM3FromEclipseProject(|project://hello-world-java|));
	M3 model = createM3FromEclipseFile(|project://hello-world-java/src/nl/mse/complexity/DoWhileStatement.java|);
	render(visCFG(calculateLOC(model).graph));
}

public CFGraph calculateLOC(M3 v) {
	set[loc] methods = methods(v);
	iprintln(methods);
	
	for (method <- methods) {
		
		Declaration ast = getMethodASTEclipse(method, model=v);
		return cflowMethod(ast);
		//iprintln(ast);
		
		//findLines(ast);
		//return;
	}
}

public set[int] findLines(Declaration t) {
	set[int] lns = {};
	
	top-down visit (t) {
		case \if(Expression condition, Statement thenBranch) : {
			println("if");
			//iprintln(condition);
		}
		case \if(Expression condition, Statement thenBranch, Statement elseBranch) : {
			println("if else");
			//iprintln(condition);
		}
		case \foreach(Declaration parameter, Expression collection, Statement body) : {
			println("foreach");
			//iprintln(body);
		}
		case \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body) : {
			println("for with condition");
			//iprintln(condition);
		}
		case \for(list[Expression] initializers, list[Expression] updaters, Statement body) : {
			println("for without condition");
			//iprintln(body);
		}
		case \do(Statement body, Expression condition) : {
			println("do");
			//iprintln(condition);
		}
		case \while(Expression condition, Statement body) : {
			println("while");
		}
		case \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl) : {
			println(name);
		}
		//case (Declaration) s : {
		//	iprintln("Declaration");
		//	//map[str,value] ans = getAnnotations(s);
		//	//if (ans["src"]? && loc l := ans["src"]) {
		//	//	lns += l.end.line;
		//	//	lns += l.begin.line;
		//	//}
		//}
		//case (Modifier) s : {
		//	iprintln("Modifier");
		//	//lns += s@src.end.line;
		//}
		//case (Type) s : {
		//	iprintln("Type");
		//	//map[str,value] ans = getAnnotations(s);
		//	//if (ans["src"]? && loc l := ans["src"]) {
		//	//	lns += l.end.line;
		//	//}
		//}
	}
	return lns;
}


public data CFNode                                                                
	= entry(loc location)
	| exit()
	| choice(loc location, Expression exp)
	| statement(loc location, Statement statement);

alias CFGraph = tuple[set[CFNode] entry, Graph[CFNode] graph, set[CFNode] exit];  

//CFGraph cflowStat(s:asgStat(PicoId Id, EXP Exp)) {                                
//   S = statement(s@location, s);
//   return <{S}, {}, {S}>;
//}

CFGraph cflowStat(ifElseStat(EXP Exp,                                             
                              list[STATEMENT] Stats1,
                              list[STATEMENT] Stats2)){
   CF1 = cflowStats(Stats1); 
   CF2 = cflowStats(Stats2); 
   E = {choice(Exp@location, Exp)}; 
   return < E, (E * CF1.entry) + (E * CF2.entry) + CF1.graph + CF2.graph, CF1.exit + CF2.exit >;
}

CFGraph cflowStat(whileStat(EXP Exp, list[STATEMENT] Stats)) {                    
   CF = cflowStats(Stats); 
   E = {choice(Exp@location, Exp)}; 
   return < E, (E * CF.entry) + CF.graph + (CF.exit * E), E >;
}

//CFGraph cflowStats(list[STATEMENT] Stats){                                        
//  if(size(Stats) == 1)
//     return cflowStat(Stats[0]);
//  CF1 = cflowStat(Stats[0]);
//  CF2 = cflowStats(tail(Stats));
//  return < CF1.entry, CF1.graph + CF2.graph + (CF1.exit * CF2.entry), CF2.exit >;
//}


CFGraph cflowStat(e:expressionStatement(Expression stmt)) {                                
   S = statement(e@src, e);
   return <{S}, {}, {S}>;
}

CFGraph cflowStat(d:declarationStatement(Declaration declaration)) {                                
   S = statement(d@src, d);
   return <{S}, {}, {S}>;
}

CFGraph cflowStat(\if(Expression condition, Statement thenBranch, Statement elseBranch)) {                    
	CF1 = cflowStat(thenBranch); 
	CF2 = cflowStat(elseBranch); 
	E = {choice(condition@src, condition)}; 
	return < E, (E * CF1.entry) + (E * CF2.entry) + CF1.graph + CF2.graph, CF1.exit + CF2.exit >;
}

CFGraph cflowStat(do(Statement body, Expression condition)) {                    
	CF = cflowStat(body); 
   	E = {choice(condition@src, condition)}; 
   	return < E, (E * CF.entry) + CF.graph + (CF.exit * E), E >;
}

CFGraph cflowStat(block(list[Statement] statements)){
	if(size(statements) == 1) {
     	return cflowStat(statements[0]);
  	}
  	CF1 = cflowStat(statements[0]);
  	CF2 = cflowStats(tail(statements));
  	return < CF1.entry, CF1.graph + CF2.graph + (CF1.exit * CF2.entry), CF2.exit >;
}

CFGraph cflowStats(list[Statement] statements){
	if(size(statements) == 1) {
     	return cflowStat(statements[0]);
  	}
  	CF1 = cflowStat(statements[0]);
  	CF2 = cflowStats(tail(statements));
  	return < CF1.entry, CF1.graph + CF2.graph + (CF1.exit * CF2.entry), CF2.exit >;
}

//Might need another one as there are 2 methods
public CFGraph cflowMethod(Declaration D){                                           
	if(method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl) := D){
		iprintln(name);
		CF = cflowStat(impl);
		Entry = entry(D@src);
		Exit  = exit();
		return <{Entry}, ({Entry} * CF.entry) + CF.graph + (CF.exit * {Exit}), {Exit}>;
	} else
    	throw "Cannot happen";
}



public CFGraph cflowProgram(PROGRAM P){                                           
  if(program(list[DECL] Decls, list[STATEMENT] Series) := P){
     CF = cflowStats(Series);
     Entry = entry(P@location);
     Exit  = exit();
     return <{Entry}, ({Entry} * CF.entry) + CF.graph + (CF.exit * {Exit}), {Exit}>;
  } else
    throw "Cannot happen";
}

//  Convert expressions into text


str make(natCon(int N)) = "<N>";
str make(strCon(str S)) = S;
str make(demo::lang::Pico::Abstract::id(PicoId Id)) = Id;
str make(add(EXP E1, EXP E2)) = "<make(E1)> + <make(E2)>";
str make(sub(EXP E1, EXP E2)) = "<make(E1)> - <make(E2)>";
str make(conc(EXP E1, EXP E2)) = "<make(E1)> || <make(E2)>";

//  Add an editor to a node

FProperty editIt(CFNode n) =
   (n has location) ? onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers){ edit(n.location,[]); return true;})
                    : onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {return false;});
        
//  Visualize one CFG node

Figure visNode(CFNode n:entry(loc location)) = 
       box(text("ENTRY"), vis::Figure::id(getId(n)), fillColor("red"), gap(4));

Figure visNode(CFNode n:exit()) = 
       box(text("EXIT"),  vis::Figure::id(getId(n)), fillColor("grey"), gap(4));

Figure visNode(CFNode n:choice(loc location, Expression exp)) = 
       ellipse(text("expression"),  vis::Figure::id(getId(n)), fillColor("yellow"), gap(8), editIt(n));

Figure visNode(CFNode n:statement(loc location, Statement statement)) =
        box(text("statement"),  vis::Figure::id(getId(n)), gap(8), editIt(n));

//  Define the id for each CFG node

str getId(entry(loc location)) = "ENTRY";
str getId(exit()) = "EXIT";
default str getId(CFNode n) = "<n.location>";

//  Visualize a complete CFG

public Figure visCFG(rel[CFNode, CFNode] CFGGraph){
       nodeSet = {};
       edges = [];
       for(< CFNode cf1, CFNode cf2> <- CFGGraph){
           nodeSet += {cf1, cf2};
           edges += edge(getId(cf1), getId(cf2), toArrow(triangle(5, fillColor("black"))));
       }
       
       for(n <- nodeSet){
			iprintln(n);
			visNode(n);       
       }
       nodes = [visNode(n) | n <- nodeSet];
       return graph(nodes, edges, hint("layered"), gap(20));
}