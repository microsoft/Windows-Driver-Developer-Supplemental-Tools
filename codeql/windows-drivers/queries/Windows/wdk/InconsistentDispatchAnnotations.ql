// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

import microsoft.code.cpp.commons.WindowsDrivers

 /*
 from WdmDispatchRoutine wdr, DispatchTypeDefinition dtd
 where exists (FunctionDeclarationEntry fde |
    fde.getFunction() = wdr
    and dtd.getAnAffectedElement() = fde)
select wdr, "This function is not correctly annotated."*/

from DispatchTypeDefinition dmi, WdmDispatchRoutine wdr, FunctionDeclarationEntry fde
where fde = wdr.getADeclarationEntry() and
dmi.getDeclarationEntry() = fde //and
//not (wdr.matchesAnnotation(dmi))
select wdr.getDispatchType(), fde, dmi.getDispatchType(), dmi.getFile()