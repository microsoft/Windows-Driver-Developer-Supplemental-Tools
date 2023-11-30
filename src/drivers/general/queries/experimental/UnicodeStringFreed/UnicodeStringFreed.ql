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

class UnicodeString extends VariableAccess {
  UnicodeString() { this.getType().getName() = "PUNICODE_STRING" }
}

module MyFlowConfiguration implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(FunctionCall rtlCreate |
      //source.asIndirectExpr() = rtlCreate.getArgument(0) and
      rtlCreate.getArgument(0).getAChild*() = source.asExpr() and
      rtlCreate.getTarget().getName() = ("RtlCreateUnicodeString")
    )
  }

  predicate isSink(DataFlow::Node sink) {
    exists(FunctionCall rtlFree |
      // sink.asIndirectExpr() = rtlFree.getArgument(0) and
      rtlFree.getArgument(0).getAChild*() = sink.asExpr() and
      rtlFree.getTarget().getName() = ("RtlFreeUnicodeString")
    )
  }

  predicate isAdditionalFlowStep(DataFlow::Node source, DataFlow::Node sink) {
  //  source instanceof DataFlow::VariableNode or sink instanceof DataFlow::VariableNode
  exists( FunctionCall fc, DataFlow::VariableNode var |
   ( var = source and
    fc.getArgument(0).getAChild*() = sink.asExpr() ) or 
    ( var = sink and
    fc.getArgument(0).getAChild*() = source.asExpr() ) and

    // fc.getArgument(0).getAChild*() = source.asExpr() and

   ( fc.getTarget().getName() = ("RtlFreeUnicodeString")
   or fc.getTarget().getName() = ("RtlCreateUnicodeString")
  )
  )
  }
}

module Flow = DataFlow::Global<MyFlowConfiguration>;

from DataFlow::Node source, DataFlow::Node sink
where 
Flow::flow(source, sink)
select source, "This " + source.toString() + " uses data from $@.", sink, sink.toString()
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

