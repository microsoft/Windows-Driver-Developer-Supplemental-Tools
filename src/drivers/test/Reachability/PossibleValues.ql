// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/possible-values
 * @kind path-problem
 * @name Possible Values
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

Expr getAssignedValue(Flow::PathNode node) {
      exists(Expr e 
        |(e=getBranchExpr(node).(VariableAccess).getTarget().getAnAssignment().(Assignment).getRValue() or
      e = getEqualityOperand(node).(VariableAccess).getTarget().getAnAssignment().(Assignment).getRValue())
      and result = e
  )
}

Operand getCase(Flow::PathNode node) {
  node.getNode().asInstruction().(SwitchInstruction).getACaseSuccessor().getAnOperand() = result
}

VariableAccess getBranchVariableAccess(Flow::PathNode node) {
  exists(EqualityOperation eo |
    getBranchExpr(node) = eo and
    result = eo.getAnOperand()
  )
  or
  result = getBranchExpr(node)
}

Expr getEqualityOperand(Flow::PathNode node) {
  exists(EqualityOperation eo |
    getBranchExpr(node) = eo and
    result = eo.getAnOperand()
  )
  or
  result = getBranchExpr(node) and
  not result instanceof EqualityOperation
}

// from
//   Flow::PathNode source, Flow::PathNode sink, Flow::PathNode intermediateNode, Expr equalityOperand,
//   BasicBlock assignedValBlock
// where
//   Flow::flowPath(source, sink) and
//   intermediateNode = source.getASuccessorImpl*() and
//   isBranch(intermediateNode) and
//   getEqualityOperand(intermediateNode) = equalityOperand and
//   assignedValBlock = getAssignedValue(intermediateNode)
// select intermediateNode, source, sink, "$@|$@", intermediateNode, intermediateNode.toString(),
//   assignedValBlock, assignedValBlock.toString()


from
  Flow::PathNode source, Flow::PathNode sink, Flow::PathNode intermediateNode, Expr equalityOperand,
  Expr assignedVal
where
  Flow::flowPath(source, sink) and
  intermediateNode = source.getASuccessorImpl*() and
  isBranch(intermediateNode) and
  getEqualityOperand(intermediateNode) = equalityOperand and
  assignedVal = getAssignedValue(intermediateNode)  
select intermediateNode, source, sink, "$@|$@", intermediateNode, intermediateNode.toString(),
  assignedVal, assignedVal.toString()
