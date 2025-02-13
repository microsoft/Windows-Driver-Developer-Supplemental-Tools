// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/precondition-todo
 * @kind problem
 * @name todo
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

// from GlobalVariable g
// where g.getLocation().getFile().toString().matches("%osmodel.c%")
// select g, "TYPE##$@|NAME##$@", g, g.getType().toString(), g, g.getASpecifier().toString()
from VariableDeclarationEntry v, string type
where
  v.getFile().toString().matches("%osmodel.c%") and
  v.getVariable() instanceof GlobalVariable and
  if v.getType() instanceof Struct
  then type = "struct " + v.getType().(Struct).getName().toString()
  else
    if
      (
        v.getType() instanceof PointerType and
        v.getType().(PointerType).getBaseType() instanceof Struct
      )
    then type = "struct " + v.getType().toString()
    else type = v.getType().toString()
select v, "TYPE##$@|NAME##$@", v,type, v, v.getName()
