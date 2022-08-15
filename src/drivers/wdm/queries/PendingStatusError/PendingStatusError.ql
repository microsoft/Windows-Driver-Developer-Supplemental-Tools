/**
 * @name PendingStatusError
 * @kind problem
 * @platform Desktop
 * @description A dispatch routine that calls IoMarkIrpPending includes at least one path in which the driver returns a value other than STATUS_PENDING. The IoMarkIrpPending routine marks the specified IRP, indicating that a driver's dispatch routine subsequently returned STATUS_PENDING because further processing is required by other driver routines.
 * @problem.severity error
 * @feature.area Multiple
 * @repro.text The following code locations potentially contain IoMarkIrpPending calls that do not return STATUS_PENDING
 * @id cpp/portedqueries/pending-status-error
 * @version 1.0
 */

import cpp
import drivers.wdm.libraries.WdmDrivers

//Represents elements with IO_COMPLETION_ROUTINE type
class IORoutineTypedef extends TypedefType {
  IORoutineTypedef() { this.getName().matches("IO_COMPLETION_ROUTINE") }
}

//Evaluates to true for IO_COMPLETION_ROUTINE type routines.
predicate isIOCompletionRoutine(Function f) {
  exists(FunctionDeclarationEntry fde |
    fde.getFunction() = f and
    fde.getTypedefType() instanceof IORoutineTypedef
  )
}

predicate returnsStatusPending(FunctionCall call) {
  exists(ReturnStmt rs |
    //259 is the integer representaion for STATUS_PENDING
    (
      rs.getExpr().(Literal).getValue().toInt() = 259 and
      call.getASuccessor*() = rs
      or
      exists(VariableAccess va1, AssignExpr ae, VariableAccess va2 |
        (
          //STATUS_PENDING assignment can occur before or after the function call.
          call.getEnclosingFunction() = ae.getEnclosingFunction() and
          (
            call.getAPredecessor*() = ae
            or
            call.getASuccessor*() = ae
          )
        ) and
        ae.getRValue().(Literal).getValue().toInt() = 259 and
        ae.getLValue() = va1 and
        ae.getASuccessor*() = rs and
        va2.getParent() = rs and
        va2.getTarget().getName() = va1.getTarget().getName()
      )
    )
  )
}

from FunctionCall call
where
  call.getTarget().getName() = "IoMarkIrpPending" and
  call.getEnclosingFunction() instanceof WdmDispatchRoutine and
  not returnsStatusPending(call) and
  not isIOCompletionRoutine(call.getEnclosingFunction())
select call, "The return type should be STATUS_PENDING when making IoMarkIrpPending calls"
