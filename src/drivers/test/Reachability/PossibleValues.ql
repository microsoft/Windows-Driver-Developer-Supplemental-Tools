// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/precondition-roletypes
 * @kind path-problem
 * @name FunctionLocationsPrecondition
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
import semmle.code.cpp.interproccontrolflow.ControlFlow
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

BasicBlock getAssignedValue(Flow::PathNode node) {
  result = getBranchExpr(node).(VariableAccess).getTarget().getAnAssignment().getBasicBlock() or 
  result = getEqualityOperand(node).(VariableAccess).getTarget().getAnAssignment().getBasicBlock()
}
Operand getCase(Flow::PathNode node) {
  node.getNode().asInstruction().(SwitchInstruction).getACaseSuccessor().getAnOperand() = result
}

Expr getEqualityOperand(Flow::PathNode node) {
  exists(EqualityOperation eo |
    getBranchExpr(node) = eo and
    result = eo.getAnOperand()
  )
  or
  (
    result = getBranchExpr(node) and
    not result instanceof EqualityOperation
  )

}
from
  Flow::PathNode source, Flow::PathNode sink, Flow::PathNode intermediateNode, Expr equalityOperand
where
  Flow::flowPath(source, sink) and
  intermediateNode = source.getASuccessorImpl*() and
  isBranch(intermediateNode) and
  (
    getEqualityOperand(intermediateNode) = equalityOperand
  )
  // TODO check if state machine assignment is in flow path
select intermediateNode, source, sink, "$@|$@", intermediateNode, intermediateNode.toString(),
  // getBranchExpr(intermediateNode).(VariableAccess).getTarget().getADeclarationEntry(),getBranchExpr(intermediateNode).(VariableAccess).getTarget().getADeclarationEntry().toString(), // TODO this prevents ..==.. branch exprs
  //getAssignedValue(intermediateNode), getAssignedValue(intermediateNode).toString()
  // // TODO need to check each side of a ..==.. branch expr
  // intermediateNode.getNode().getLocation(), intermediateNode.getNode().getLocation().toString()
  equalityOperand, equalityOperand.toString()
