// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * Provides data-flow analyses used in calculating the IRQL in a Windows driver.
 */


import cpp
import drivers.libraries.Irql
import semmle.code.cpp.dataflow.new.DataFlow


/**
 * A data-flow configuration describing flow from a
 * KeRaiseIrqlCall to a KeLowerIrqlCall.
 */
module IrqlRaiseLowerFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source.asExpr() instanceof KeRaiseIrqlCall }

  predicate isSink(DataFlow::Node sink) {
   exists(KeLowerIrqlCall firf |
     sink.asExpr() = firf.getArgument(firf.getTarget().(IrqlRestoreFunction).getIrqlIndex())
   )
 }
}

module IrqlRaiseLowerFlow = DataFlow::Global<IrqlRaiseLowerFlowConfig>;
/**
 * A function that has at least one parameter annotated with "\_IRQL\_restores\_".
 */
class IrqlRestoreFunction extends Function {
  Parameter p;
  int irqlIndex;

  IrqlRestoreFunction() {
    p = this.getParameter(irqlIndex) and
    p instanceof IrqlRestoreParameter
  }

  Parameter getRestoreParameter() { result = p }

  int getIrqlIndex() { result = irqlIndex }
}