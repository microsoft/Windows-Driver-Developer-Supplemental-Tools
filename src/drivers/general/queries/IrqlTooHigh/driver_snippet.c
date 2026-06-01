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

// =====================================================================
// Adversarial cases for `isInConstantFalseBranch` (Irql.qll).
//
// These cases ensure the predicate that suppresses calls inside
// `if (b)` for variables that look "constantly FALSE" does not
// accidentally drop legitimate findings when `b` is in fact mutated
// at runtime via:
//   - a compound assignment (|=, &=, +=, ...);
//   - an increment / decrement (++, --);
//   - a pass-by-reference helper that takes its address;
//   - a separate function (when `b` is a file-scope global).
//
// Each adversarial case below should be flagged as IRQL-too-high.
// =====================================================================

_IRQL_requires_(PASSIVE_LEVEL)
NTSTATUS PassiveOnly_TooHigh(void){
    return STATUS_SUCCESS;
}

static BOOLEAN g_DispatchSafe_TooHigh = FALSE;

void initialize_global_dispatch_safe_TooHigh(void){
    g_DispatchSafe_TooHigh = TRUE;
}

static void mutate_flag_by_pointer_TooHigh(PBOOLEAN pb){
    *pb = TRUE;
}

// Adversarial: `bFalse |= 1` is `AssignBitwiseOrExpr`, which
// extends `AssignOperation` and not `AssignExpr`.
void failForIrqlTooHigh_compoundAssignment(PKIRQL oldIrql){
    BOOLEAN bFalse = FALSE;
    bFalse |= 1;
    KeRaiseIrql(DISPATCH_LEVEL, oldIrql);
    if (bFalse) {
        PassiveOnly_TooHigh();
    }
    KeLowerIrql(*oldIrql);
}

// Adversarial: `bFalse++` is `CrementOperation`.
void failForIrqlTooHigh_increment(PKIRQL oldIrql){
    BOOLEAN bFalse = FALSE;
    bFalse++;
    KeRaiseIrql(DISPATCH_LEVEL, oldIrql);
    if (bFalse) {
        PassiveOnly_TooHigh();
    }
    KeLowerIrql(*oldIrql);
}

// Adversarial: variable mutated by reference; no AssignExpr to
// `bFalse` exists in this function.
void failForIrqlTooHigh_byReference(PKIRQL oldIrql){
    BOOLEAN bFalse = FALSE;
    mutate_flag_by_pointer_TooHigh(&bFalse);
    KeRaiseIrql(DISPATCH_LEVEL, oldIrql);
    if (bFalse) {
        PassiveOnly_TooHigh();
    }
    KeLowerIrql(*oldIrql);
}

// Adversarial: file-scope global, reassigned only from other
// functions.  A naive intra-function-only mutation check would
// fail to see the reassignment in the initialiser routine and
// silently drop the finding.
void failForIrqlTooHigh_globalReassigned(PKIRQL oldIrql){
    KeRaiseIrql(DISPATCH_LEVEL, oldIrql);
    if (g_DispatchSafe_TooHigh) {
        PassiveOnly_TooHigh();
    }
    KeLowerIrql(*oldIrql);
}