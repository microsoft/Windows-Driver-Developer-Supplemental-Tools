// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1

// Template. Not called in this test.
void top_level_call() {}

#include <wdm.h>

/*
 */
_IRQL_raises_(DISPATCH_LEVEL)
    VOID IrqlRaiseLevelExplicit_fail(void)
{
    KIRQL oldIRQL;
    KeRaiseIrql(DISPATCH_LEVEL, &oldIRQL);
    KeRaiseIrql(PASSIVE_LEVEL, &oldIRQL); // raise the IRQL to PASSIVE_LEVEL, which is lower than DISPATCH_LEVEL
}
/*
Function can be called to raise the IRQL but needs to exit at DISPATCH_LEVEL.
*/
_IRQL_raises_(DISPATCH_LEVEL)
    VOID IrqlRaiseLevelExplicit_pass(void)
{
    KIRQL oldIRQL;
    KeRaiseIrql(DISPATCH_LEVEL, &oldIRQL);
    KeLowerIrql(oldIRQL);
}
