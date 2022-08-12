// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Write to opaque MDL field (C28145)
 * @description Opaque MDL fields should not be written to.  This is a port of Code Analysis check C28145.
 * @platform Desktop
 * @feature.area Multiple
 * @repro.text The following code locations directly write to an opaque MDL filed.
 * @kind problem
 * @id cpp/windows/drivers/queries/opaquemdlwrite
 * @problem.severity error
 * @precision high
 * @tags correctness
 * @query-version v1
 */

import cpp
import drivers.wdm.libraries.Mdl

/**
 * A class representing a write to a field in an MDL which is not:
 * - The "Next" field (valid to update manually)
 * - Part of the WDM header files
 * - The result of expanding a safe macro to adjust a field
 */
class IncorrectMdlWrite extends Assignment {
  FieldAccess access;

  IncorrectMdlWrite() {
    this.getLValue() = access and
    access.getTarget().getDeclaringType() instanceof Mdl and
    not access.getTarget().getName().matches("Next") and
    not this.getFile().getBaseName().matches("wdm.h") and
    not (
      this.isInMacroExpansion() and
      exists(SafeMdlWriteMacro safeWriteMacro |
        safeWriteMacro.getAnInvocation().getAnExpandedElement() = this
      )
    )
  }

  /** Returns the MDL field that was being incorrectly written to. */
  Field getAccessedField() { result = access.getTarget() }
}

from IncorrectMdlWrite incorrectWrite
select incorrectWrite,
  "The driver is writing to an opaque MDL field (" + incorrectWrite.getAccessedField().getName() +
    ").  MDLs are semi-opaque and opaque fields should not be modified."