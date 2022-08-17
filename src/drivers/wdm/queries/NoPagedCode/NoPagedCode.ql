// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name NoPagedCode
 * @kind problem
 * @platform Desktop
 * @description The function has been declared to be in a paged segment, but neither PAGED_CODE nor PAGED_CODE_LOCKED was found. For more information look at C28170 Code Analysis rule.
 * @problem.severity warning
 * @feature.area Multiple
 * @repro.text The following code locations do not call PAGED_CODE() or PAGED_CODE_LOCKED even though they put the function in a paged segment.
 * @id cpp/portedqueries/no-paged-code
 * @version 1.0
 */

import cpp
import drivers.libraries.Page

from PagedFunctionDeclaration f
where
  f.getEntryPoint() instanceof BlockStmt and
  not f instanceof PagedFunc
select f,
  "The function has been declared to be in a paged segment, but neither PAGED_CODE nor PAGED_CODE_LOCKED was found."
