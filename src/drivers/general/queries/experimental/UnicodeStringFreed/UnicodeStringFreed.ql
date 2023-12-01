// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/unicode-string-not-freed
 * @name Unicode String Not Freed
 * @description UnicodeString objects created with RtlCreateUnicodeString must be freed with RtlFreeUnicodeString.
 * @platform Desktop
 * @security.severity Medium
 * @feature.area Multiple
 * @impact Exploitable Design
 * @repro.text A UNICODE_STRING object is created with RtlCreateUnicodeString but not freed with RtlFreeUnicodeString.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-D0006
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */


import cpp
import semmle.code.cpp.dataflow.new.DataFlow

class UnicodeStringAccess extends VariableAccess {
  UnicodeStringAccess() { this.getTarget() instanceof UnicodeString }
}

class UnicodeString extends Variable {
  UnicodeString() { this.getType().getName() = "PUNICODE_STRING" }
}

module UnicodeStringDataFlowConfig implements DataFlow::ConfigSig {
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

module Flow = DataFlow::Global<UnicodeStringDataFlowConfig>;

from DataFlow::Node source
where
  not exists(DataFlow::Node sink | Flow::flow(source, sink)) and
  UnicodeStringDataFlowConfig::isSource(source)
select source,
  "PUNICODE_STRING object $@ created with RtlCreateUnicodeString but not freed with RtlFreeUnicodeString",
  source.asExpr(), source.asExpr().toString()
