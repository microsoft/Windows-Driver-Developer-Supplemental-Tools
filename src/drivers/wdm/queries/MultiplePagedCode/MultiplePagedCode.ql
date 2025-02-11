// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/multiple-paged-code
 * @name Multiple instances of PAGED_CODE or PAGED_CODE_LOCKED
 * @description The function has more than one instance of PAGED_CODE or PAGED_CODE_LOCKED.  This can cause issues when debugging, using Code Analysis, or running on checked builds.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text The following code locations are duplicate PAGED_CODE() calls within a function.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28171
 * @kind problem
 * @problem.severity warning
 * @precision high
 * @tags correctness
 *       ca_ported
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.libraries.Page

// Selects functions that have at least two instances of a PAGED_CODE macro.
from MacroInvocation mi, MacroInvocation mi2
where
  mi.getEnclosingFunction() = mi2.getEnclosingFunction() and
  mi.getEnclosingFunction() instanceof PagedFunctionDeclaration and
  mi.getMacroName() = ["PAGED_CODE", "PAGED_CODE_LOCKED"] and
  mi2.getMacroName() = ["PAGED_CODE", "PAGED_CODE_LOCKED"] and
  mi.getLocation().getStartLine() < mi2.getLocation().getStartLine()
select mi2,
  "Functions in a paged section must have exactly one instance of the PAGED_CODE or PAGED_CODE_LOCKED macro"
