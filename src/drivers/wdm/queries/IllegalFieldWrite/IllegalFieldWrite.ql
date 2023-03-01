// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Illegal access to a protected field (C28176)
 * @description The driver wrote to a structure field that should not be modified outside of certain contexts.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @repro.text The driver wrote to a structure field that should not be modified outside of certain contexts.
 * @kind problem
 * @id cpp/windows/drivers/queries/illegal-field-write
 * @problem.severity warning
 * @precision high
 * @tags correctness
 * @query-version v1
 */

import cpp
import drivers.wdm.libraries.WdmDrivers

/**
 * Represents the illegal accesses we look for in this query.
 *
 * Because some field accesses are legal in the correct context, you should always check the
 * isIllegalAccess() predicate when looking for illegal accesses.
 */
abstract class PotentiallyIllegalFieldAccess extends Element {
  /** Provides a message describing the illegal access. */
  abstract string getErrorMessage();
}

/**
 * Represents a potentially illegal access to a field of a DeviceObject, namely:
 * - Accesses to a DeviceObject's NextDevice field (outside of DriverEntry and DriverUnload)
 * - Accesses to generally unavailable DeviceObject fields
 */
class IllegalDeviceObjectFieldAccess extends FieldAccess, PotentiallyIllegalFieldAccess {
  IllegalDeviceObjectFieldAccess() {
    this.getTarget().getParentScope() instanceof DeviceObject and
    /*
     * The below cases are not handled by this rule or are generally read-accessible.
     *
     *      TODO: Vpb and SecurityDescriptor are valid in filesystem drivers, but the
     *      macros to indicate this were never implemented, and so they are always suppressed
     *      in filesystem drivers ATM.  We need to either implement suppression or filesystem
     *      driver detection.
     */

    this.getTarget()
        .getName()
        .matches([
            "NextDevice", "DriverObject", "SecurityDescriptor"
          ]) and
    not this.getFile().getBaseName().matches("wdm.h")
  }

  override string getErrorMessage() {
    result = "The '" + this.getTarget().getName() + "' field is read-only."
  }
}

/**
 * Represents potentially illegal accesses to a DriverObject field, namely:
 * - Accesses to a DriverObject's DriverStartIo, DriverUnload, MajorFunction, and DriverExtension fields outside DriverEntry
 * - Accesses to generally unavailable DriverObject fields
 */
class IllegalDriverObjectFieldAccess extends FieldAccess, PotentiallyIllegalFieldAccess {
  IllegalDriverObjectFieldAccess() {
    this.getTarget().getParentScope() instanceof DriverObject and
    // The below cases are not handled by this rule or are generally read-accessible.
    this.getTarget()
        .getName()
        .matches(["DeviceObject", "HardwareDatabase", "DriverInit", "Size"]) and
    not this.getFile().getBaseName().matches("wdm.h")
  }

  override string getErrorMessage() {
    result = "The '" + this.getTarget().getName() + "' field is read-only."
  }
}

// TODO: catch _both_ illegal writes in the "DriverObject->DeviceObject->NextDevice = NULL;" case?

from AssignExpr ae, PotentiallyIllegalFieldAccess ifa
where ae.getLValue() = ifa
select ifa, ifa.getErrorMessage()
