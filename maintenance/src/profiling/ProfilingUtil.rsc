module profiling::ProfilingUtil

import util::Math;
import List;
import IO;

import Domain;

public Profile convertToProfile(RiskProfile riskProfile, int totalLOC) {
	real moderate = toReal(riskProfile[moderate()] ? 0) / totalLOC;
	real high = toReal(riskProfile[high()] ? 0) / totalLOC;
	real veryHigh = toReal(riskProfile[veryHigh()] ? 0) / totalLOC;
	
	map[str,value] riskData = riskProfileToMap(riskProfile);
	
	if (moderate <= 0.25 && high == 0 && veryHigh == 0) return plusPlus(riskData);
	if (moderate <= 0.3 && high <= 0.05 && veryHigh == 0) return plus(riskData);
	if (moderate <= 0.4 && high <= 0.1 && veryHigh == 0) return neutral(riskData);
	if (moderate <= 0.5 && high <= 0.15 && veryHigh <= 0.05) return minus(riskData);
	return minusMinus(riskData);
}

private map[str,value] riskProfileToMap(RiskProfile riskProfile) {
	return (stringListKey(riskKey) : riskProfile[riskKey] | riskKey <- riskProfile);
}

private str stringListKey(low()) = "low";
private str stringListKey(moderate()) = "moderate";
private str stringListKey(high()) = "high";
private str stringListKey(veryHigh()) = "very_high";


public Profile mergeProfiles(lrel[str, Profile] profiles) {
	ProfileData result = ();
	
	iprintln(profiles);
	
	int newRating = round(( 0. | it + profileToInt(profile) | <_,profile> <- profiles) / size(profiles));
	ProfileData combinedProfileData = ( result | it + (subTitle : profile.profileData) | <subTitle, profile> <- profiles);
	
	return intToProfile(newRating, combinedProfileData);
}

private int profileToInt(minusMinus(_)) = 1;
private int profileToInt(minus(_)) = 2;
private int profileToInt(neutral(_)) = 3;
private int profileToInt(plus(_)) = 4;
private int profileToInt(plusPlus(_)) = 5;

private Profile intToProfile(1, ProfileData profileData) = minusMinus(profileData);
private Profile intToProfile(2, ProfileData profileData) = minus(profileData);
private Profile intToProfile(3, ProfileData profileData) = neutral(profileData);
private Profile intToProfile(4, ProfileData profileData) = plus(profileData);
private Profile intToProfile(5, ProfileData profileData) = plusPlus(profileData);


public Profile profileForValues(int m, int h, int vh, int total) = convertToProfile((
	moderate() : m,
	high() : h,
	veryHigh() : vh
), total);

test bool allLow()  = plusPlus(_) := profileForValues(0, 0, 0, 100);
test bool moderateExceedsThreshold1()  = plus(_) := profileForValues(26, 0, 0, 100);
test bool moderateExceedsThreshold2()  = neutral(_) := profileForValues(31, 0, 0, 100);
test bool moderateExceedsThreshold3()  = minus(_) := profileForValues(41, 0, 0, 100);
test bool moderateExceedsThreshold4()  = minusMinus(_) := profileForValues(51, 0, 0, 100);
test bool highExceedsThreshold1()  = plus(_) := profileForValues(0, 1, 0, 100);
test bool highExceedsThreshold2()  = neutral(_) := profileForValues(0, 6, 0, 100);
test bool highExceedsThreshold3()  = minus(_) := profileForValues(0, 11, 0, 100);
test bool highExceedsThreshold4()  = minusMinus(_) := profileForValues(0, 16, 0, 100);
test bool veryHighExceedsThreshold1()  = minus(_) := profileForValues(0, 0, 1, 100);
test bool veryHighExceedsThreshold2()  = minusMinus(_) := profileForValues(0, 0, 6, 100);

test bool takesWorst()  = minusMinus(_) := profileForValues(31, 11, 6, 100);