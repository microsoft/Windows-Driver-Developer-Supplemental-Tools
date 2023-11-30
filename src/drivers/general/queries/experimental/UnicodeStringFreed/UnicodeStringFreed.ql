// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/ke-set-event-irql
 * @name Unicode String Freed
 * @description UnicodeString objects created with RtlCreateUnicodeString must be freed with RtlFreeUnicodeString.
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       wddst
 * @kind path-problem
 */

import cpp
import semmle.code.cpp.dataflow.new.DataFlow

class UnicodeStringAccess extends VariableAccess {
  UnicodeStringAccess() { this.getType().getName() = "PUNICODE_STRING" }
}

class UnicodeString extends Variable {
  UnicodeString() {
    this.getType().getName() = "PUNICODE_STRING"
  }
}

module MyFlowConfiguration implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(FunctionCall rtlCreate |
      rtlCreate.getArgument(0).getAChild*() = source.asExpr() and
      rtlCreate.getTarget().getName() = ("RtlCreateUnicodeString")
    )
  }

  predicate isSink(DataFlow::Node sink) {
    exists(FunctionCall rtlFree |
      rtlFree.getArgument(0).getAChild*() = sink.asExpr() and
      rtlFree.getTarget().getName() = ("RtlFreeUnicodeString")
    )
  }

  predicate isAdditionalFlowStep(DataFlow::Node pred, DataFlow::Node succ) {
    exists(FunctionCall fc, DataFlow::VariableNode var |
      fc.getArgument(0).getAChild*() = pred.asExpr() and
      (
        fc.getTarget().getName() = ("RtlFreeUnicodeString")
        or
        fc.getTarget().getName() = ("RtlCreateUnicodeString")
      ) and
      fc.getArgument(0).getAChild*() instanceof UnicodeStringAccess
    |
      succ = var and
      var.asVariable() instanceof UnicodeString and
      var.asVariable() instanceof GlobalVariable and
      var.asVariable().getName() = fc.getArgument(0).(VariableAccess).getTarget().getName()
    )
  }
}

module Flow = DataFlow::Global<MyFlowConfiguration>;

from DataFlow::Node source
where
  not exists(DataFlow::Node sink | 
    Flow::flow(source, sink)
  ) 
and MyFlowConfiguration::isSource(source)

select source,
  "PUNICODE_STRING object $@ created with RtlCreateUnicodeString but not freed with RtlFreeUnicodeString ",source, source.toString()
