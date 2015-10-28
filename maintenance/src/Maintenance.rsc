module Maintenance

import lang::java::jdt::m3::Core;
import metrics::java::UnitSize;
import metrics::java::LOC;
import metrics::Constants;
import IO;

public value main() {
	m3Model = createM3FromEclipseProject(|project://hello-world-java|);
	
	map[str,Rating] result = ();;
	result + ("UnitSize":calculateUnitSize(m3Model)); 
	iprintln(calculateLOC(m3Model));
		
	return result;
}
