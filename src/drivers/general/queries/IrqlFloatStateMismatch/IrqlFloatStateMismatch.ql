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
 * @query-version v3
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
 * Holds if `cfn` is a call to a function that may change the IRQL.
 * This includes KeRaiseIrql, KeLowerIrql, functions annotated with
 * _IRQL_raises_, and functions annotated with _IRQL_saves_global_ /
 * _IRQL_restores_global_ (which imply spinlock acquire/release patterns).
 */
predicate isIrqlChangingCall(FunctionCall fc) {
  fc instanceof KeRaiseIrqlCall
  or
  fc instanceof KeLowerIrqlCall
  or
  fc instanceof RestoresGlobalIrqlCall
  or
  fc instanceof SavesGlobalIrqlCall
  or
  fc.getTarget() instanceof IrqlChangesFunction
}

/**
 * Holds if there is an IRQL-changing call in the same function as
 * `saveCall` and `restoreCall` whose source location lies (textually)
 * between them. This is intentionally a source-position check rather
 * than a CFG reachability check: the cpp control-flow graph in some
 * extracted databases does not transitively connect calls across
 * statement boundaries, which would silently eliminate true positives.
 *
 * The intent of the filter is to suppress mismatches in functions
 * that have no IRQL transition at all (where the apparent
 * save/restore IRQL difference is purely a may-analysis artifact
 * from multiple hypothetical entry IRQLs).
 */
predicate irqlChangesBetween(FunctionCall saveCall, FunctionCall restoreCall) {
  exists(FunctionCall mid, Function f |
    f = saveCall.getEnclosingFunction() and
    f = restoreCall.getEnclosingFunction() and
    f = mid.getEnclosingFunction() and
    isIrqlChangingCall(mid) and
    mid.getLocation().getStartLine() >= saveCall.getLocation().getStartLine() and
    mid.getLocation().getStartLine() <= restoreCall.getLocation().getStartLine() and
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
