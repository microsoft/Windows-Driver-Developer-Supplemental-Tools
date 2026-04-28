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

// Selects functions that have at least two PAGED_CODE/PAGED_CODE_LOCKED
// macro invocations on distinct source lines.
//
// Implementation note: ranges over the pre-filtered `PagedCodeMacro` class
// and uses `getEnclosingPagedFunction()` (defined in `Page.qll`), which
// routes through `MacroInvocation.getStmt().getEnclosingFunction()`. The
// stock `MacroInvocation.getEnclosingFunction()` is built on
// `getAnAffectedElement()` and materializes a relation that scales poorly
// on large codebases, causing analysis timeouts. `getStmt()` uses only the
// cheaper `inmacroexpansion` relation and returns the unique outermost
// `Stmt`, which gives a well-defined enclosing function without fanning
// out across template instantiations.
from PagedCodeMacro mi2, Function f
where
  f = mi2.getEnclosingPagedFunction() and
  exists(PagedCodeMacro mi |
    mi.getEnclosingPagedFunction() = f and
    mi.getLocation().getStartLine() < mi2.getLocation().getStartLine()
  )
select mi2,
  "Functions in a paged section must have exactly one instance of the PAGED_CODE or PAGED_CODE_LOCKED macro"
