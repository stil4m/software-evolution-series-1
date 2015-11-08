module profiling::UnitSizeTest

import profiling::UnitSize;
import Domain;

test bool shouldGetRiskProfileLow1() = getUnitSizeRisk(0) == low();
test bool shouldGetRiskProfileLow2() = getUnitSizeRisk(20) == low();

test bool shouldGetRiskProfileModerate1() = getUnitSizeRisk(21) == moderate();
test bool shouldGetRiskProfileModerate2() = getUnitSizeRisk(50) == moderate();

test bool shouldGetRiskProfileHigh1() = getUnitSizeRisk(51) == high();
test bool shouldGetRiskProfileHigh2() = getUnitSizeRisk(100) == high();

test bool shouldGetRiskProfileVeryHigh() = getUnitSizeRisk(101) == veryHigh();