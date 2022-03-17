// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

/**
 * @name Inconsistent annotation of WDM dispatch routine.
 * @description One or more WDM dispatch routines is incorrectly annotated.
 * @platform Desktop
 * @feature.area Multiple
 * @repro.text One or more WDM dispatch routines is incorrectly annotated.
 * @kind problem
 * @id cpp/windows/wdk/inconsistent-dispatch-annotation
 * @problem.severity warning
 * @query-version 0.9
 */

import microsoft.code.cpp.commons.WindowsDrivers

from DispatchTypeDefinition dmi, WdmDispatchRoutine wdr, FunctionDeclarationEntry fde
where fde = wdr.getADeclarationEntry() and
dmi.getDeclarationEntry() = fde and
not (wdr.matchesAnnotation(dmi))
select fde, "Function declaration of " + fde.getFunction().getName() + " is annotated as a different dispatch type than it is assigned to in the driver's DRIVER_INITIALIZE function ($@).", wdr.getDriverEntry(), wdr.getDriverEntry().getName()