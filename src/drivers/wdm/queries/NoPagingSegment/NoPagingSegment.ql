// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/no-paged-code
 * @name No paging segment for PAGED_CODE macro invocation
 * @description The function has PAGED_CODE or PAGED_CODE_LOCKED but is not declared to be in a paged segment. This can cause issues when debugging, using Code Analysis, or running on checked builds.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text The following code locations have PAGED_CODE() or PAGED_CODE_LOCKED() calls but they were not put in paged segments.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28172
 * @kind problem
 * @problem.severity warning
 * @precision low
 * @tags correctness
 *       ca_ported
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.libraries.Page

from PagedFunc pf
where
  not pf instanceof FunctionWithPageSet and
  not isPagedSegSetWithMacroAbove(pf) and
  not isAllocUsedToLocatePagedFunc(pf) 
select pf,
  "The function has PAGED_CODE or PAGED_CODE_LOCKED but is not declared to be in a paged segment"
 