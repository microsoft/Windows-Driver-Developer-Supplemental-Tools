// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or maynot conflict with this test.
#define SET_DISPATCH 1

void top_level_call()
{
}

_IRQL_requires_same_ void fail1(PKIRQL oldIrql)
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

_IRQL_requires_same_
    NTSTATUS
    pass1(PKIRQL oldIrql)
{
    KeRaiseIrql(DISPATCH_LEVEL, oldIrql);
    KeLowerIrql(*oldIrql);
    return STATUS_SUCCESS;
}