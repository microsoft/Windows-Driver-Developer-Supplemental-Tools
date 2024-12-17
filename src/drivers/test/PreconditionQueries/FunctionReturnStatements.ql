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

from FunctionDeclarationEntry fde, ReturnStmt rs, string s
where fde.getLocation().getFile().getAbsolutePath().matches("%.c%")
and rs.getEnclosingFunction() = fde.getFunction()
and if rs.hasExpr() then s = rs.getExpr().toString() else s = ""
select fde, "NAME##$@|RETURNLOC##$@|RETURNSTR##$@", 
fde, fde.getName(), 
rs, rs.getLocation().getStartLine().toString(), 
rs, s


