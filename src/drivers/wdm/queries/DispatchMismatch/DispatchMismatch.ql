// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name DispatchMismatch
 * @kind problem
 * @platform Desktop
 * @description The dispatch function does not have a _Dispatch_type_ annotation matching this dispatch table entry
 * @problem.severity warning
 * @id cpp/portedqueries/dispatch-mismatch
 * @version 1.0
 */

import cpp
import drivers.wdm.libraries.WdmDrivers

//Represents functions whose declaration annotations don't match their expected annotation type
class MismatchedDispatches extends Function {
  MismatchedDispatches() {
    exists(DispatchTypeDefinition dmi, WdmDispatchRoutine wdr, FunctionDeclarationEntry fde |
      this = fde.getFunction() and
      fde = wdr.getADeclarationEntry() and
      dmi.getDeclarationEntry() = fde and
      not wdr.matchesAnnotation(dmi)
    )
  }
}

//Represents functions with  annotation in their declaration.
class NonAnnotatedDispatchs extends Function {
  NonAnnotatedDispatchs() {
    exists(DispatchTypeDefinition dmi, WdmDispatchRoutine wdr |
      this = wdr and
      dmi.getDeclarationEntry() = wdr.getADeclarationEntry()
    )
  }
}

//Evaluates to true for functions that are not dispatch routine assignments
predicate notWdmDispatchAssignment(AssignExpr ae) {
  exists(FunctionAccess fa |
    ae.getRValue() = fa and
    fa.getEnclosingFunction() instanceof WdmDriverEntry and
    not fa.getTarget() instanceof WdmDispatchRoutine and
    not ae instanceof CallbackRoutineAssignment and
    ae.getLValue().(ArrayExpr).getArrayBase().toString() = "MajorFunction"
  )
}

from FunctionAccess fa, WdmDispatchRoutine wdm, ExprStmt es
where
  fa.getEnclosingFunction() instanceof WdmDriverEntry and
  es.getExpr().(AssignExpr).getRValue() = fa and
  (
    fa.getTarget() = wdm and not fa.getTarget() instanceof NonAnnotatedDispatchs
    or
    fa.getTarget() instanceof MismatchedDispatches
    or
    notWdmDispatchAssignment(es.getExpr())
  )
select fa,
  fa.getTarget() +
    " : The dispatch function does not have a _Dispatch_type_ annotation matching this dispatch table entry."
