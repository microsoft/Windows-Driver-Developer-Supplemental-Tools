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

from FunctionDeclarationEntry fde
where fde.getLocation().getFile().getAbsolutePath().matches("%.c%")
select fde, "NAME##$@|RETURNTYPE##$@|PARAMSTR##$@|FILE##$@|BODYSTART##$@|BODYEND##$@", fde,
  getName(fde), fde, fde.getType().toString(), fde, fde.getParameterString(), fde.getLocation(),
  fde.getLocation().getFile().getAbsolutePath(), fde.getBlock(),
  fde.getBlock().getLocation().getStartLine().toString(), fde.getBlock(),
  fde.getBlock().getLocation().getEndLine().toString()
