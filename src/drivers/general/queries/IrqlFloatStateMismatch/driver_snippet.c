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
