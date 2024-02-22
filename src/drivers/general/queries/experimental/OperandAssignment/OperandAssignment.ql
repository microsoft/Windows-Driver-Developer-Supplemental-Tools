// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/operand-assignment
 * @name 
 * @description C28114: Copying a whole IRP stack entry leaves certain fields initialized that should be cleared or updated.
 * @platform Desktop
 * @security.severity Medium
 * @feature.area Multiple
 * @impact Exploitable Design
 * @repro.text
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-D0006
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */

import cpp


from AssignExpr a
where 
  a.getLValue() instanceof FieldAccess
select a, "$@", a, a.toString()
