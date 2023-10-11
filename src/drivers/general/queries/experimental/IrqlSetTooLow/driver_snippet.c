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
IRQL values:
PASSIVE_LEVEL
APC_LEVEL
DISPATCH_LEVEL
DIRQL
*/

/*
_IRQL_requires_max_(irql)           //The irql is the maximum IRQL at which the function can be called.
_IRQL_requires_min_(irql)	        //The irql is the minimum IRQL at which the function can be called.
_IRQL_requires_(irql)	            //The function must be entered at the IRQL specified by irql.
_IRQL_raises_(irql)	                //The function exits at the specified irql, but it can only be called to raise (not lower) the current IRQL.
_IRQL_saves_	                    //The annotated parameter saves the current IRQL to restore later.
_IRQL_restores_	                    //The annotated parameter contains an IRQL value from IRQL_saves that is to be restored when the function returns.
_IRQL_saves_global_(kind, param)	//The current IRQL is saved into a location that is internal to the code analysis tools from which the IRQL is to be restored. This annotation is used to annotate a function. The location is identified by kind and further refined by param. For example, OldIrql could be the kind, and FastMutex could be the parameter that held that old IRQL value.
_IRQL_restores_global_(kind, param)	//The IRQL saved by the function annotated with IRQL_saves_global is restored from a location that is internal to the Code Analysis tools.
_IRQL_always_function_min_(value)	//The IRQL value is the minimum value to which the function can lower the IRQL.
_IRQL_always_function_max_(value)	//The IRQL value is the maximum value to which the function can raise the IRQL.
_IRQL_requires_same_	            //The annotated function must enter and exit at the same IRQL. The function can change the IRQL, but it must restore the IRQL to its original value before exiting.
_IRQL_uses_cancel_	                //The annotated parameter is the IRQL value that should be restored by a DRIVER_CANCEL callback function. In most cases, use the IRQL_is_cancel annotation instead.
*/

/*
Function which should only be called from PASSIVE_LEVEL
*/
_IRQL_requires_max_(PASSIVE_LEVEL)
    VOID DoNothing_Passive(void)
{
    __noop;
}

/*
Function which should only be called from DISPATCH_LEVEL
*/
_IRQL_requires_max_(DISPATCH_LEVEL)
    VOID DoNothing_Dispatch(void)
{
    __noop;
}

/*
Function which should only be called from DISPATCH_LEVEL but lowers the IRQL to PASSIVE_LEVEL
*/
_IRQL_requires_min_(DISPATCH_LEVEL)
    VOID IrqlSetLowerFromDispatch(void)
{
    KeLowerIrql(PASSIVE_LEVEL);
}

/*
Funciton which lowers the IRQL to PASSIVE_LEVEL and then calls a function which should only be called from DISPATCH_LEVEL
*/
VOID IrqlRaiseLevelExplicit_fail1(void)
{
    // Set IRQL to DISPATCH_LEVEL
    KeLowerIrql(PASSIVE_LEVEL);
    // Call a function at a lower IRQL than DISPATCH_LEVEL
    DoNothing_Dispatch();
}

/*
Function is entered at PASSIVE_LEVEL, but it raises the IRQL to DISPATCH_LEVEL.
This is allowed because _IRQL_raises_(PASSIVE_LEVEL) specifies that the function can only be called to raise (not lower) the current IRQL of PASSIVE_LEVEL.
*/
_IRQL_raises_(PASSIVE_LEVEL)
    VOID IrqlRaiseLevelExplicit_pass(void)
{
    KIRQL oldIRQL;
    oldIRQL = KeGetCurrentIrql();
    KeRaiseIrql(DISPATCH_LEVEL, &oldIRQL);
}

/*
Function specifies it must be called with max IRQL PASSIVE_LEVEL, but it raises the IRQL to DISPATCH_LEVEL through another function call.
*/
_IRQL_requires_max_(PASSIVE_LEVEL)
    VOID CallFunctionThatRaisesIRQL_fail(void)
{
    IrqlSetHigherFromPassive();
}

/*
Function is annotated for max IRQL PASSIVE_LEVEL but raises the IRQL
*/
_IRQL_always_function_max_(PASSIVE_LEVEL)
    VOID IrqlRaiseLevelExplicit_fail2(void)
{
    KIRQL oldIRQL;
    oldIRQL = KeGetCurrentIrql();
    KeRaiseIrql(DISPATCH_LEVEL, &oldIRQL);
}

/*
Function is annotated for max IRQL PASSIVE_LEVEL and does not raise the IRQL
*/
_IRQL_always_function_max_(PASSIVE_LEVEL)
    VOID IrqlDontChange_pass(void)
{
    DoNothing_Passive();
}

/*
Function must enter and exit at the same IRQL, but raises and does not lower the IRQL
*/
_IRQL_requires_same_
    VOID
    IrqlRequiresSame_fail(void)
{
    KIRQL oldIRQL;
    oldIRQL = KeGetCurrentIrql();
    KeRaiseIrql(DISPATCH_LEVEL, &oldIRQL);
}

/*
Funciton must enter and exit at the same IRQL. IRQL is set higher but then set lower before exiting.
*/
_IRQL_requires_same_
    VOID
    IrqlRequiresSame_pass(void)
{
    KIRQL oldIRQL;
    oldIRQL = KeGetCurrentIrql();
    KeRaiseIrql(DISPATCH_LEVEL, &oldIRQL);
    KeLowerIrql(oldIRQL);
}