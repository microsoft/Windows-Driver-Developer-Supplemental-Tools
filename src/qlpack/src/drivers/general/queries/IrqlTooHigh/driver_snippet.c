// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

//Macros to enable or disable a code section that may or maynot conflict with this test.
#define SET_DISPATCH 1
#define IRQL_CHECK 1

void top_level_call(){
}

_IRQL_requires_(DISPATCH_LEVEL) 
NTSTATUS TestInner3(){
    return STATUS_SUCCESS;
}

_IRQL_requires_(PASSIVE_LEVEL) 
NTSTATUS TestInner4(){
    return STATUS_SUCCESS;
}

NTSTATUS someFunc(){
    return TestInner3();
}

_IRQL_requires_(APC_LEVEL) 
NTSTATUS TestInner2(){
    NTSTATUS status, unused;

    /*
    The call below, someFunc() represents a failing case for IrqlTooLow function as it is in a call is made in a PASSIVE_LEVEL to a function that requres APC_LEVEL, aka TestInner3().
    */
    status = someFunc();
    /*
    The call below, TestInner4() represents a passing case for IrqlTooLow() as the Irql level of caller is not less than the Irql level of called function.
    */
    unused = TestInner4();
    return status;
}

_Check_return_
NTSTATUS TestInner1(){
    return TestInner2();
}

NTSTATUS
IrqlLowTestFunction(){
    return TestInner1();
}

_Must_inspect_result_
_IRQL_requires_(DISPATCH_LEVEL) 
NTSTATUS
IrqlHighTestFunction(){
    return STATUS_SUCCESS;
}

void 
failForIrqlTooHigh(PKIRQL oldIrql){
    KeRaiseIrql(DISPATCH_LEVEL, oldIrql);
    /*
    The call below, IrqlLowTestFunction() represents a failing case for IrqlTooHigh function as it is in a call is made in a DISPATCH_LEVEL to a call that contains two subsequent child calls in it with lower IRQL level. 
    */
    IrqlLowTestFunction();
}

NTSTATUS 
passForIrqlTooHigh(PKIRQL oldIrql){
    NTSTATUS status;
    KeRaiseIrql(DISPATCH_LEVEL, oldIrql);
    /*
    The call below, IrqlHighTestFunction() represents a passing case for IrqlTooHigh check.
    */
    status = IrqlHighTestFunction();
    KeLowerIrql(*oldIrql);
    return status;
}