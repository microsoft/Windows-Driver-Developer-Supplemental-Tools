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

class MDL extends Struct {
  MDL() {
    this.getName().matches("_MDL") and
    this.getFile().getBaseName().matches("wdm.h")
  }
}

class SafeMDLMacro extends Macro {
  SafeMDLMacro() {
    this.getName().matches(["MmGetMdlVirtualAddress", "MmGetMdlByteCount", "MmGetMdlByteOffset"]) and
    this.getFile().getBaseName().matches("wdm.h")
    or
    this.getName().matches(["NdisAdjustMdlLength"]) and
    this.getFile().getBaseName().matches("ndis.h")
  }
}

class IncorrectMDLFieldAccess extends FieldAccess {
  Field accessedField;

  IncorrectMDLFieldAccess() {
    accessedField = this.getTarget() and
    exists(MDL mdl |
      this.getTarget() = mdl.getAMember() and
      not accessedField.getName().matches(["Next", "MdlFlags"]) and
      not this.getFile().getBaseName().matches("wdm.h") and
      not (
        this.isInMacroExpansion() and
        exists(SafeMDLMacro m | m.getAnInvocation().getAnExpandedElement() = this)
      )
    )
  }


  string getMessage() {
   if accessedField.getName().matches("ByteCount") then  result = "Direct access of opaque MDL field (ByteCount). This field should not be directly accessed.  Please use the MmGetMdlByteCount() macro isntead."
   else if accessedField.getName().matches("ByteOffset") then result = "Direct access of opaque MDL field (ByteOffset). This field should not be directly accessed.  Please use the MmGetMdlByteOffset() macro instead."
   else if accessedField.getName().matches("MappedSystemVa") then result = "Direct access of opaque MDL field (MappedSystemVa). This field should not be directly accessed.  Please use the MmGetMdlVirtualAddress() macro instead."
   else result = "Direct access of opaque MDL field (" + accessedField.getName() + "). This field should not be directly accessed."
  }
}

from IncorrectMDLFieldAccess access
select access, access.getMessage()
//TODO: test cases
//TODO: proper CQL comments
