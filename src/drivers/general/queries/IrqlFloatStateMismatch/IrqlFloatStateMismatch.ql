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
 * @query-version v2
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
predicate isIrqlChangingCfn(ControlFlowNode cfn) {
  cfn instanceof KeRaiseIrqlCall
  or
  cfn instanceof KeLowerIrqlCall
  or
  cfn instanceof RestoresGlobalIrqlCall
  or
  cfn instanceof SavesGlobalIrqlCall
  or
  (
    cfn instanceof FunctionCall and
    cfn.(FunctionCall).getTarget() instanceof IrqlChangesFunction
  )
}

/**
 * Holds if there is an IRQL-changing call on some CFG path between
 * `save` and `restore` within the same function.
 */
predicate irqlChangesBetween(ControlFlowNode save, ControlFlowNode restore) {
  exists(ControlFlowNode mid |
    mid.getControlFlowScope() = save.getControlFlowScope() and
    isIrqlChangingCfn(mid) and
    save.getASuccessor+() = mid and
    mid.getASuccessor+() = restore
  )
}

from DataFlow::Node source, DataFlow::Node sink, int irqlSink, int irqlSource
where
  FloatStateFlow::flow(source, sink) and
  irqlSource = getPotentialExitIrqlAtCfn(source.asIndirectExpr()) and
  irqlSink = getPotentialExitIrqlAtCfn(sink.asIndirectExpr()) and
  irqlSink != irqlSource and
  // Only flag if there is an actual IRQL-changing operation between save and restore.
  // If no IRQL-changing call exists, the IRQL is invariant within a single invocation
  // and the mismatch is a may-analysis artifact from different hypothetical entry IRQLs.
  irqlChangesBetween(source.asIndirectExpr(), sink.asIndirectExpr())
select sink.asIndirectExpr(),
  "The irql level where the floating-point state was saved (" + irqlSource +
    ") does not match the irql level for the restore operation (" + irqlSink + ")."
