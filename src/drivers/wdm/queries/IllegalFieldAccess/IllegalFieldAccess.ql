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

from AssignExpr ae, IllegalFieldUsage ifu
where ae.getLValue() = ifu
select ae, ifu.getErrorMessage()
