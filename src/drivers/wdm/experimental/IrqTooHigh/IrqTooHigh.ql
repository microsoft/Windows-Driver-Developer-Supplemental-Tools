// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name IrqTooHigh
 * @kind problem
 * @description The function is not permitted to be called at the current IRQ level. The current level is too high.
 * @problem.severity error
 * @id cpp/portedqueries/irq-too-high
 * @platform Desktop
 * @repor.text The following line(s) potentially contains a function call that is supposed to be called at a higher Irql level.
 * @feature.area Multiple
 * @version 1.0
 */

import cpp
import drivers.libraries.Irql 

//Evaluates to true if KeLowerIrql call is made before a call to IrqlAnnotatedFunction is made
predicate preceedingKeLowerIrqlCall(CallsToIrqlAnnotatedFunction iafc) {
  exists(FunctionCall fc2, Function fc3 |
    iafc.getAPredecessor*() = fc2 and
    (
      fc2.getTarget().getName() = "KeLowerIrql"
      or
      fc2.getTarget().calls*(fc3) and fc3.getName() = "KeLowerIrql"
    )
  )
}

// Evaluates to true for FunctionCalls inside IrqlAnnotatedFunction where the call requires a lower Irql level
predicate irqlAnnotationViolatingCall(CallsToIrqlAnnotatedFunction ciaf) {
  exists(IrqlAnnotatedFunction iaf, int current, int called |
    ciaf.getEnclosingFunction() = iaf and
    iaf.getIrqlLevel() = current and
    getActualIrqlFunc(ciaf).getIrqlLevel() = called and
    current > called
  )
}

//Evaluates to true if there is a call from KeRaiseIrql to a IrqlAnnotatedFunction before any KeLowerIrql call in between.
predicate irqlNotLoweredCall(CallsToIrqlAnnotatedFunction fc) {
  exists(FunctionCall kr, int called, int current |
    kr.getASuccessor*() = fc and
    getActualIrqlFunc(fc).getIrqlLevel() = called and
    (
      kr.getTarget().getName().matches("KfRaiseIrql") and
      kr.getArgument(0).getValue().toInt() = current
      or
      kr.getTarget().getName().matches("KeRaiseIrqlToDpcLevel") and
      2 = current
    ) and
    called < current and
    not preceedingKeLowerIrqlCall(fc)
  )
}

from CallsToIrqlAnnotatedFunction ciaf
where irqlNotLoweredCall(ciaf) or irqlAnnotationViolatingCall(ciaf)
select ciaf,
  ciaf.getTarget().getName() +
    " can not be called at the current Irql level.  The current level is too high"
