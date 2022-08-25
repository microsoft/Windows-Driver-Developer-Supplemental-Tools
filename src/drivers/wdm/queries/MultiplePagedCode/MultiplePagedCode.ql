// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name MultiplePagedCode
 * @kind problem
 * @platform Desktop
 * @description The function has more than one instance of PAGED_CODE or PAGED_CODE_LOCKED.
 * @problem.severity warning
 * @feature.area Multiple
 * @repro.text The following code locations potentially contain dupulicate PAGED_CODE() calls.
 * @id cpp/portedqueries/multiple-paged-code
 * @version 1.0
 */

import cpp
import drivers.libraries.Page

//Selects routines with two at least two PAGE_CODE invocations inside one function
from MacroInvocation mi, MacroInvocation mi2
where
  mi.getEnclosingFunction() = mi2.getEnclosingFunction() and
  mi.getMacroName() = ["PAGED_CODE", "PAGED_CODE_LOCKED"] and
  mi2.getMacroName() = ["PAGED_CODE", "PAGED_CODE_LOCKED"] and
  mi.getLocation().getStartLine() < mi2.getLocation().getStartLine()
select mi2,
  "Functions in a paged section must have exactly one instance of the PAGED_CODE or PAGED_CODE_LOCKED macro"
