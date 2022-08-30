// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name WrongDispatchTableAssignment
 * @kind problem
 * @platform Desktop
 * @description The dispatch table assignment satisfies either of these 3 scenarios: 1) The dispatch table assignment has a function whose type is not DRIVER_DISPATCH, or 2) The dispatch table assignment has a DRIVER_DISPATCH function at its right-hand side but the function doesn't have a driver dispatch type annotation, or 3) The dispatch function satisfies both of the above conditions but its dispatch type doesn't match the expected type for the dispatch table entry.
 * @problem.severity warning
 * @feature.area Multiple
 * @repro.text The following lines of code may potentially contain incorrect assignment to dispatch table entry.
 * @id cpp/portedqueries/wrong-dispatch-table-assignment
 * @version 1.0
 */

import cpp
import drivers.wdm.libraries.WdmDrivers
import drivers.libraries.SAL

//Evaluates to true for AssignExpr for whom the right hand side evaluates to a FunctionAccess whose target is
//a WdmDispatchRoutine but its dispatch type annotation doesn't match the dispatch table entry
predicate dispatchAnnotationMismatched(AssignExpr ae) {
  exists(DispatchTypeDefinition dmi, WdmDispatchRoutine wdr, FunctionAccess faa |
    ae.getRValue().(FunctionAccess) = faa and
    faa.getTarget() = wdr and
    dmi.getDeclarationEntry() = wdr.getADeclarationEntry() and
    not wdr.matchesAnnotation(dmi)
  )
}

//Evaluates to true if a given assignment, recursively, has a WdmDispatchRoutine callback routine as the right hand side
predicate dispatchRoutineExists(AssignExpr ae) {
  exists(FunctionAccess fa |
    ae.getRValue() = fa and
    fa.getTarget() instanceof WdmDispatchRoutine
  )
  or
  ae.getRValue() instanceof AssignExpr and
  dispatchRoutineExists(ae.getRValue().(AssignExpr))
}

//Represents dispatch table AssignExpr whose right hand side is not a funtion of type DRIVER_DISPATCH
class NonDispatchFunction extends AssignExpr {
  NonDispatchFunction() {
    exists(
      ArrayExpr dispatchTable, PointerFieldAccess fieldAccess, VariableAccess driverObjectAccess
    |
      this.getLValue() = dispatchTable and
      not dispatchRoutineExists(this) and
      dispatchTable.getArrayBase() = fieldAccess and
      fieldAccess.getQualifier() = driverObjectAccess and
      driverObjectAccess.getTarget().getType().getName().matches("PDRIVER_OBJECT") and
      this.getEnclosingFunction() instanceof WdmDriverEntry
    )
  }
}

//Evaluates to true for a dispatch table assignment where the dispatch function doesn't have annotation matching "this" dispatch table entry.
predicate dispatchAnnotationMissing(AssignExpr ae) {
  exists(CallbackRoutineAssignment cra, WdmDispatchRoutine dr |
    ae = cra and
    cra.getTarget() = dr and
    not exists(DispatchTypeDefinition dmi | dmi.getDeclarationEntry() = dr.getADeclarationEntry())
  )
}

//Represents AssignExpr that satisfy either of the three scenarios given below
class WrongDispatchFunctionAssignments extends AssignExpr {
  string message;

  WrongDispatchFunctionAssignments() {
    this instanceof NonDispatchFunction and
    message =
      "Dispatch table assignment should have a DRIVER_DISPATCH type rouine as its right-hand side value."
    or
    dispatchAnnotationMissing(this) and
    message = "The dispatch function doesn't not have a dispatch type annotation."
    or
    dispatchAnnotationMismatched(this) and
    message =
      "The dispatch function doesn't not have a dispatch type annotation matching this dispatch table entry."
  }

  string getMessage() { result = message }
}

from WrongDispatchFunctionAssignments wdfa
select wdfa, wdfa.getMessage()
