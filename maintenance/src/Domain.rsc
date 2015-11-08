module Domain

alias RiskProfile = map[Risk, int];

alias ProfileData = map[str, value];

data Profile = plusPlus(ProfileData profileData) 
			| plus(ProfileData profileData) 
			| neutral(ProfileData profileData) 
			| minus(ProfileData profileData) 
			| minusMinus(ProfileData profileData);

data Risk = low() | moderate() | high() | veryHigh();

data MethodAnalysis = methodAnalysis(int LOC, int cc, bool isTest, loc location);

data ClassAnalysis = classAnalysis(list[MethodAnalysis] methods, bool inner, loc location);

data EffectiveLine = effectiveLine(int number, str content);

data FileAnalysis = fileAnalysis(int LOC, list[ClassAnalysis] classes, list[EffectiveLine] lines, bool containsTestClass, loc location);

data ProjectAnalysis = projectAnalysis(int LOC, list[FileAnalysis] files);