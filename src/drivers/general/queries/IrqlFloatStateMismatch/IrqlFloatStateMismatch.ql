// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irql-float-state-mismatch
 * @kind problem
 * @name Irql Float State Mismatch
 * @description The IRQL where the floating-point state was saved does not match the current IRQL (for this restore operation).
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text The IRQL at which the driver is executing when it restores a floating-point state is different than the IRQL at which it was executing when it saved the floating-point state.
 * Because the IRQL at which the driver runs determines how the floating-point state is saved, the driver must be executing at the same IRQL when it calls the functions to save and to restore the floating-point state.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28111
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       ca_ported
 * @scope domainspecific
 * @query-version v6
 */

import cpp
import drivers.libraries.Irql
import semmle.code.cpp.dataflow.new.DataFlow

module FloatStateFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(FunctionCall fc |
      fc.getTarget().getName().matches("KeSaveFloatingPointState") and
      source.asIndirectExpr() = fc.getArgument(0)
    )
  }

  predicate isSink(DataFlow::Node sink) {
    exists(FunctionCall fc |
      fc.getTarget().getName().matches("KeRestoreFloatingPointState") and
      sink.asIndirectExpr() = fc.getArgument(0)
    )
  }
}

module FloatStateFlow = DataFlow::Global<FloatStateFlowConfig>;

/**
 * --- AI-generated ---
 *
 * Gets a source line in `f` that anchors `fc` from `f`'s perspective:
 *
 *   - If `fc`'s enclosing function is `f`, the anchor is `fc`'s own
 *     start line.
 *   - Otherwise, if `f` contains a call site whose static target is
 *     `fc`'s enclosing function, the anchor is that call site's start
 *     line. (One-level wrapper case.)
 *
 * This lets `irqlChangesBetween` reason about the relative source
 * position of the save and the restore in any function that either
 * directly contains the call or calls the helper that does.
 */
private int anchorLineForCall(Function f, FunctionCall fc) {
  f = fc.getEnclosingFunction() and
  result = fc.getLocation().getStartLine()
  or
  exists(FunctionCall site |
    site.getEnclosingFunction() = f and
    site.getTarget() = fc.getEnclosingFunction() and
    f != fc.getEnclosingFunction() and
    result = site.getLocation().getStartLine()
  )
}

/**
 * --- AI-generated ---
 *
 * Holds if some IRQL-changing call could run between `saveCall` and
 * `restoreCall` at runtime. Used as a sanity filter on top of the
 * dataflow result: dataflow already paired save -> restore, but
 * without this filter we'd flag pairs whose hypothetical entry IRQLs
 * differ even though no actual IRQL transition runs between them.
 *
 * Two additive disjuncts:
 *
 *  1. **Source-position branch.** A `FunctionCall` `mid` syntactically
 *     inside some `f` has `isIrqlChangingCall(mid)` and lies on a
 *     source line bracketed by `anchorLineForCall(f, save/restoreCall)`.
 *     Two cross-function reach mechanisms with different depth bounds
 *     cooperate: `anchorLineForCall` walks at most one call-graph edge
 *     (we need a concrete line in `f` to anchor each endpoint), but
 *     `isIrqlChangingCall` is transitively recursive through
 *     `isIrqlChangingFunction`, so `mid`'s target can chain through any
 *     number of wrappers before reaching a primitive (`KeRaiseIrql`,
 *     `_IRQL_raises_`, etc.).
 *
 *  2. **AST-loop branch.** All three calls share an enclosing loop body
 *     in the same function. The back-edge makes any IRQL-changing call
 *     in the loop a real transition between save and restore on a
 *     subsequent iteration, including when restore is textually above
 *     save (which makes branch 1's range empty).
 *
 * We use source-line bracketing rather than CFG reachability because
 * the extracted cpp CFG can drop forward edges across `if (call(...))`
 * and similar boundaries, silently losing TPs. The AST relation in
 * branch 2 is densely populated and avoids that gap.
 *
 * Caveat: `getPotentialExitIrqlAtCfn` doesn't always bind at save-call
 * argument expressions inside loop bodies in current extracted DBs, so
 * branch 2 can fire correctly while the upstream `irqlSource != irqlSink`
 * still filters it out. Recovering those needs work in `Irql.qll`.
 *
 * Performance: `pragma[inline_late]` + `bindingset[saveCall, restoreCall]`
 * specialize this per call site after dataflow has bound the endpoints,
 * turning a codebase-wide enumeration of (save, restore) pairs into a
 * per-pair check. Both annotations are planner hints; semantics unchanged.
 *
 * --- Human comments ---
 * 
 * Branch (1) wound up like this for perf reasons as well; a transitive 
 * check across all of the helper's internals gets expensive and in practice
 * if there are helper functions involved they're pretty shallow.
 */
