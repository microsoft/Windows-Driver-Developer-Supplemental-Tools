// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/branches
 * @kind path-problem
 * @name Branches
 * @description Get all function definition locations
 * @platform Desktop
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-TODOID
 * @problem.severity warning
 * @precision medium
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.libraries.interproccontrolflow.ControlFlow
import Flow::PathGraph
import semmle.code.cpp.ir.IR
import Flow::PathGraph

module Config implements ControlFlow::ConfigSig {
  predicate isSource(ControlFlow::Node source) {
    source.asExpr().getEnclosingFunction().hasName("main") and // start control-flow at the argv declaration
    source.asExpr().getAPredecessor().getControlFlowScope().hasName("main") and
    source.asExpr().(FunctionCall).getTarget().hasName("sdv_main")
  }

  predicate isSink(ControlFlow::Node sink) {
    sink.asExpr().(FunctionCall).getTarget().hasName("abort")
    //  sink.asExpr().(FunctionCall).getTarget().hasName("sdv_RunDispatchFunction")
  }
}

module Flow = ControlFlow::Global<Config>;

predicate isBranch(Flow::PathNode node) {
  node.getNode().asInstruction() instanceof ConditionalBranchInstruction or
  node.getNode().asInstruction() instanceof SwitchInstruction
}

Expr getBranchExpr(Flow::PathNode node) {
  result =
    node.getNode()
        .asInstruction()
        .(SwitchInstruction)
        .getExpression()
        .getUnconvertedResultExpression() or
  result =
    node.getNode()
        .asInstruction()
        .(ConditionalBranchInstruction)
        .getCondition()
        .getUnconvertedResultExpression()
}

from Flow::PathNode source, Flow::PathNode sink, Flow::PathNode intermediateNode
where
  Flow::flowPath(source, sink) and
  intermediateNode = source.getASuccessorImpl*() and
  isBranch(intermediateNode)
select getBranchExpr(intermediateNode), source, sink, "$@|$@",
  getBranchExpr(intermediateNode).(VariableAccess).getTarget().getADeclarationEntry(), "",
  intermediateNode.getNode().getLocation(), ""
