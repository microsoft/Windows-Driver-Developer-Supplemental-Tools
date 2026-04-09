// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/wdm/double-completion
 * @kind problem
 * @name WdmDoubleCompletion
 * @description A WDM driver must not call IoCompleteRequest twice on the same IRP.
 *              Double-completing an IRP corrupts kernel memory and can crash the system.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Exploitable Design Issue
 * @owner.email sdat@microsoft.com
 * @opaqueid SDV-DoubleCompletion-WDM
 * @problem.severity error
 * @precision high
 * @tags correctness
 *       wdm
 *       sdv-ported
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import semmle.code.cpp.dataflow.new.DataFlow
import semmle.code.cpp.controlflow.Dominance

/** A call to IoCompleteRequest or IofCompleteRequest. */
class IoCompleteRequestCall extends FunctionCall {
  IoCompleteRequestCall() {
    this.getTarget().getName() = ["IoCompleteRequest", "IofCompleteRequest"]
  }

  Expr getIrpArg() { result = this.getArgument(0) }
}

module WdmDoubleCompletionConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(IoCompleteRequestCall call | source.asExpr() = call.getIrpArg())
  }

  predicate isSink(DataFlow::Node sink) {
    exists(IoCompleteRequestCall call | sink.asExpr() = call.getIrpArg())
  }
}

module WdmDoubleCompletionFlow = DataFlow::Global<WdmDoubleCompletionConfig>;

from IoCompleteRequestCall first, IoCompleteRequestCall second
where
  first != second and
  first.getEnclosingFunction() = second.getEnclosingFunction() and
  first.getASuccessor+() = second and
  WdmDoubleCompletionFlow::flow(
    DataFlow::exprNode(first.getIrpArg()),
    DataFlow::exprNode(second.getIrpArg())
  )
select second,
  "IoCompleteRequest is called twice on the same IRP. " +
    "The first call is $@. Double-completing an IRP corrupts kernel memory.",
  first, "here"
