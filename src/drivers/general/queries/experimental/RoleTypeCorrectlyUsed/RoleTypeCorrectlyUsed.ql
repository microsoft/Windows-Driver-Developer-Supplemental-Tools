// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/role-type-correctly-used
 * @kind problem
 * @name Incorrect Role Type Use
 * @description A function is declared with a role type but used as an argument in a function that expects a different role type for that argument.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text 
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28147e
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.wdm.libraries.WdmDrivers
import semmle.code.cpp.TypedefType

from WdmImplicitRoleTypeFunction irtf, FunctionCall fc, Function f, FunctionAccess fa
where
  irtf.getActualRoleTypeString() != irtf.getExpectedRoleTypeString() and
  irtf.getImplicitUse() = fc and
  fa = irtf.getFunctionAccess() 
  and f = fc.getTarget()
select fc,
  "Function " + irtf.toString() +" declared with role type " +irtf.getActualRoleTypeString().toString() + 
  " but used as argument in function " + fc.toString() + " that expects role type " + irtf.getExpectedRoleTypeString().toString() + 
  " for that argument"
