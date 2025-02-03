// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/precondition-roletypes
 * @kind problem
 * @name RoleTypePrecondition
 * @description Get all functions with role types
 * @platform Desktop
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-TODOID
 * @problem.severity warning
 * @precision medium
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
  roleType = "DRIVER_DISPATCH#" + func.(WdmDispatchRoutine).getDispatchType()
select func, "NAME##$@|ROLETYPE##$@", func, func.getName(), func, roleType
