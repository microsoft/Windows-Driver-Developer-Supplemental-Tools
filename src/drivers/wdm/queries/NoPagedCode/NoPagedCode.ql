// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/no-paged-code
 * @name No PAGED_CODE invocation
 * @description The function has been declared to be in a paged segment, but neither PAGED_CODE nor PAGED_CODE_LOCKED was found. This can cause issues when debugging, using Code Analysis, or running on checked builds.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text The following code locations are duplicate PAGED_CODE() calls within a function.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28170
 * @kind problem
 * @problem.severity warning
 * @precision low
 * @tags correctness
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.libraries.Page

from PagedFunctionDeclaration f
where
  f.getEntryPoint() instanceof BlockStmt and
  not f instanceof PagedFunc
select f,
  "The function has been declared to be in a paged segment, but neither PAGED_CODE nor PAGED_CODE_LOCKED was found."
