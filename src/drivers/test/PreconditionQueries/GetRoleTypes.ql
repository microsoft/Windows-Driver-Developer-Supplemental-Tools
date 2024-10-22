// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/precondition-roletypes
 * @kind problem
 * @name RoleTypePrecondition
 * @description Get all functions with role types
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-TODOID
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.libraries.RoleTypes

from Function func, string roleType
where
  func instanceof RoleTypeFunction and
  not func instanceof WdmDispatchRoutine and
  roleType = func.(RoleTypeFunction).getRoleTypeString()
  or
  func instanceof ImplicitRoleTypeFunction and
  not func instanceof WdmDispatchRoutine and
  roleType = func.(ImplicitRoleTypeFunction).getExpectedRoleTypeString()
  or
  func instanceof WdmDispatchRoutine and
  roleType = "DRIVER_DISPATCH" + func.(WdmDispatchRoutine).getDispatchType()
select func, "$@|$@", func, func.getName(), func, roleType
