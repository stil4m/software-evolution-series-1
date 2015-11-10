module profiling::UnitTestQualityTest

import TestUtil;
import Domain;

import profiling::UnitTestQuality;

test bool testUnitTestQuality() = minusMinus(("very_high":3,"low":22)) == profileUnitTestQuality(getProjectAnalysis());