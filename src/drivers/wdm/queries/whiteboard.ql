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
import drivers.libraries.SAL

predicate annotationMismatch(AssignExpr ae) {
  exists(
    DispatchTypeDefinition dmi, WdmDispatchRoutine wdr, FunctionDeclarationEntry fde,
    FunctionAccess faa
  |
    ae.getRValue().(FunctionAccess) = faa and
    faa.getTarget() instanceof WdmCallbackRoutine and
    faa.getTarget() = fde.getFunction() and
    fde = wdr.getADeclarationEntry() and
    dmi.getDeclarationEntry() = fde and
    not wdr.matchesAnnotation(dmi)
  )
}

/** Determines if a given assignment, recursively, has a WDM callback routine as the right-hand side. */
predicate vV(AssignExpr ae) {
    ae.getFile().getBaseName() = "cdinit.c"  and
  exists(FunctionAccess fa |
    // result = ae.getLocation().getStartLine() and
    ae.getRValue() = fa and
    fa.getTarget() instanceof WdmDispatchRoutine
  )
  or
  ae.getRValue() instanceof AssignExpr and
 vV(ae.getRValue().(AssignExpr))
}

class Y extends AssignExpr {
  WdmDriverEntry driverEntry;

  Y() {
    exists(
      ArrayExpr dispatchTable, PointerFieldAccess fieldAccess, FunctionAccess fa,
      VariableAccess driverObjectAccess
    |
      this.getLValue() = dispatchTable and
      // this.getRValue().(FunctionAccess).getTarget() instanceof WdmDispatchRoutine
      // or
      // exists(CallbackRoutineAssignment cra |
      //   this = cra and cra.getTarget() instanceof WdmDispatchRoutine
      not vV(this) and
      dispatchTable.getArrayBase() = fieldAccess and
      fieldAccess.getQualifier() = driverObjectAccess and
      driverObjectAccess.getTarget().getType().getName().matches("PDRIVER_OBJECT") and
      this.getEnclosingFunction() = driverEntry 
     and  this.getFile().getBaseName() = "cdinit.c" 
      
    )
  }
  int getLoc(){
    result = this.getLocation().getStartLine()
  }
}

predicate xx(AssignExpr ae) {
  exists(CallbackRoutineAssignment cra, WdmDispatchRoutine dr |
    ae = cra and
    cra.getTarget() = dr and
    not exists(DispatchTypeDefinition dmi | dmi.getDeclarationEntry() = dr.getADeclarationEntry())
  )
}

class A extends AssignExpr {
  string message;

  A() {
    this instanceof Y and
    message = "right of assignment not proper dispatch function"
    or
    xx(this) and
    message = "missing annotation"
    or
    annotationMismatch(this) and
    message = "annotation mismatch"
  }

  string getMessage() { result = message }
}

// from A a
// select a, a.getMessage()


// from FunctionAccess fa
// where fa.getFile().getBaseName() = "cdinit.c" 
// and 
//  fa.getTarget() instanceof WdmDispatchRoutine
// select fa, fa.getTarget().getName()


from AssignExpr ae
where vV(ae) and ae.getFile().getBaseName() = "cdinit.c" 
select ae, ""



// from Y y
// where y.getFile().getBaseName() = "cdinit.c" 
// select y, y.getLocation().getStartLine().toString()