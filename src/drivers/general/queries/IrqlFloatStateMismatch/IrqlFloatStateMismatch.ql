// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/TODO
 * @kind problem
 * @name TODO
 * @description TODO
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-TODO
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
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

from ControlFlowNode sourceCfn, ControlFlowNode sinkCfn, DataFlow::Node source, DataFlow::Node sink
where
  // fc.getTarget().getName().matches("KeSaveFloatingPointState")
  // and cfn = fc
  // and irql = getPotentialExitIrqlAtCfn(cfn)
  FloatStateFlow::flow(source, sink) and
  sourceCfn = source.asExpr() and
  sinkCfn = sink.asExpr() 
  // and
  // getPotentialExitIrqlAtCfn(sourceCfn) != getPotentialExitIrqlAtCfn(sinkCfn)
select source,getPotentialExitIrqlAtCfn(sourceCfn), sink,getPotentialExitIrqlAtCfn(sinkCfn)
