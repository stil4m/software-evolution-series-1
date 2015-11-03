module Domain

alias RiskProfile = map[Risk,int];

alias MethodAnalysis = tuple[int LOC, int cc, loc location];

alias ClassAnalysis = tuple[list[MethodAnalysis] methods, bool inner, loc location];

alias FileAnalysis = tuple[int LOC, list[ClassAnalysis] classes, lrel[int,str] lines, loc location];

alias ProjectAnalysis = tuple[int LOC,list[FileAnalysis] files];

alias RiskProfile = map[Risk, int];

data Profile = plusPlus() | plus() | neutral() | minus() | minusMinus();

data Risk = low() | moderate() | high() | veryHigh();