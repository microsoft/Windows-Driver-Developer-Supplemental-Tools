/**
 * @name NoPagedCode
 * @kind problem
 * @description The function has been declared to be in a paged segment, but neither PAGED_CODE nor PAGED_CODE_LOCKED was found.
 * @problem.severity warning
 * @id cpp/portedqueries/no-paged-code
 * @version 1.0
 */

import cpp
import PortedQueries.PortLibrary.Page

from PagedFunctionDeclaration f
where
  not f instanceof PagedFunc and
  f.getFile().getExtension() != "tmh"
select f,
  "The function has been declared to be in a paged segment, but neither PAGED_CODE nor PAGED_CODE_LOCKED was found."
