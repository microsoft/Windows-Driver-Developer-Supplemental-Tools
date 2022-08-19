// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * Provides classes for reasoning about use of Memory Descriptor Lists (MDLs).
 */

import cpp

/** A class representing a Memory Descriptor List structure. */
class Mdl extends Struct {
  Mdl() {
    this.getName().matches("_MDL") and
    this.getFile().getBaseName().matches("wdm.h")
  }
}

/** A class representing macros that can safely write to MDL fields. */
class SafeMdlWriteMacro extends Macro {
  SafeMdlWriteMacro() {
    this.getName().matches("NdisAdjustMdlLength") and this.getFile().getBaseName().matches("ndis.h")
  }
}

/** A class representing a macro used to safely access opaque members of an MDL struct. */
class SafeMdlAccessMacro extends Macro {
  SafeMdlAccessMacro() {
    this.getName()
        .matches([
            "MmGetMdlVirtualAddress", "MmGetMdlByteCount", "MmGetMdlByteOffset",
            "MmGetSystemAddressForMdlSafe"
          ]) and
    this.getFile().getBaseName().matches("wdm.h")
    or
    this.getName().matches(["NdisAdjustMdlLength"]) and
    this.getFile().getBaseName().matches("ndis.h")
  }
}
