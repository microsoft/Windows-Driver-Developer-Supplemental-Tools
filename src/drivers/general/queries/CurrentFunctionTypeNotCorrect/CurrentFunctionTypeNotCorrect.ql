// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/current-function-type-not-correct
 * @kind problem
 * @name Current function type not correct (C28101)
 * @description DriverEntry functions should be declared using the DRIVER_INITIALIZE function typedef.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Attack Surface Reduction
 * @repro.text
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28101
 * @problem.severity warning
 * @precision high
 * @tags correctness
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.libraries.RoleTypes

from Function f
where
  f.getName().matches("DriverEntry%") and
  not f instanceof RoleTypeFunction  
select f, "DriverEntry functions should be declared using the DRIVER_INITIALIZE function typedef."
