/**
 * @name DispatchMismatch
 * @kind problem
<<<<<<< HEAD
=======
 * @platform Desktop
>>>>>>> 9cc8e27942839d6c64e90599f4c96ab8bbfeefd4
 * @description The dispatch function does not have a _Dispatch_type_ annotation matching this dispatch table entry
 * @problem.severity warning
 * @id cpp/portedqueries/dispatch-mismatch
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

<<<<<<< HEAD
//Represents function with missing annotation in their declaration. 
=======
//Represents functions with  annotation in their declaration.
>>>>>>> 9cc8e27942839d6c64e90599f4c96ab8bbfeefd4
class NonAnnotatedDispatchs extends Function {
  NonAnnotatedDispatchs() {
    exists(DispatchTypeDefinition dmi, WdmDispatchRoutine wdr |
      this = wdr and
      dmi.getDeclarationEntry() = wdr.getADeclarationEntry()
    )
  }
}

<<<<<<< HEAD
from FunctionAccess fa, WdmDispatchRoutine wdm
where
  fa.getTarget() = wdm and not fa.getTarget() instanceof NonAnnotatedDispatchs
  or
  fa.getTarget() instanceof MismatchedDispatches
select fa.getTarget(),
=======
//Evaluates to true for functions that are not dispatch routine assignments
predicate notWdmDispatchAssignment(AssignExpr ae) {
  exists(FunctionAccess fa |
    ae.getRValue() = fa and
    fa.getEnclosingFunction() instanceof WdmDriverEntry and
    not fa.getTarget() instanceof WdmDispatchRoutine and
    not ae instanceof DispatchRoutineAssignment and
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
>>>>>>> 9cc8e27942839d6c64e90599f4c96ab8bbfeefd4
  fa.getTarget() +
    " : The dispatch function does not have a _Dispatch_type_ annotation matching this dispatch table entry."
