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
 * @query-version v1
 */

import WdmDrivers

from DispatchTypeDefinition dmi, WdmDispatchRoutine wdr, FunctionDeclarationEntry fde
where
  fde = wdr.getADeclarationEntry() and
  dmi.getDeclarationEntry() = fde and
  not wdr.matchesAnnotation(dmi)
select fde,
  "Function declaration of " + fde.getFunction().getName() +
    " is annotated as a different dispatch type (" + dmi.getDispatchTypeAsName() +
    ") than it is assigned to in the driver's DriverEntry function ($@). Dispatch type annotations should match the assigned dispatch type of the function.  Please review, as this may indicate a mistake in dispatch assignment.",
  wdr.getDriverEntry(), wdr.getDriverEntry().getName()
