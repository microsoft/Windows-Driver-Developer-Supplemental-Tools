// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Illegal access to a protected field (C28175)
 * @description The driver read a structure field that should not be accessed outside of certain contexts.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @repro.text The driver read a structure field that should not be accessed outside of certain contexts.
 * @kind problem
 * @id cpp/windows/drivers/queries/illegal-field-access-2
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
  /** Provides a message describing the illegal access.  Use only if isIllegalAccess() is true. */
  abstract string getErrorMessage();

  /** Determines if this access is actually illegal in context. */
  abstract predicate isIllegalAccess();
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

    not this.getTarget()
        .getName()
        .matches([
            "DeviceExtension", "Flags", "Characteristics", "CurrentIrp", "DeviceType", "StackSize",
            "AlignmentRequirement", "DriverObject", "Vpb", "SecurityDescriptor"
          ]) and
    not this.getFile().getBaseName().matches("wdm.h")
  }

  override string getErrorMessage() {
    if this.getTarget().getName().matches("NextDevice")
    then result = "The 'NextDevice' field of the " + this.getQualifier() + " struct can only be accessed in DriverEntry or DriverUnload."
    else result = "The '" + this.getTarget().getName() + "' field of the " + this.getQualifier() + " struct cannot be accessed by a driver."
  }

  override predicate isIllegalAccess() {
    not this.getTarget().getName().matches("NextDevice")
    or
    this.getTarget().getName().matches("NextDevice") and
    not (
      this.getControlFlowScope() instanceof WdmDriverEntry or
      this.getControlFlowScope() instanceof WdmDriverUnload
    )
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
    not this.getTarget()
        .getName()
        .matches(["FastIoDispatch", "Size", "DeviceObject", "HardwareDatabase", "DriverInit"]) and
    not this.getFile().getBaseName().matches("wdm.h")
  }

  override string getErrorMessage() {
    if
      this.getTarget()
          .getName()
          .matches(["DriverStartIo", "DriverUnload", "MajorFunction", "DriverExtension"])
    then
      result =
        "The '" + this.getTarget().getName() +
          "' field of the " + this.getQualifier() + " struct can only be accessed in a DriverEntry routine."
    else result = "The '" + this.getTarget().getName() + "' field of the " + this.getQualifier() + " struct cannot be accessed by a driver."
  }

  override predicate isIllegalAccess() {
    // Below fields are illegal iff we're not in a DriverEntry function
    this.getTarget()
        .getName()
        .matches(["DriverStartIo", "DriverUnload", "MajorFunction", "DriverExtension"]) and
    not this.getControlFlowScope() instanceof WdmDriverEntry
    or
    not this.getTarget()
        .getName()
        .matches(["DriverStartIo", "DriverUnload", "MajorFunction", "DriverExtension"])
  }
}

/** Represents illegal accesses to DriverExtension fields, i.e. anything that isn't the "AddDevice" field. */
class IllegalDriverExtensionFieldAccess extends FieldAccess, PotentiallyIllegalFieldAccess {
  IllegalDriverExtensionFieldAccess() {
    this.getTarget().getParentScope() instanceof DriverExtension and
    not this.getTarget().getName().matches("AddDevice")
  }

  override string getErrorMessage() {
    result = "The '" + this.getTarget().getName() + "' field of the " + this.getQualifier() + " struct cannot be accessed by a driver."
  }

  override predicate isIllegalAccess() {
    // This is always true for this class, as we filtered out on AddDevice in the characteristic predicate.
    this instanceof IllegalDriverExtensionFieldAccess
  }
}

from PotentiallyIllegalFieldAccess ifa
where ifa.isIllegalAccess()
select ifa, ifa.getErrorMessage()
