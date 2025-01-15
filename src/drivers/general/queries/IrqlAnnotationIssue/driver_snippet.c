// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1
#include <wdm.h>

// Template function. Not used for this test.
void top_level_call()
{
}

_IRQL_requires_(DISPATCH_LEVEL)
    VOID DoNothing_RequiresDispatch(void)
{
    __noop;
}
_IRQL_raises_(DISPATCH_LEVEL)
    VOID IrqlRaiseLevelExplicit_pass(void)
{
    KIRQL oldIRQL;
    KeRaiseIrql(APC_LEVEL, &oldIRQL);      // Raise level
    KeRaiseIrql(DISPATCH_LEVEL, &oldIRQL); // Raise level again
    // Function Exits at DISPATCH_LEVEL
}
_IRQL_always_function_max_(PASSIVE_LEVEL)
    VOID IrqlRaiseLevelExplicit_pass2(void)
{
       __noop;
}


// Mistakes in IRQL annotations

int irql = 1;

_IRQL_requires_(65)
    VOID DoNothing_RequiresDispatch2(void)
{
    __noop;
}
_IRQL_raises_(-1)
    VOID IrqlRaiseLevelExplicit_fail(void)
{
    KIRQL oldIRQL;
    KeRaiseIrql(APC_LEVEL, &oldIRQL);      // Raise level
    KeRaiseIrql(DISPATCH_LEVEL, &oldIRQL); // Raise level again
    // Function Exits at DISPATCH_LEVEL
}
_IRQL_always_function_max_(irql)
    VOID IrqlRaiseLevelExplicit_fail2(void)
{
    KIRQL oldIRQL;
    KeRaiseIrql(DISPATCH_LEVEL, &oldIRQL);
}


// TODO add tests for query