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
Call a function which should always be min DISPATCH_LEVEL but takes in an argument set to APC_LEVEL
*/
_IRQL_always_function_min_(DISPATCH_LEVEL)
    VOID IrqlMinDispatchLowerIrql_fail(KIRQL *oldIRQL)
{
    KeLowerIrql(*oldIRQL);
}

VOID IrqlLowerWithFunctionCall(void)
{
    KIRQL oldIRQL;
    KeRaiseIrql(APC_LEVEL, &oldIRQL);
    IrqlMinDispatchLowerIrql_fail(&oldIRQL);
}

/*
Call a function which should always be min DISPATCH_LEVEL but takes in an argument set to APC_LEVEL
*/
_IRQL_always_function_min_(DISPATCH_LEVEL)
    VOID IrqlMinDispatchLowerIrql_fail1(KIRQL *oldIRQL)
{
    KeLowerIrql(*oldIRQL); 
}

VOID IrqlLowerWithFunctionCall1(void)
{
    KIRQL oldIRQL;
    KeRaiseIrql(APC_LEVEL, &oldIRQL);
    KeRaiseIrql(DISPATCH_LEVEL, &oldIRQL); // oldIRQL should be APC_LEVEL
    IrqlMinDispatchLowerIrql_fail1(&oldIRQL); 
}


/*
Call a function which should always be min APC_LEVEL that takes in an argument set to DISPATCH_LEVEL
*/
_IRQL_always_function_min_(APC_LEVEL)
    VOID IrqlMinAPCLowerIrql(KIRQL *oldIRQL)
{
    KeLowerIrql(*oldIRQL);
}

VOID IrqlLowerWithFunctionCall_pass(void)
{
    KIRQL oldIRQL;
    KeRaiseIrql(APC_LEVEL, &oldIRQL);
    KeRaiseIrql(DISPATCH_LEVEL, &oldIRQL); // oldIRQL should be APC_LEVEL
    IrqlMinAPCLowerIrql(&oldIRQL);
}

/* Set IRQL to PASSIVE_LEVEL inside function which is min APC_LEVEL*/
_IRQL_always_function_min_(APC_LEVEL)
    VOID IrqlAlwaysMinAPC_fail(KIRQL *oldIRQL)
{
    KeLowerIrql(*oldIRQL); // lowers to PASSIVE_LEVEL which is lower than APC_LEVEL
}

VOID IrqlCallAlwaysMinAPC(void)
{
    KIRQL oldIRQL;
    KeRaiseIrql(APC_LEVEL, &oldIRQL);
    IrqlAlwaysMinAPC_fail(&oldIRQL); // oldIRQL should be PASSIVE_LEVEL
}

_IRQL_requires_same_
    VOID
    IrqlReqSame_pass(void)
{
    KIRQL oldIRQL;
    KeRaiseIrql(APC_LEVEL, &oldIRQL);
    KeLowerIrql(oldIRQL);
}

/*
Requires same but lowers IRQL
*/
_IRQL_requires_same_
    VOID
    IrqlReqSame_fail(KIRQL *oldIRQL)
{
    KeLowerIrql(*oldIRQL);
}

VOID IrqlCallReqSame(void)
{
     KIRQL oldIRQL;
    KeRaiseIrql(APC_LEVEL, &oldIRQL);
    IrqlReqSame_fail(&oldIRQL); // oldIRQL should be APC_LEVEL
}
