// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

/**
 * @name Illegal write to a protected field (C28176)
 * @id cpp/drivers/illegal-field-write
 * @kind problem
 * @description The driver wrote to a structure field that should not be modified outside of certain contexts.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text The driver wrote to a structure field that should not be modified outside of certain contexts.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28176
 * @problem.severity warning
 * @precision high
 * @tags correctness
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.wdm.libraries.WdmDrivers

/**
 * An illegal access we look for in this query.
 */
abstract class PotentiallyIllegalFieldAccess extends FieldAccess {
  /** Provides a message describing the illegal access. */
  string getErrorMessage() {
    result =
      "The '" + this.getTarget() + "' field of the " + this.getQualifier() + " struct is read-only."
  }
}

/**
 * A potentially illegal access to a field of a DeviceObject when used in a write,
 * namely the NextDevice, DriverObject, and SecurityDescriptor fields.
 */
class IllegalDeviceObjectFieldAccess extends PotentiallyIllegalFieldAccess {
  IllegalDeviceObjectFieldAccess() {
    this.getTarget().getParentScope() instanceof DeviceObject and
    this.getTarget().getName().matches(["NextDevice", "DriverObject", "SecurityDescriptor"]) and
    not this.getFile().getBaseName().matches("wdm.h")
  }
}

/**
 * A potentially illegal access to a DriverObject field when used in a write, namely the
 * DeviceObject, HardwareDatabase, DriverInit, and Size fields.
 */
class IllegalDriverObjectFieldAccess extends PotentiallyIllegalFieldAccess {
  IllegalDriverObjectFieldAccess() {
    this.getTarget().getParentScope() instanceof DriverObject and
    this.getTarget().getName().matches(["DeviceObject", "HardwareDatabase", "DriverInit", "Size"]) and
    not this.getFile().getBaseName().matches("wdm.h")
  }
}

// Look for any assignments to an illegal field, or any direct increment/decrements of it.
from PotentiallyIllegalFieldAccess ifa
where
  exists(Assignment ae |
    ifa = ae.getLValue()
    or
    exists(FieldAccess fa |
      fa.getQualifier*() = ifa and
      ae.getLValue() = fa
    )
  )
  or
  exists(CrementOperation co | co.getOperand() = ifa)
select ifa, ifa.getErrorMessage()
