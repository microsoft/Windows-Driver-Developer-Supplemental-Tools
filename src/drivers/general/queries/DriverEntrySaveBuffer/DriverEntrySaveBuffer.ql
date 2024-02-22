// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/driver-entry-save-buffer
 * @name Driver Entry Save Buffer
 * @description C28131: The DriverEntry routine should save a copy of the argument, not the pointer, because the I/O Manager frees the buffer
 * @platform Desktop
 * @security.severity Medium
 * @feature.area Multiple
 * @impact Exploitable Design
 * @repro.text
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28131
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */

import cpp

from VariableAccess va
where
  va.getParent() instanceof AssignExpr and
  exists(Parameter p | p.getAnAccess() = va and p.getFunction().getName() = "DriverEntry") and
  exists(GlobalVariable gv |
    gv = va.getParent().(AssignExpr).getLValue().(VariableAccess).getTarget()
  )
select va,
  "The DriverEntry routine should save a copy of the argument $@, not the pointer, because the I/O Manager frees the buffer",
  va, va.toString()
