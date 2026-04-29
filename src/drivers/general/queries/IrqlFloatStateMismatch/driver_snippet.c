// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}

_IRQL_requires_(PASSIVE_LEVEL) 
void driver_utility_bad(void)
{
    KIRQL oldIRQL;
    KeRaiseIrql(APC_LEVEL, &oldIRQL);
    // running at APC level
    KFLOATING_SAVE FloatBuf;
    if (KeSaveFloatingPointState(&FloatBuf))
    {
        KeLowerIrql(oldIRQL); // lower back to PASSIVE_LEVEL
        // ...
        KeRestoreFloatingPointState(&FloatBuf);
    }
}

_IRQL_requires_(PASSIVE_LEVEL) 
void driver_utility_good(void)
{
    // running at APC level
    KFLOATING_SAVE FloatBuf;
    KIRQL oldIRQL;
    KeRaiseIrql(APC_LEVEL, &oldIRQL);

    if (KeSaveFloatingPointState(&FloatBuf))
    {
        KeLowerIrql(oldIRQL);
        // ...
        KeRaiseIrql(APC_LEVEL, &oldIRQL);
        KeRestoreFloatingPointState(&FloatBuf);
    }
}

// An unannotated helper that nonetheless changes the IRQL.  Real drivers
// frequently wrap KeLowerIrql / KeRaiseIrql calls in helpers without the
// _IRQL_raises_ / _IRQL_requires_same_ annotations.
static void unannotated_lower_helper(KIRQL oldIRQL)
{
    KeLowerIrql(oldIRQL);
}

// Adversarial: the IRQL transition between save and restore happens inside
// an unannotated helper rather than directly in the enclosing function.
// A purely intraprocedural check that only inspects calls in the enclosing
// function will miss this true positive.
_IRQL_requires_(PASSIVE_LEVEL)
void driver_utility_helper_bad(void)
{
    KIRQL oldIRQL;
    KeRaiseIrql(APC_LEVEL, &oldIRQL);
    KFLOATING_SAVE FloatBuf;
    if (KeSaveFloatingPointState(&FloatBuf))
    {
        unannotated_lower_helper(oldIRQL);
        // ...
        KeRestoreFloatingPointState(&FloatBuf);
    }
}

// Regression guard: same as `driver_utility_good`, except the
// re-raising IRQL transition is performed inside a nested block.
// A correct check still recognises the in-function IRQL change and
// suppresses no finding here.
_IRQL_requires_(PASSIVE_LEVEL)
void driver_utility_nested_block_good(void)
{
    KFLOATING_SAVE FloatBuf;
    KIRQL oldIRQL;
    KeRaiseIrql(APC_LEVEL, &oldIRQL);

    if (KeSaveFloatingPointState(&FloatBuf))
    {
        KeLowerIrql(oldIRQL);
        {
            // nested compound statement
            KeRaiseIrql(APC_LEVEL, &oldIRQL);
        }
        KeRestoreFloatingPointState(&FloatBuf);
    }
}

// =====================================================================
// Adversarial: cross-function save / restore via thin wrappers.
//
// `irqlChangesBetween` requires `saveCall` and `restoreCall` to
// share an enclosing function, so when the save and the restore
// are routed through helper wrappers and the IRQL change happens
// in the caller, the source-position filter never finds a `mid`
// candidate.  No finding is produced even though the IRQL at the
// save (PASSIVE_LEVEL) differs from the IRQL at the restore
// (DISPATCH_LEVEL).  This is a known false negative of the
// current intraprocedural filter.
// =====================================================================

static void save_fp_helper(PKFLOATING_SAVE pfs)
{
    KeSaveFloatingPointState(pfs);
}

static void restore_fp_helper(PKFLOATING_SAVE pfs)
{
    KeRestoreFloatingPointState(pfs);
}

_IRQL_requires_(PASSIVE_LEVEL)
void driver_utility_cross_function_bad(void)
{
    KFLOATING_SAVE FloatBuf;
    KIRQL oldIRQL;

    save_fp_helper(&FloatBuf);
    KeRaiseIrql(DISPATCH_LEVEL, &oldIRQL);
    // ... do work at DISPATCH ...
    restore_fp_helper(&FloatBuf);
    KeLowerIrql(oldIRQL);
}
