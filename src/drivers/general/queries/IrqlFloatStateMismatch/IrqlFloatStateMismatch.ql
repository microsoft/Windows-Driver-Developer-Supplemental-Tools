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
 * Holds if `fc` is a call that may change the IRQL.  This includes the
 * IRQL primitives (KeRaiseIrql, KeLowerIrql, KfRaiseIrql, KfLowerIrql,
 * etc.), functions annotated with _IRQL_raises_ or
 * _IRQL_saves_global_ / _IRQL_restores_global_, and functions whose
 * body itself transitively contains an IRQL-changing call (i.e.,
 * unannotated wrapper helpers).
 *
 * The transitive closure over the call graph is necessary to avoid
 * false negatives where a driver wraps the IRQL primitives in a helper
 * function without the appropriate SAL annotations.
 */
predicate isIrqlChangingFunction(Function f) {
  f instanceof IrqlChangesFunction
  or
  exists(FunctionCall inner |
    inner.getEnclosingFunction() = f and
    isIrqlChangingCall(inner)
  )
}

predicate isIrqlChangingCall(FunctionCall fc) {
  fc instanceof KeRaiseIrqlCall
  or
  fc instanceof KeLowerIrqlCall
  or
  fc instanceof RestoresGlobalIrqlCall
  or
  fc instanceof SavesGlobalIrqlCall
  or
  isIrqlChangingFunction(fc.getTarget())
}

/**
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
 * Holds if there is an IRQL-changing call between `saveCall` and
 * `restoreCall` in some function `f`. This predicate is a sanity filter
 * applied on top of the dataflow result: dataflow has already shown the
 * floating-point buffer flows from `saveCall` to `restoreCall`, and this
 * predicate ensures there is at least one IRQL transition that could
 * actually run between them.  Without it the query would emit the pure
 * may-analysis artifact where two save / restore sites are compared at
 * different hypothetical entry IRQLs but no IRQL transition can happen
 * between them at runtime.
 *
 * Two complementary disjuncts cooperate:
 *
 *  1. **Source-position branch.** For some `f`, an IRQL-changing call
 *     `mid` in `f` lies on a source line bracketed by the anchor lines
 *     of `saveCall` and `restoreCall` (see `anchorLineForCall`).  The
 *     anchor mechanism lets `f` be the directly enclosing function of
 *     both calls or a one-level wrapper / common caller, which covers
 *     the cross-function case that intra-procedural CFG cannot reach.
 *
 *  2. **AST-loop branch.** All three calls (`saveCall`, `restoreCall`,
 *     `mid`) sit inside the body of the same loop in their common
 *     enclosing function.  The loop back-edge means that at runtime
 *     each iteration's `restoreCall` can be preceded by the previous
 *     iteration's `saveCall` with `mid` between them, so an
 *     IRQL-changing `mid` anywhere in the loop body is a real
 *     transition between save and restore even when `restoreCall` is
 *     textually above `saveCall`.  Source-line position alone cannot
 *     express this: when the restore is textually earlier than the
 *     save the bracketing line range is empty and branch (1) trivially
 *     fails.
 *
 * The two branches are disjoint in spirit: branch (1) handles
 * cross-function and acyclic in-function cases; branch (2) handles
 * intra-function loops and re-entrant patterns.  Combining them is
 * strictly additive (can only enable more findings, never suppress one
 * that branch (1) would have flagged), so existing true positives are
 * preserved.
 *
 * Why not full intra-procedural CFG reachability instead of branch (1)?
 * The cpp control-flow graph in some extracted databases does not
 * transitively connect calls across certain statement boundaries (in
 * particular, forward reachability across `if (call(...))` conditions
 * is unreliable in our extracted DBs), which would silently eliminate
 * true positives that branch (1) catches via source-line bracketing.
 * AST-loop containment in branch (2) sidesteps this by relying on the
 * AST `Loop.getStmt().getAChild*()` relation, which is densely
 * populated and reflects the syntactic loop body directly.
 *
 * Caveat: branch (2) cooperates with `irqlSource != irqlSink` only when
 * the IRQL-analysis library binds `getPotentialExitIrqlAtCfn` at the
 * argument expression of `KeSaveFloatingPointState`. In our current
 * extracted DBs that binding is not always produced for `save` calls
 * inside loop bodies, so some real-world loop true positives may
 * still be filtered out by the upstream IRQL filter even when this
 * predicate fires; recovering those will require improvements to
 * the IRQL analysis library itself.
 */
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
