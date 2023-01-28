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
 * @id cpp/windows/drivers/queries/illegal-field-access
 * @problem.severity warning
 * @precision high
 * @tags correctness
 * @query-version v1
 */

import cpp
import drivers.wdm.libraries.WdmDrivers

/** Represents an access to a field of a DPC. */
class IllegalDeviceObjectFieldAccess extends FieldAccess, IllegalFieldAccess {
  IllegalDeviceObjectFieldAccess() {
    this.getTarget().getParentScope() instanceof DeviceObject and
    not this.getTarget()
        .getName()
        .matches([
            "DeviceExtension", "Flags", "Characteristics", "CurrentIrp", "DeviceType", "StackSize",
            "AlignmentRequirement"
          ]) and
    not this.getFile().getBaseName().matches("wdm.h")
  }

  override string getErrorMessage() {
    if this.getTarget().getName().matches("NextDevice")
    then result = "The 'NextDevice' field can only be accessed in DriverEntry or DriverUnload."
    else result = "The '" + this.getTarget().getName() + "' field cannot be accessed by a driver."
  }

  /**
   * Evaluates if this access is actually illegal, given context.
   * Note: Some behavior, namely that "Vpb" and "SecurityDescriptor" are readable in storage drivers,
   * is not currently implemented.
   */
  override predicate isIllegalAccess() {
    not (
      this.getTarget().getName().matches("NextDevice") and
      not (
        this.getParentScope() instanceof WdmDriverEntry or
        this.getParentScope() instanceof WdmDriverUnload
      )
    )
  }
}

/**
 * Represents the illegal accesses we look for in this query, namely:
 * - Accesses to a DeviceObject's NextDevice field (outside of DriverEntry and DriverUnload)
 *                 // "Flags" is special cased in drivers-dfa.
 *                if (   lstrcmpW(memberName, L"DeviceExtension") == 0
 *                    || lstrcmpW(memberName, L"Flags") == 0
 *                    || lstrcmpW(memberName, L"Characteristics") == 0
 *                    || lstrcmpW(memberName, L"CurrentIrp") == 0
 *                    || lstrcmpW(memberName, L"DeviceType") == 0
 *                    || lstrcmpW(memberName, L"StackSize") == 0
 *                    || lstrcmpW(memberName, L"AlignmentRequirement") == 0)
 * - Accesses to a DPC's field
 * - Accesses to an IRP's CancelRoutine field
 */
abstract class IllegalFieldAccess extends Element {
  abstract string getErrorMessage();
  abstract predicate isIllegalAccess();
}

// "Vpb" and "SecurityDescriptor" readable if MacroValue "_DRIVER_TYPE_FILESYSTEM", "_DRIVER_TYPE_FILESYSTEM_FILTER", or "_DRIVER_TYPE_STORAGE"
// "NextDevice" readable in DriverEntry and DriverUnload
from IllegalFieldAccess ifa
where ifa.isIllegalAccess()
select ifa, ifa.getErrorMessage()
