// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1

typedef struct _TestLock {
    KIRQL inIrql;
    KSPIN_LOCK spinLock;
} TestLock, * PTestLock;

// Template. Not called in this test.
void top_level_call() {}

/* Auxillary function used in passing.
   Note that even though this function doesn't annotate KIRQL,
   it restores the IRQL correctly. */
VOID IrqlNotSaved_passAux(KIRQL outIrqlPassAux) {
    
    KeRaiseIrql(KeGetCurrentIrql(), &outIrqlPassAux);
}

/* Passing case one.
   Function directly calls a function that saves IRQL. */
VOID IrqlNotSaved_pass(_IRQL_saves_ KIRQL outIrqlPass, PKSPIN_LOCK myLock) {

    KeAcquireSpinLock(myLock, &outIrqlPass);

}

/* Passing case two.
   Function indirectly calls a function that saves IRQL. */
VOID IrqlNotSaved_pass2(_IRQL_saves_ KIRQL outIrqlPass2, PKSPIN_LOCK myLock) {

    IrqlNotSaved_passAux(outIrqlPass2);

}

/* Passing case three.
   Annotation is applied to a struct which is used to restore the IRQL. */
VOID IrqlNotSaved_pass3(_IRQL_saves_ PTestLock myLock) {

    KeAcquireSpinLock(&(myLock)->spinLock,&(myLock)->inIrql);

}

/* Failing case one.
   Function does nothing with IRQL. */
VOID IrqlNotSaved_fail1(_IRQL_saves_ KIRQL outIrqlFail, PKSPIN_LOCK myLock) {

}

/* Failing case two.
   Function has a path where the IRQL is not saved.
   This requires must-flow analysis. */
VOID IrqlNotSaved_fail2(_IRQL_saves_ KIRQL outIrqlFail2, PKSPIN_LOCK myLock, int testValue) {

    if (testValue > 15)  {KeRaiseIrql(KeGetCurrentIrql(), &outIrqlFail2); }
    else { }

}