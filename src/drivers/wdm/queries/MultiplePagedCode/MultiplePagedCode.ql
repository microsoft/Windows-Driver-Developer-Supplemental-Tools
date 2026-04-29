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
 * @query-version v4
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
// `Stmt`.
//
// The same-file constraint on `mi`, `mi2` and `f` defends against ODR-
// equivalent template entities that the cpp extractor sometimes
// consolidates across headers (e.g. two driver-private headers each
// defining `template<class T> Foo()`); without the constraint, the inner
// `mi` could match a macro invocation in a sibling header that happens to
// share the consolidated `Function` entity.
from PagedCodeMacro mi2, Function f
where
  f = mi2.getEnclosingPagedFunction() and
  f.getFile() = mi2.getFile() and
  exists(PagedCodeMacro mi |
    mi.getEnclosingPagedFunction() = f and
    mi.getFile() = mi2.getFile() and
    mi.getLocation().getStartLine() < mi2.getLocation().getStartLine()
  )
select mi2,
  "Functions in a paged section must have exactly one instance of the PAGED_CODE or PAGED_CODE_LOCKED macro"
