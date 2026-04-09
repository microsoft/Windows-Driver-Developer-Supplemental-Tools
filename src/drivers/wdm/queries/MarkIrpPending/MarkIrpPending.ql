// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/wdm/mark-irp-pending
 * @kind problem
 * @name MarkIrpPending
 * @description If a dispatch routine calls IoMarkIrpPending, it must return
 *              STATUS_PENDING. Returning any other status when the IRP is marked
 *              pending causes inconsistent state and potential data corruption.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Exploitable Design Issue
 * @owner.email sdat@microsoft.com
 * @opaqueid SDV-MarkIrpPending
 * @problem.severity error
 * @precision medium
 * @tags correctness
 *       wdm
 *       sdv-ported
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.wdm.libraries.WdmDrivers

/** A call to IoMarkIrpPending. */
class IoMarkIrpPendingCall extends FunctionCall {
  IoMarkIrpPendingCall() {
    this.getTarget().getName() = ["IoMarkIrpPending", "IofMarkIrpPending"]
  }
}

/**
 * A return statement in a WDM dispatch routine that does NOT return STATUS_PENDING.
 *
 * STATUS_PENDING = 259 (0x103). We check for both the numeric value
 * and the macro name.
 */
class NonPendingReturn extends ReturnStmt {
  NonPendingReturn() {
    exists(WdmDispatchRoutine dr |
      this.getEnclosingFunction() = dr and
      not this.getExpr().getValue() = "259" and
      not this.getExpr().toString() = "STATUS_PENDING"
    )
  }
}

from IoMarkIrpPendingCall markPending, WdmDispatchRoutine dispatchRoutine, ReturnStmt ret
where
  markPending.getEnclosingFunction() = dispatchRoutine and
  ret.getEnclosingFunction() = dispatchRoutine and
  // The return does not return STATUS_PENDING
  not ret.getExpr().getValue() = "259" and
  // The mark-pending dominates this return (not in a different branch)
  markPending.getASuccessor+() = ret
select ret,
  "This dispatch routine ($@) calls $@ but returns a value other than STATUS_PENDING. " +
    "A dispatch routine that marks an IRP pending must return STATUS_PENDING.",
  dispatchRoutine, dispatchRoutine.getName(),
  markPending, "IoMarkIrpPending"
