// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Direct access of opaque MDL field
 * @description Direct access of opaque MDL fields should be avoided, as mistakes can lead to instability.
 * @platform Desktop
 * @feature.area Multiple
 * @repro.text The following code locations directly access an opaque MDL field.
 * @kind problem
 * @id cpp/windows/drivers/queries/opaquemdluse
 * @problem.severity warning
 * @precision high
 * @tags correctness
 * @query-version v1
 */

import cpp
import drivers.wdm.libraries.Mdl

/**
 * A class representing an access to a member of an MDL which is neither:
 * - A freely-accessible member ("Next", "MdlFlags")
 * - Part of the WDM header files
 * - The result of expanding a safe macro to access these structs
 */
class IncorrectMdlFieldAccess extends FieldAccess {
  Field accessedField;

  IncorrectMdlFieldAccess() {
    accessedField = this.getTarget() and
    exists(Mdl mdl | this.getTarget() = mdl.getAMember()) and
    not accessedField.getName().matches(["Next", "MdlFlags"]) and
    not this.getFile().getBaseName().matches("wdm.h") and
    not (
      this.isInMacroExpansion() and
      exists(SafeMdlAccessMacro safeMacro |
        safeMacro.getAnInvocation().getAnExpandedElement() = this
      )
    )
  }

  /** Returns a string with information on which macro, if any, can be called to correctly use a field that was incorrectly accessed. */
  string getMessage() {
    if accessedField.getName().matches("ByteCount")
    then
      result =
        "Direct access of opaque MDL field (ByteCount). This field should not be directly accessed.  Please use the MmGetMdlByteCount() macro isntead."
    else
      if accessedField.getName().matches("ByteOffset")
      then
        result =
          "Direct access of opaque MDL field (ByteOffset). This field should not be directly accessed.  Please use the MmGetMdlByteOffset() macro instead."
      else
        if accessedField.getName().matches("MappedSystemVa")
        then
          result =
            "Direct access of opaque MDL field (MappedSystemVa). This field should not be directly accessed.  Please use the MmGetSystemAddressForMdlSafe() macro instead."
        else
          if accessedField.getName().matches("StartVa")
          then
            result =
              "Direct access of opaque MDL field (StartVa).  This field should not be directly accessed.  If you are using this access in conjunction with the ByteOffset to calculate the virtual address of the buffer described by an MDL, please use the MmGetMdlVirtualAddress() macro instead."
          else
            result =
              "Direct access of opaque MDL field (" + accessedField.getName() +
                "). This field should not be accessed."
  }
}

from IncorrectMdlFieldAccess incorrectAccess
select incorrectAccess, incorrectAccess.getMessage()