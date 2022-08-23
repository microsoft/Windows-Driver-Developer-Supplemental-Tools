/**
 * @name DispatchAnnotationMissing
 * @kind problem
 * @description The dispatch function does not have any _Dispatch_type_ annotations
 * @problem.severity warning
 * @id cpp/portedqueries/dispatch-annotation-missing
 * @version 1.0
 */

import cpp
import Windows.wdk.wdm.WdmDrivers
import Windows.wdk.wdm.SAL

//Represents elements with DRIVER_DISPATCH type.
class DriverDispatchDRoutineTypedef extends TypedefType {
  DriverDispatchDRoutineTypedef() { this.getName().matches("DRIVER_DISPATCH") }
}

//Evaluates to true for Routines with DRIVER_DISPATCH annotation
predicate isDriverDispatchRoutine(Function f) {
  exists(FunctionDeclarationEntry fde |
    fde.getFunction() = f and
    fde.getTypedefType() instanceof DriverDispatchDRoutineTypedef
  )
}

//Represents elements with _Dispatch_type_ and _drv_dispatchType annotation
class DispatchAnnotations extends SALAnnotation {
  DispatchAnnotations() { this.getMacroName() = ["_Dispatch_type_", "__drv_dispatchType"] }
}

//Represents functions that with DRIVER_DISPATCH function type and DispatchAnnotation
class SALAnnotatedDispatchRoutines extends Function {
  SALAnnotatedDispatchRoutines() {
    exists(DispatchAnnotations da |
      isDriverDispatchRoutine(this) and
      da.getDeclaration() = this
    )
  }
}

//Evaluates to true if the assignment is to the MajorFunction table of a DRIVER_OBJECT
predicate isMajorFunctionTableAssignments(Function f) {
  exists(AssignExpr ae, Expr exp |
    ae.getRValue() = exp and exp.(FunctionAccess).getTarget().getName() = f.getName()
  |
    ae.getLValue().(ArrayExpr).getArrayBase().toString() = "MajorFunction"
  )
}

from Function f
where
  isDriverDispatchRoutine(f) and
  not f instanceof SALAnnotatedDispatchRoutines and
  isMajorFunctionTableAssignments(f)
select f, "The dispatch function does not have any _Dispatch_type_ annotations"
