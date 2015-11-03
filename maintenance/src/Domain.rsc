module Domain

data Risk = low() | moderate() | high() | veryHigh();

data Rating = plusPlus() | plus() | neutral() | minus() | minusMinus();

alias RiskProfile = map[Risk,int];

alias MethodAnalysis = tuple[int size, int cc, loc location];

alias ClassAnalysis = tuple[list[MethodAnalysis] methods, bool inner, loc location];

alias FileAnalysis = tuple[int LOC, list[ClassAnalysis] classes, lrel[int,str] lines, loc location];

alias ProjectAnalysis = list[FileAnalysis];