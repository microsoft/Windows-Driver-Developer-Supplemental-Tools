// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/query-template
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
import semmle.code.cpp.dataflow.new.DataFlow
import semmle.code.cpp.dataflow.new.TaintTracking
import drivers.wdm.libraries.WdmDrivers

module FlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source.asIndirectExpr().getType().toString().matches("%IRP%") 
  }

  predicate isSink(DataFlow::Node sink) {
    sink.asIndirectExpr() instanceof VariableAccess and
    sink.asIndirectExpr().getType().toString().matches("%IRP%") 
  }
}

module Flow = DataFlow::Global<FlowConfig>;

from FunctionCall fc1, FunctionCall fc2, Variable irp, VariableAccess va1, VariableAccess va2
where
  irp.getType().toString().matches("%IRP%") and
  exists(DataFlow::Node source, DataFlow::Node sink |
    Flow::flow(source, sink) and
    sink.asIndirectExpr().getEnclosingFunction() = fc1.getTarget() and
    va1 = sink.asIndirectExpr() and
    source.asIndirectExpr().(VariableAccess).getTarget() = irp
  ) and
  exists(DataFlow::Node source, DataFlow::Node sink |
    Flow::flow(source, sink) and
    sink.asIndirectExpr().getEnclosingFunction() = fc2.getTarget() and
    va2 = sink.asIndirectExpr() and
    source.asIndirectExpr().(VariableAccess).getTarget() = irp
  ) and
  fc1.getTarget() instanceof WdmCallbackRoutine and
  fc2.getTarget() instanceof WdmCallbackRoutine and
  fc1 != fc2

select irp, "Same IRP $@ used in two callback routines: $@ and $@", irp, irp.toString(), fc1, fc1.toString(), fc2, fc2.toString() 
