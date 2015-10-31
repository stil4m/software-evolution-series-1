module Domain

data Risk = low() | moderate() | high() | veryHigh();

data Rating = plusPlus() | plus() | neutral() | minus() | minusMinus();

alias RiskProfile = map[Risk,int];

alias MethodAnalysis = tuple[int,int,loc];

alias ClassAnalysis = list[MethodAnalysis];

alias FileAnalysis = tuple[int, list[ClassAnalysis], loc];

alias ProjectAnalysis = list[FileAnalysis];