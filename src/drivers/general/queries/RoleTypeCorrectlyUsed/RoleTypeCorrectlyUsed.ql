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
 * @opaqueid CQLD-C28158
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v2
 */

import cpp
import drivers.libraries.RoleTypes
import semmle.code.cpp.TypedefType

from ImplicitRoleTypeFunction irtf, Function f, string rtActual, string rtExpected
where
  irtf.getActualRoleTypeString() != irtf.getExpectedRoleTypeString() and
  f = irtf.getFunctionUse().getTarget() and
  (
    if f instanceof RoleTypeFunction
    then rtActual = f.(RoleTypeFunction).getRoleTypeString()
    else rtActual = "<NO_ROLE_TYPE>"
  ) and
  rtExpected = irtf.getExpectedRoleTypeString() and
  not isEqualRoleTypes(rtExpected, rtActual) and
  // Account for case where one function covers multiple role types
  not exists(string otherRoleType |
    otherRoleType = f.(RoleTypeFunction).getRoleTypeString() and
    isEqualRoleTypes(rtExpected, otherRoleType)
  )
select irtf.getFunctionUse(),
  "Function " + f.toString() + " declared with role type " + rtActual + " but role type " +
    rtExpected + " is expected."
