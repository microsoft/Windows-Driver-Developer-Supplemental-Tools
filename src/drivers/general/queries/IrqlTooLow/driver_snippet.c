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

// =====================================================================
// Adversarial cases for `isInConstantFalseBranch` (Irql.qll).
//
// Symmetric to the IrqlTooHigh cases: the enclosing function is
// at PASSIVE_LEVEL but the call inside `if (b)` requires
// DISPATCH_LEVEL.  The predicate suppresses these calls because
// the variable looks constantly FALSE, even when in fact it has
// been mutated through a compound assignment, an increment, a
// pass-by-reference helper, or in a separate function (for a
// global).
// =====================================================================

_IRQL_requires_(DISPATCH_LEVEL)
NTSTATUS DispatchOnly_TooLow(void){
    return STATUS_SUCCESS;
}

static BOOLEAN g_DispatchSafe_TooLow = FALSE;

void initialize_global_dispatch_safe_TooLow(void){
    g_DispatchSafe_TooLow = TRUE;
}

static void mutate_flag_by_pointer_TooLow(PBOOLEAN pb){
    *pb = TRUE;
}

_IRQL_requires_(PASSIVE_LEVEL)
void failForIrqlTooLow_compoundAssignment(void){
    BOOLEAN bFalse = FALSE;
    bFalse |= 1;
    if (bFalse) {
        DispatchOnly_TooLow();
    }
}

_IRQL_requires_(PASSIVE_LEVEL)
void failForIrqlTooLow_increment(void){
    BOOLEAN bFalse = FALSE;
    bFalse++;
    if (bFalse) {
        DispatchOnly_TooLow();
    }
}

_IRQL_requires_(PASSIVE_LEVEL)
void failForIrqlTooLow_byReference(void){
    BOOLEAN bFalse = FALSE;
    mutate_flag_by_pointer_TooLow(&bFalse);
    if (bFalse) {
        DispatchOnly_TooLow();
    }
}

_IRQL_requires_(PASSIVE_LEVEL)
void failForIrqlTooLow_globalReassigned(void){
    if (g_DispatchSafe_TooLow) {
        DispatchOnly_TooLow();
    }
}