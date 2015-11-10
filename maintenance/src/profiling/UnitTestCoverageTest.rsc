module profiling::UnitTestCoverageTest

import IO;

import TestUtil;
import Domain;

import profiling::UnitTestCoverage;

test bool testUnitTestCoverage() = minusMinus(("very_high":126,"low":15)) == profileUnitTestCoverage(getProjectAnalysis(), getTestM3());