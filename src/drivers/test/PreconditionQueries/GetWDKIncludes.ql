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

from Include inc
where inc.getIncludedFile().getBaseName().matches(["wdm.h", "ntddk.h", "ntifs.h"])

select inc, "$@|$@", inc, inc.getIncludedFile().getBaseName().toString(), inc, inc.getLocation().getFile().getAbsolutePath().toString()
