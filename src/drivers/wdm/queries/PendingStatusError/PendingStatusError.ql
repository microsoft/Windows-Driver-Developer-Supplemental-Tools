// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/pending-status-error
 * @name Did not return STATUS_PENDING after IoMarkIrpPending call
 * @description A dispatch routine that calls IoMarkIrpPending includes at least one path in which the driver returns a value other than STATUS_PENDING. The IoMarkIrpPending routine marks the specified IRP, indicating that a driver's dispatch routine subsequently returned STATUS_PENDING because further processing is required by other driver routines. For more information please refer C28143 Code Analysis rule.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text The following code locations potentially contain IoMarkIrpPending calls that do not return STATUS_PENDING
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28143
 * @kind problem
 * @problem.severity warning
 * @precision Low
 * @tags correctness
 *       ca_ported
 *       wddst
 * @scope domainspecific
 * @query-version v1
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
