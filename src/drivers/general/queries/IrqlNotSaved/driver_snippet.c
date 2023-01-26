// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1

// Template. Not called in this test.
void top_level_call() {}

// Auxilliary function used in passing.
// Note that even thoough this function doesn't annotate KIRQL,
// it restores the IRQL correctly.
VOID IrqlNotSaved_passAux(KIRQL outIrql) {
    
    KeRaiseIrql(KeGetCurrentIrql(), &outIrql);
}

// Passing case one.
// Function directly calls a function that saves IRQL.
VOID IrqlNotSaved_pass(_IRQL_saves_ KIRQL outIrql, PKSPIN_LOCK myLock) {

    KeRaiseIrql(KeGetCurrentIrql(), &outIrql);

}

// Passing case two.
// Function indirectly calls a function that saves IRQL.
VOID IrqlNotSaved_pass2(_IRQL_saves_ KIRQL outIrql, PKSPIN_LOCK myLock) {

    IrqlNotSaved_passAux(outIrql);

}

// Failing case one.
// Function does nothing with IRQL.
VOID IrqlNotSaved_fail1(_IRQL_saves_ KIRQL outIrql, PKSPIN_LOCK myLock) {

}

// Failing case two.
// Function has a path where the IRQL is not saved.
// This requies must-flow analysis.
VOID IrqlNotSaved_fail2(_IRQL_saves_ KIRQL outIrql, PKSPIN_LOCK myLock, int testValue) {

    if (testValue > 15)  {KeRaiseIrql(KeGetCurrentIrql(), &outIrql); }
    else { }

}