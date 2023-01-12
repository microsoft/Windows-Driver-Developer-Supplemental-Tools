// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Failure to clear DO_DEVICE_INITIALIZING (C28152)
 * @description The driver exited its AddDevice routine without clearing the DO_DEVICE_INITIALIZING flag of the DeviceObject.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @repro.text The driver exited its AddDevice routine without clearing the DO_DEVICE_INITIALIZING flag of the DeviceObject.
 * @kind problem
 * @id cpp/windows/drivers/queries/init-not-cleared
 * @problem.severity warning
 * @precision high
 * @tags correctness
 * @query-version v1
 */

import cpp
import drivers.wdm.libraries.WdmDrivers

/** Represents an access to a CancelRoutine field of an IRP. */
class IrpCancelRoutineAccess extends FieldAccess, IllegalFieldUsage {
  IrpCancelRoutineAccess() {
    this.getTarget().getParentScope() instanceof Irp and
    this.getTarget().getName().matches("CancelRoutine")
  }
}

/** Represents an access to a field of a DPC. */
class DpcFieldAccess extends FieldAccess, IllegalFieldUsage {
  DpcFieldAccess() { this.getTarget().getParentScope() instanceof Dpc }
}

/** Represents an access to a DPC. */
class DpcAccess extends FieldAccess, IllegalFieldUsage {
  DpcAccess() { this.getTarget().getUnderlyingType() instanceof Dpc }
}

/**
 * Represents the illegal accesses we look for in this query, namely:
 * - Accesses to a DeviceObject's DPC field
 * - Accesses to a DPC's field
 * - Accesses to an IRP's CancelRoutine field
 */
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

/*warning C28152: The return from an AddDevice-like function unexpectedly DO_DEVICE_INITIALIZING

The driver has returned from its AddDevice routine, or a similar utility routine, but the DO_DEVICE_INITIALIZING bit of the Flags word (DeviceObject->Flags) in the DeviceObject routine is not cleared.

The AddDevice routine must contain code similar to the following to clear the DO_DEVICE_INITIALIZING flag.

FunctionalDeviceObject->Flags &= ~DO_DEVICE_INITIALIZING;*/

from AssignExpr ae, IllegalFieldUsage ifu
where ae.getLValue() = ifu
select ae, ifu.getErrorMessage()
