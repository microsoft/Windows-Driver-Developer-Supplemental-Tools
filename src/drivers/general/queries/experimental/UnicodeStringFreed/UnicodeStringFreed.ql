// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/ke-set-event-irql
 * @name KeSetEvent called at wrong IRQL
 * @description KeSetEvent must be called at DISPATCH_LEVEL or below.  If the Wait argument is set to TRUE, it must be called at APC_LEVEL or below.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Exploitable Design
 * @repro.text The following call to KeSetEvent occurs at too high of an IRQL.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-D0005
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
  UnicodeStringAccess() { this.getType().getName() = "PUNICODE_STRING" }
}

class UnicodeString extends Variable {
  UnicodeString() { this.getType().getName() = "PUNICODE_STRING" and this instanceof GlobalVariable }
  
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
      fc.getArgument(0).getAChild*() = pred.asExpr()
      and(
        fc.getTarget().getName() = ("RtlFreeUnicodeString")
        or
        fc.getTarget().getName() = ("RtlCreateUnicodeString")
      )
      and fc.getArgument(0).getAChild*() instanceof UnicodeStringAccess
    |
      succ = var and 
      var.asVariable() instanceof UnicodeString and
      var.asVariable() instanceof GlobalVariable and 
      var.asVariable().getName() = fc.getArgument(0).(VariableAccess).getTarget().getName() 
      // rtlCreate.getArgument(0).getAChild*() = source.asExpr() and
      // rtlCreate.getTarget().getName() = ("RtlCreateUnicodeString") and
      // rtlFree.getArgument(0).getAChild*() = sink.asExpr() and
      // rtlFree.getTarget().getName() = ("RtlFreeUnicodeString") and
      // rtlFree.getArgument(0).getAChild*() = var.asExpr()
      // getArgument(0) = var.asIndirectArgument()
    )
  }
}

module Flow = DataFlow::Global<MyFlowConfiguration>;

from DataFlow::Node source, DataFlow::Node sink
where Flow::flow(source, sink)
select source, "This " + source + " uses data from $@.", sink, sink.toString()
/*
 * from FunctionCall rtlCreate, VariableAccess unicodeString, VariableAccess freeString
 * where
 *  rtlCreate.getTarget().getName() = "RtlCreateUnicodeString" and
 *  unicodeString = rtlCreate.getArgument(0) and
 *  exists(FunctionCall rtlFree |
 *    rtlFree.getTarget().getName() = "RtlFreeUnicodeString" and
 *    rtlFree.getArgument(0) = freeString
 *  ) and
 *  freeString.getTarget() = unicodeString.getTarget()
 *  and exists(GlobalVariable g | g.getADeclarationEntry() = unicodeString.getTarget().getADeclarationEntry())
 *
 * select unicodeString, "Function " + rtlCreate + " arg " + unicodeString + " " + freeString
 */

