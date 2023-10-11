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
Function which should only be called from min APC_LEVEL
*/
_IRQL_requires_min_(APC_LEVEL)
    VOID DoNothing_MinAPC(void)
{
    __noop;
}

/*
Function which should only be called from min DISPATCH_LEVEL
*/
_IRQL_requires_min_(DISPATCH_LEVEL)
    VOID DoNothing_MinDispatch(void)
{
    __noop;
}

/*
Function which should only be called from PASSIVE_LEVEL
*/
_IRQL_requires_(PASSIVE_LEVEL)
    VOID DoNothing_RequiresPassive(void)
{
    __noop;
}

/*
Function which should only be called from DISPATCH_LEVEL
*/
_IRQL_requires_(DISPATCH_LEVEL)
    VOID DoNothing_RequiresDispatch(void)
{
    __noop;
}

_IRQL_requires_min_(DISPATCH_LEVEL)
    VOID IrqlSetLowerFromDispatch_pass0(void)
{
    KeLowerIrql(PASSIVE_LEVEL);
}

_IRQL_requires_min_(DISPATCH_LEVEL)
    VOID IrqlSetAPCFromDispatch_pass0(void)
{
    KeLowerIrql(APC_LEVEL);
}

/*
Function is annotated for min IRQL APC_LEVEL but lowers the IRQL
*/
_IRQL_always_function_min_(APC_LEVEL)
    VOID IrqlLowerLevelExplicit_fail1(void)
{
    KIRQL oldIRQL;
    oldIRQL = KeGetCurrentIrql();
    KeRaiseIrql(DISPATCH_LEVEL, &oldIRQL); // Raise above APC_LEVEL
    DoNothing_MinAPC();
    KeLowerIrql(PASSIVE_LEVEL); // Lower to PASSIVE_LEVEL, which is below the min IRQL
}
/*
Function is annotated for min IRQL APC_LEVEL but raises the IRQL and then lowers it.
*/
_IRQL_always_function_min_(APC_LEVEL)
    VOID IrqlLowerLevelExplicit_fail4(void)
{
    KIRQL oldIRQL;
    oldIRQL = KeGetCurrentIrql();
    KeRaiseIrql(DISPATCH_LEVEL, &oldIRQL);
    KeLowerIrql(PASSIVE_LEVEL);
}

/*
Function is annotated for min IRQL DISPATCH_LEVEL, but it lowers the IRQL to PASSIVE_LEVEL through another function call.
*/
_IRQL_always_function_min_(DISPATCH_LEVEL)
    VOID CallFunctionThatLowersIRQL_fail5(void)
{
    IrqlSetLowerFromDispatch_pass0();
}

/*
Function is annotated for require same, but it lowers the IRQL to APC_LEVEL through another function call after raising.
*/
_IRQL_requires_same_
    VOID
    CallFunctionThatLowersIRQL_fail6(void)
{
    KIRQL oldIRQL;
    oldIRQL = KeGetCurrentIrql();
    KeRaiseIrql(DISPATCH_LEVEL, &oldIRQL);
    IrqlSetAPCFromDispatch_pass0();
}

/*
Function is annotated for min IRQL PASSIVE_LEVEL and does not raise the IRQL
*/
_IRQL_always_function_min_(PASSIVE_LEVEL)
    VOID IrqlDontChange_pass(void)
{
    KeLowerIrql(PASSIVE_LEVEL);
}

/*
Function must enter and exit at the same IRQL, but raises and does not lower the IRQL fully
*/
_IRQL_requires_same_
    VOID
    IrqlRequiresSame_fail7(void)
{
    KIRQL oldIRQL;
    oldIRQL = KeGetCurrentIrql();

    KeRaiseIrql(DISPATCH_LEVEL, &oldIRQL);
    if (oldIRQL <= PASSIVE_LEVEL)
    {
        KeLowerIrql(APC_LEVEL);
    }
    else if (oldIRQL <= APC_LEVEL)
    {
        KeLowerIrql(PASSIVE_LEVEL);
    }
    else
    {
        KeLowerIrql(DISPATCH_LEVEL);
    }
}

/*
Function must enter and exit at the same IRQL, but raises and does not lower the IRQL
*/
_IRQL_requires_same_
    VOID
    IrqlRequiresSame_notsupported(void)
{
    KIRQL oldIRQL;
    oldIRQL = KeGetCurrentIrql();
    KeRaiseIrql(oldIRQL + 2, &oldIRQL);
    KeLowerIrql(oldIRQL + 1);
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

/*
Function that calls another function by reference which correctly lowers the IRQL.
This should pass since IrqlInderectCall_pass0 is not annotated for min IRQL.
*/
VOID IrqlInderectCall_pass0(void)
{
    void (*funcPtr)(void);
    KIRQL oldIRQL;
    oldIRQL = KeGetCurrentIrql();
    KeRaiseIrql(DISPATCH_LEVEL, &oldIRQL);
    funcPtr = &IrqlSetLowerFromDispatch_pass0;
    funcPtr();
}

/*
Function that calls another function by reference which correctly lowers the IRQL.
This should pass since IrqlInderectCall_pass0 is annotated for min PASSIVE_LEVEL.
*/
_IRQL_always_function_min_(PASSIVE_LEVEL)
    VOID IrqlInderectCall_pass1(void)
{
    void (*funcPtr)(void);
    funcPtr = &IrqlSetLowerFromDispatch_pass0;
    funcPtr();
}

/*
Function that calls another function by reference which incorrectly lowers the IRQL.
This should fail because the function pointer points to a function that should fail.
*/
VOID IrqlInderectCall_fail0(void)
{
    void (*funcPtr)(void);
    funcPtr = &IrqlLowerLevelExplicit_fail1;
    funcPtr();
}
/*
Function that calls another function by reference which incorrectly raises the IRQL.
This should fail because the function pointer points to a function that that raises the IRQL above PASSIVE_LEVEL.
*/
_IRQL_always_function_min_(PASSIVE_LEVEL)
    VOID IrqlInderectCall_fail1(void)
{
    void (*funcPtr)(void);
    funcPtr = &IrqlSetLowerFromDispatch_pass0;
    funcPtr();
}

// TODO multi-threaded tests
// function has max IRQL requirement, creates two threads where one is above that requirement and one is below
