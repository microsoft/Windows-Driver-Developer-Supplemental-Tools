// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name NoPagingSegment
 * @kind problem
 * @description The function has PAGED_CODE or PAGED_CODE_LOCKED but is not declared to be in a paged segment. In other words, a function that contains a PAGED_CODE or PAGED_CODE_LOCKED macro has not been placed in paged memory by using #pragma alloc_text or #pragma code_seg. For more information refer to C28172 Code Analysis rule.
 * @problem.severity warning
 * @feature.area Multiple
 * @platform Desktop
 * @repro.text The following code locations have PAGED_CODE() or PAGED_CODE_LOCKED() calls but they were not put in paged segments.
 * @id cpp/portedqueries/no-paging-segment
 * @version 1.0
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
 