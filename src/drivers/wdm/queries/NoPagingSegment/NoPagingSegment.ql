/**
 * @name NoPagingSegment
 * @kind problem
 * @description The function has PAGED_CODE or PAGED_CODE_LOCKED but is not declared to be in a paged segment
 * @problem.severity warning
 * @id cpp/portedqueries/no-paging-segment
 * @version 1.0
 */

import cpp
import drivers.libraries.Page

from PagedFunc pf
where
  not isPageCodeSectionSetAbove(pf) and
  not isPagedSegSetWithMacroAbove(pf) and
  not isAllocUsedToLocatePagedFunc(pf) and
  pf.getFile().getExtension() != "tmh" and 
  //The path below observed while testing. It was Auto-generated file.
  not pf.getFile().getRelativePath().matches("%x64/Debug%")
select pf,
  "The function has PAGED_CODE or PAGED_CODE_LOCKED but is not declared to be in a paged segment"
