/**
 * @name MultiplePagedCode
 * @kind problem
 * @platform Desktop
 * @description The function has more than one instance of PAGED_CODE or PAGED_CODE_LOCKED.
 * @problem.severity warning
 * @feature.area Multiple
 * @id cpp/portedqueries/multiple-paged-code
 * @version 1.0
 */

import cpp
import PortedQueries.PortLibrary.Page

//Selects routines with two at least two PAGE_CODE invocations inside one function
from Function f, MacroInvocation mi, MacroInvocation mi2
where
  f instanceof PagedFunctionDeclaration and
  f instanceof PagedFunc and
  mi.getEnclosingFunction() = f and
  mi2.getEnclosingFunction() = f and
  mi.getMacroName() = ["PAGED_CODE", "PAGED_CODE_LOCKED"] and
  mi2.getMacroName() = ["PAGED_CODE", "PAGED_CODE_LOCKED"] and
  mi.getLocation().getStartLine() < mi2.getLocation().getStartLine()
select mi2,
  "Functions in a paged section must have exactly one instance of the PAGED_CODE or PAGED_CODE_LOCKED macro"
