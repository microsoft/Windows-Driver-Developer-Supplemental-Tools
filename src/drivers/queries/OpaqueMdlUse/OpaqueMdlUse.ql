// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Direct access of opaque MDL field (C28145)
 * @description Direct access of opaque MDL fields should be avoided, as mistakes can lead to instability.  This is a port of the Code Analysis rule C28145.
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

/**A class representing a Memory Descriptor List structure. */
class MDL extends Struct {
  MDL() {
    this.getName().matches("_MDL") and
    this.getFile().getBaseName().matches("wdm.h")
  }
}

/** A class representing a macro used to access opaque members of an MDL struct. */
class SafeMDLMacro extends Macro {
  SafeMDLMacro() {
    this.getName().matches(["MmGetMdlVirtualAddress", "MmGetMdlByteCount", "MmGetMdlByteOffset"]) and
    this.getFile().getBaseName().matches("wdm.h")
    or
    this.getName().matches(["NdisAdjustMdlLength"]) and
    this.getFile().getBaseName().matches("ndis.h")
  }
}

/**
 * A class representing an access to a member of an MDL which is neither:
 * - A freely-accessible member ("Next", "MdlFlags")
 * - Part of the WDM header files
 * - The result of expanding a safe macro to access these structs
 */
class IncorrectMDLFieldAccess extends FieldAccess {
  Field accessedField;

  IncorrectMDLFieldAccess() {
    accessedField = this.getTarget() and
    exists(MDL mdl | this.getTarget() = mdl.getAMember()) and
    not accessedField.getName().matches(["Next", "MdlFlags"]) and
    not this.getFile().getBaseName().matches("wdm.h") and
    not (
      this.isInMacroExpansion() and
      exists(SafeMDLMacro safeMacro | safeMacro.getAnInvocation().getAnExpandedElement() = this)
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
            "Direct access of opaque MDL field (MappedSystemVa). This field should not be directly accessed.  Please use the MmGetMdlVirtualAddress() macro instead."
        else
          result =
            "Direct access of opaque MDL field (" + accessedField.getName() +
              "). This field should not be accessed."
  }
}

from IncorrectMDLFieldAccess incorrectAccess
select incorrectAccess, incorrectAccess.getMessage()
//TODO: test cases
