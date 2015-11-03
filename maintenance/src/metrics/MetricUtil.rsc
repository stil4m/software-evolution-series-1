module metrics::MetricUtil

import util::Math;
import metrics::Constants;

public Rating riskProfileToRating(RiskProfile riskProfile, int totalLOC) {
	real moderate = toReal(riskProfile[moderate()] ? 0) / totalLOC;
	real high = toReal(riskProfile[high()] ? 0) / totalLOC;
	real veryHigh = toReal(riskProfile[veryHigh()] ? 0) / totalLOC;
	
	if (moderate <= 0.25 && high == 0 && veryHigh == 0) {
		return plusPlus();
	} else if (moderate <= 0.3 && high <= 0.05 && veryHigh == 0) {
		return plus();
	} else if (moderate <= 0.4 && high <= 0.1 && veryHigh == 0) {
		return neutral();
	} else if (moderate <= 0.5 && high <= 0.15 && veryHigh <= 0.05) {
		return minus();
	} else {
		return minusMinus();
	}
}

// MinusMinus
test bool createRatingMinusMinus1() = riskProfileToRating((veryHigh():6),100) == minusMinus();

// Minus
test bool createRatingMinus1() = riskProfileToRating((moderate():20,veryHigh():5),100) == minus();
test bool createRatingMinus2() = riskProfileToRating((moderate():50),100) == minus();

// Neutral 
test bool createRatingNeutral1() = riskProfileToRating((moderate():20, high():9),100) == neutral();
test bool createRatingNeutral2() = riskProfileToRating((moderate():40, high():5),100) == neutral();

// Plus
test bool createRatingPlus1() = riskProfileToRating((moderate():26, high():0),100) == plus();
test bool createRatingPlus2() = riskProfileToRating((moderate():30, high():5),100) == plus();

// PlusPlus
test bool createRatingPlusPlus1() = riskProfileToRating((moderate():0),100) == plusPlus();
test bool createRatingPlusPlus2() = riskProfileToRating((moderate():25),100) == plusPlus();
test bool createRatingPlusPlus3() = riskProfileToRating((moderate():20),100) == plusPlus();