module Domain

alias RiskProfile = map[Risk, int];

alias ProfileData = map[str, value];

data Profile = plusPlus(ProfileData) 
			| plus(ProfileData) 
			| neutral(ProfileData) 
			| minus(ProfileData) 
			| minusMinus(ProfileData);

data Risk = low() | moderate() | high() | veryHigh();

data MethodAnalysis = methodAnalysis(int LOC, int cc, loc location);

data ClassAnalysis = classAnalysis(list[MethodAnalysis] methods, bool inner, loc location);

data EffectiveLine = effectiveLine(int number, str content);

data FileAnalysis = fileAnalysis(int LOC, list[ClassAnalysis] classes, list[EffectiveLine] lines, loc location);

data ProjectAnalysis = projectAnalysis(int LOC, list[FileAnalysis] files);