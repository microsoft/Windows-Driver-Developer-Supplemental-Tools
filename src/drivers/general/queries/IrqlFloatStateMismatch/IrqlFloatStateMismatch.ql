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
 * @query-version v5
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
 * Holds if there is an IRQL-changing call in some function `f` whose
 * source line lies between the save anchor and the restore anchor in
 * `f`. The anchor mechanism (see `anchorLineForCall`) lets `f` be:
 *
 *   - the enclosing function of both `saveCall` and `restoreCall`
 *     (the original same-function case),
 *   - the common caller that calls thin save / restore helper
 *     wrappers,
 *   - the enclosing function of one of the two calls when the other
 *     is in a one-level helper called from it (asymmetric case).
 *
 * The dataflow library has already established that the floating-
 * point buffer flows from `saveCall` to `restoreCall`; this predicate
 * is purely a sanity filter to suppress the pure may-analysis
 * artifact where two save / restore sites are compared at different
 * hypothetical entry IRQLs but no IRQL transition can actually happen
 * at runtime between them.
 *
 * The position-based check (rather than a CFG-reachability check) is
 * required because the cpp control-flow graph in some extracted
 * databases does not transitively connect calls across statement
 * boundaries, which would silently eliminate true positives.
 */
predicate irqlChangesBetween(FunctionCall saveCall, FunctionCall restoreCall) {
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
}

from
  DataFlow::Node source, DataFlow::Node sink, int irqlSink, int irqlSource,
  FunctionCall saveCall, FunctionCall restoreCall
where
  FloatStateFlow::flow(source, sink) and
  saveCall.getTarget().getName().matches("KeSaveFloatingPointState") and
  source.asIndirectExpr() = saveCall.getArgument(0) and
  restoreCall.getTarget().getName().matches("KeRestoreFloatingPointState") and
  sink.asIndirectExpr() = restoreCall.getArgument(0) and
  irqlSource = getPotentialExitIrqlAtCfn(source.asIndirectExpr()) and
  irqlSink = getPotentialExitIrqlAtCfn(sink.asIndirectExpr()) and
  irqlSink != irqlSource and
  // Only flag if there is an actual IRQL-changing call in the same function
  // between save and restore (in source order). If no IRQL-changing call
  // exists between them, the IRQL is invariant within a single invocation
  // and the mismatch is a may-analysis artifact from different hypothetical
  // entry IRQLs.
  irqlChangesBetween(saveCall, restoreCall)
select sink.asIndirectExpr(),
  "The irql level where the floating-point state was saved (" + irqlSource +
    ") does not match the irql level for the restore operation (" + irqlSink + ")."
