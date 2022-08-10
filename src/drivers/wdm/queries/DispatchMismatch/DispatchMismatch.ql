/**
 * @name DispatchMismatch
 * @kind problem
 * @platform Desktop
 * @description The dispatch function does not have a _Dispatch_type_ annotation matching this dispatch table entry. This defect can be corrected either by adding a _Dispatch_type_ annotation to the function or correcting the dispatch table entry being used.
 * @problem.severity warning
 * @feature.area Multiple
 * @id cpp/portedqueries/dispatch-mismatch
 * @repro.text The following code locations potentially contain _Dispatch_type_ annotation mismatches.
 * @version 1.0
 */

import cpp
import Windows.wdk.wdm.WdmDrivers

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
    // not ae instanceof DispatchRoutineAssignment and
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
