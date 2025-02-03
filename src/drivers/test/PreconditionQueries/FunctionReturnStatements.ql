// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/precondition-roletypes
 * @kind problem
 * @name FunctionLocationsPrecondition
 * @description Get all function definition locations
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

string getName(FunctionDeclarationEntry fde) {
  result = fde.getName()
  or
  exists(Macro m |
    m.getBody().toString() = fde.getName() and result = m.getAnInvocation().toString()
  )
}

from FunctionDeclarationEntry fde, ReturnStmt rs, string s
where
  fde.getLocation().getFile().getAbsolutePath().matches("%.c%") and
  rs.getEnclosingFunction() = fde.getFunction() and
  if rs.hasExpr() then s = rs.getExpr().toString() else s = ""
select fde, "NAME##$@|RETURNLOC##$@|RETURNSTR##$@", fde, getName(fde), rs,
  rs.getLocation().getStartLine().toString(), rs, s
