module metrics::Constants

data Risk = low() | moderate() | high() | veryHigh();

data Rating = plusPlus() | plus() | neutral() | minus() | minusMinus();

alias RiskProfile = map[Risk,int];