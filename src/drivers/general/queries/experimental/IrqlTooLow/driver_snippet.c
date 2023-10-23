// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

//Macros to enable or disable a code section that may or maynot conflict with this test.
#define SET_DISPATCH 1

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