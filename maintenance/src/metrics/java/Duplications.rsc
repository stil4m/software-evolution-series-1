module metrics::java::Duplications

 
import Domain;
import IO;

alias LineRef = lrel[loc, int];

public void computeDuplications(ProjectAnalysis p) {
	
	map[str,LineRef] db = ();
	
	for(FileAnalysis f <- p) {
		<LOC, clss, lines, l> = f;	
		println(lines);
	}
}