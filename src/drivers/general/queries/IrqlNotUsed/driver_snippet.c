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
VOID IrqlNotUsed_passAux(KIRQL inIrql, PKSPIN_LOCK myLock) {
    
    KeReleaseSpinLock(myLock, inIrql);
}

/* Passing case one.
   Function directly calls a function that restores IRQL. */
VOID IrqlNotUsed_pass(_IRQL_restores_ KIRQL inIrql, PKSPIN_LOCK myLock) {

    KeReleaseSpinLock(myLock, inIrql);

}

/* Passing case two.
   Function indirectly calls a function that restores IRQL. */ 
VOID IrqlNotUsed_pass2(_IRQL_restores_ KIRQL inIrql, PKSPIN_LOCK myLock) {

    IrqlNotUsed_passAux(inIrql, myLock);

}

/* Passing case three.
   Annotation is applied to a struct which is used to restore the IRQL. */
VOID IrqlNotUsed_pass3(_IRQL_restores_ PTestLock myLock) {

    KeReleaseSpinLock(&(myLock)->spinLock,(myLock)->inIrql);

}

/* Failing case one.
   Function does nothing with IRQL. */
VOID IrqlNotUsed_fail1(_IRQL_restores_ KIRQL inIrql, PKSPIN_LOCK myLock) {

}

/* Failing case two.
   Function has a path where the IRQL is not restored.
   This requires must-flow analysis. */
VOID IrqlNotUsed_fail2(_IRQL_restores_ KIRQL inIrql, PKSPIN_LOCK myLock, int testValue) {

    if (testValue > 15)  {KeReleaseSpinLock(myLock, inIrql); }
    else { }

}