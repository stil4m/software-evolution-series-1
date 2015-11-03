module profiling::ProfilingUtilTest

import profiling::ProfilingUtil;
import Domain;

// MinusMinus
test bool shouldCreateMinusMinus1() = minusMinus(_) := convertToProfile((veryHigh():6),100);

// Minus
test bool shouldCreateMinus1() = minus(_) := convertToProfile((moderate():20,veryHigh():5),100);
test bool shouldCreateMinus2() = minus(_) := convertToProfile((moderate():50),100);

// Neutral
test bool shouldCreateNeutral1() = neutral(_) := convertToProfile((moderate():20, high():9),100);
test bool shouldCreateNeutral2() = neutral(_) := convertToProfile((moderate():40, high():5),100);

// Plus
test bool shouldCreatePlus1() = plus(_) := convertToProfile((moderate():26, high():0),100);
test bool shouldCreatePlus2() = plus(_) := convertToProfile((moderate():30, high():5),100);

// PlusPlus
test bool shouldCreatePlusPlus1() = plusPlus(_) := convertToProfile((moderate():0),100);
test bool shouldCreatePlusPlus2() = plusPlus(_) := convertToProfile((moderate():25),100);
test bool shouldCreatePlusPlus3() = plusPlus(_) := convertToProfile((moderate():20),100);