bindingset[saveCall, restoreCall]
pragma[inline_late]
predicate irqlChangesBetween(FunctionCall saveCall, FunctionCall restoreCall) {
  // Branch 1: source-line bracketing in a function `f` that anchors
  // both calls (directly enclosing or one-level wrapper / common caller).
  exists(Function f, int saveLine, int restoreLine, FunctionCall mid |
    saveLine = anchorLineForCall(f, saveCall) and
    restoreLine = anchorLineForCall(f, restoreCall) and
    mid.getEnclosingFunction() = f and
    isIrqlChangingCall(mid) and
    mid.getLocation().getStartLine() >= saveLine and
    mid.getLocation().getStartLine() <= restoreLine and
    mid != saveCall and
    mid != restoreCall
  )
  or
  // Branch 2: all three calls live inside the body of the same loop in
  // their shared enclosing function. The loop back-edge makes any
  // IRQL-changing call in the body a real transition between save and
  // restore on a subsequent iteration, even when source-line position
  // would put restore before save.
  exists(Function f, Loop l, FunctionCall mid |
    f = saveCall.getEnclosingFunction() and
    f = restoreCall.getEnclosingFunction() and
    f = mid.getEnclosingFunction() and
    isIrqlChangingCall(mid) and
    mid != saveCall and
    mid != restoreCall and
    l.getStmt().getAChild*() = saveCall.getEnclosingStmt() and
    l.getStmt().getAChild*() = restoreCall.getEnclosingStmt() and
    l.getStmt().getAChild*() = mid.getEnclosingStmt()
  )
}

from
  DataFlow::Node source, DataFlow::Node sink, int irqlSink, int irqlSource,
  FunctionCall saveCall, FunctionCall restoreCall
where
  FloatStateFlow::flow(source, sink) and
  // FloatStateFlow's source/sink predicates already restrict the flow's
  // endpoints to be the first arguments of KeSaveFloatingPointState /
  // KeRestoreFloatingPointState. The two arg(0) equalities below
  // uniquely bind `saveCall` and `restoreCall` (each Expr has exactly
  // one parent FunctionCall), without re-stating the function-name
  // constraints.
  source.asIndirectExpr() = saveCall.getArgument(0) and
  sink.asIndirectExpr() = restoreCall.getArgument(0) and
  irqlSource = getPotentialExitIrqlAtCfn(source.asIndirectExpr()) and
  irqlSink = getPotentialExitIrqlAtCfn(sink.asIndirectExpr()) and
  irqlSink != irqlSource and
  // Only flag if there is an actual IRQL-changing call between the save
  // and the restore (in source order), in either the directly enclosing
  // function or a one-level wrapper / common-caller. If no IRQL-changing
  // call exists between them, the IRQL is invariant within a single
  // invocation and the mismatch is a may-analysis artifact from
  // different hypothetical entry IRQLs.
  irqlChangesBetween(saveCall, restoreCall)
select sink.asIndirectExpr(),
  "The irql level where the floating-point state was saved (" + irqlSource +
    ") does not match the irql level for the restore operation (" + irqlSink + ")."
