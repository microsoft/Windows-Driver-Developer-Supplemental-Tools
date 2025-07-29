// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}


void fail1(PKIRQL oldIrql)
{

    if (oldIrql == PASSIVE_LEVEL)
    {
        KeLowerIrql(*oldIrql);
    }
    else
    {
        KeRaiseIrql(DISPATCH_LEVEL, oldIrql); // Function exits at DISPATCH_LEVEL
    }
}

_IRQL_raises_(DISPATCH_LEVEL)
void pass(PKIRQL oldIrql)
{

    if (oldIrql == PASSIVE_LEVEL)
    {
        KeLowerIrql(*oldIrql);
    }
    KeRaiseIrql(DISPATCH_LEVEL, oldIrql); // Function exits at DISPATCH_LEVEL
}