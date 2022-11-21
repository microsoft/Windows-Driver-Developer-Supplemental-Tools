// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Incorrect access to protected field (C28128)
 * @description The driver assigned a value to a structure member that should be accessed only by using specialized functions.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @repro.text The driver assigned a value to a structure member that should be accessed only by using specialized functions.
 * @kind problem
 * @id cpp/windows/drivers/queries/illegal-field-access
 * @problem.severity warning
 * @precision high
 * @tags correctness
 * @query-version v1
 */

import cpp
import drivers.wdm.libraries.WdmDrivers

// So.  It appears that what this check does on paper != what it does in practice.
// In theory, it should check that you aren't (for example) assigning CancelRoutines directly.
// In practice, it only looks for accesses to the DPC object fields.
// Example: DeviceObject->Dpc.DeferredRoutine = DpcForIsrRoutine;
// Let's implement both.
//Irp->CancelRoutine = DispatchCancel; // SHOULD be caught by C28128 but isn't
//DeviceObject->Dpc.DeferredRoutine = DpcForIsrRoutine; // IS caught by C28128
class IrpCancelRoutineAccess extends FieldAccess, IllegalFieldUsage {
  IrpCancelRoutineAccess() {
    this.getTarget().getParentScope() instanceof Irp and
    this.getTarget().getName().matches("CancelRoutine")
  }
}

class DpcFieldAccess extends FieldAccess, IllegalFieldUsage {
  DpcFieldAccess() { this.getTarget().getParentScope() instanceof Dpc }
}

class DpcAccess extends FieldAccess, IllegalFieldUsage {
  DpcAccess() { this.getTarget().getUnderlyingType() instanceof Dpc }
}

abstract class IllegalFieldUsage extends Element {
  string getErrorMessage() {
    if this instanceof DpcAccess or this instanceof DpcFieldAccess
    then
      result =
        "An assignment to an IO DPC or one of its fields has been made directly. It should be made by IoInitializeDpcRequest."
    else
      result =
        "An assignment to an IRP CancelRoutine field was made directly. It should be made by IoSetCancelRoutine."
  }
}

from AssignExpr ae, IllegalFieldUsage ifu
where ae.getLValue() = ifu
select ae, ifu.getErrorMessage()
