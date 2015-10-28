module metrics::java::LOC2



public void calculateLOC(M3 v) {
	set[loc] cu = { e.lhs | tuple[loc lhs, loc _] e <- v@containment, isCompilationUnit(e.lhs)} +
					{ e.rhs | tuple[loc _, loc rhs] e <- v@containment, isCompilationUnit(e.rhs)};

	for (c <- cu) {
		println(c.file);
		Declaration ast = createAstFromFile(c, true, Version="1.7");
		println("  -  <findLines(ast)>");
		return;
	}
}

public set[int] findLines(Declaration t) {
	set[int] lns = {};
	
	visit (t) {
		case (Expression) s: {
			lns += s@src.end.line;
		}
		case (Statement) s : {
			lns += s@src.end.line;
		}
		case Declaration s : {
			map[str,value] ans = getAnnotations(s);
			if (ans["src"]? && loc l := ans["src"]) {
				lns += l.end.line;
				println(l.end.line);
			}
		}
		case (Modifier) s : {
			lns += s@src.end.line;
		}
		case (Type) s : {
			map[str,value] ans = getAnnotations(s);
			if (ans["src"]? && loc l := ans["src"]) {
				lns += l.end.line;
			}
		}
	}
	return lns;
}