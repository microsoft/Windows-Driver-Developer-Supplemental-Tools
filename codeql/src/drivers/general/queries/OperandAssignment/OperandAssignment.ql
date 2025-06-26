// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/operand-assignment
 * @name Operand Assignment
 * @description C28129: An assignment has been made to an operand, which should only be modified using bit sets and clears
 * @platform Desktop
 * @security.severity Medium
 * @feature.area Multiple
 * @impact Exploitable Design
 * @repro.text
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28129
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       ca_ported
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */

import cpp

from FieldAccess fa, Field f
where 
  f = fa.getTarget() and
  exists(Struct v | fa.getTarget() = v.getAMember() | v.getName() = "_DEVICE_OBJECT") and
  f.getName() = "Flags" and 
  fa.getParent() instanceof AssignExpr

select fa, "An assignment has been made to an operand $@, which should only be modified using bit sets and clears.", fa, fa.toString()
