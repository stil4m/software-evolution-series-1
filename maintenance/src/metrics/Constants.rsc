module metrics::Constants

data Risk = low() | moderate() | high() | veryHigh();

alias RiskProfile = map[Risk risk, int LOC];

data Rating = plusPlus() | plus() | neutral() | minus() | minusMinus();

