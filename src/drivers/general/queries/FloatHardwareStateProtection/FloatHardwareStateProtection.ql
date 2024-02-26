// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/float-hardware-state-protection 
 * @kind problem
 * @name Float Hardware State Protection
 * @description Drivers must protect floating-point hardware state.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text This warning is only applicable in kernel mode. The driver is attempting to use a variable or constant of a float type when the code is not protected by KeSaveFloatingPointState and KeRestoreFloatingPointState, or EngSaveFloatingPointState and EngRestoreFloatingPointState.
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28110
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */


import cpp

from Variable floatVar
where
  floatVar.getType() instanceof FloatType
select floatVar, "TODO"