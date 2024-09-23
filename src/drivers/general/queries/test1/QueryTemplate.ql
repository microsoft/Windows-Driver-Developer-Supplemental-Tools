// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/TODO
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
import semmle.code.cpp.controlflow.ControlFlowGraph
import drivers.libraries.OSModel

predicate isSinkImpl(DataFlow::Node sink, Type t){
  exists(FunctionCall f, Expr lock |
    f.getTarget().getName().matches("IoReleaseRemoveLock%") and
    lock.getParent*() = f and
    lock.getType().toString().matches("IO_REMOVE_LOCK") and
    lock.(PointerFieldAccess).getQualifier() =  [sink.asIndirectExpr(), sink.asExpr()] and 
    t = lock.getUnspecifiedType()
    )
  }

module FlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(FunctionCall f, Expr lock |
      f.getTarget().getName().matches("IoAcquireRemoveLock%") and
      lock.getParent*() = f and
      lock.getType().toString().matches("IO_REMOVE_LOCK") and
      lock.(PointerFieldAccess).getQualifier() = [source.asIndirectExpr(), source.asExpr()]
    )
  }

  //predicate isBarrierIn(DataFlow::Node node) {  }

  // predicate isAdditionalFlowStep(DataFlow::Node n1, DataFlow::Node n2) {
  //   n1.asIndirectExpr().getType().toString().matches("%DEVICE_OBJECT%") and

  //   n2.asIndirectExpr().getType().toString().matches("%DEVICE_OBJECT%") and 
  //   n2.getEnclosingCallable() instanceof OsCalledFunction
  //   and n1.getEnclosingCallable() != n2.getEnclosingCallable()
  // }
  // predicate isSink(DataFlow::Node sink) {
  //   isSinkImpl(sink, _)
  // }
  predicate isAdditionalFlowStep(DataFlow::Node n1, DataFlow::Node n2) {
    exists(FieldAccess fa |
      n1.asIndirectExpr() = fa.getQualifier() and
      n2.asExpr() = fa
    )
  }
  predicate isSink(DataFlow::Node sink) {
    exists(Call call |
      call.getTarget() instanceof OsCalledFunction and
      sink.asIndirectExpr() = call.getAnArgument()
    )
    }
  // predicate allowImplicitRead(DataFlow::Node node, DataFlow::ContentSet content) {
  //   // flow out from fields at the sink (only).
  //   // constrain `content` to a field inside the node.
  //   //isSink(node) and
  //   content.getAReadContent().(DataFlow::FieldContent).getField().hasName(["%"])
    
  // }
}
module Flow = DataFlow::Global<FlowConfig>;
import Flow::PathGraph
from Flow::PathNode source, FunctionCall f, Flow::PathNode sink
where
  // f.getTarget().getName().matches("IoAcquireRemoveLock%") and
  // f.getArgument(0) = source.asIndirectExpr() and
 //exists(DataFlow::Node sink |
    Flow::flowPath(source, sink)
    and source != sink
 // )
select f, source, sink, "message"









/*
BasicBlock getCallers(BasicBlock bb) {
  result = bb
  or
  if bb.isReachable() and exists(bb.getAPredecessor())
  then result = getCallers(bb.getAPredecessor())
  else
    if bb.getEnclosingFunction().getName().matches("main")
    then result = bb
    else
      exists(FunctionCall fc |
        bb.getEnclosingFunction() = fc.getTarget() and
        result = getCallers(fc.getEnclosingBlock())
      )
}

// enclosing functino of access to va such that va is a parameter of fc, and fc is reachable from main
Function getReachableParentFuncion(VariableAccess va, FunctionCall fc) {
  exists(BasicBlock bb, BasicBlock caller |
    bb = va.getEnclosingBlock() and
    caller = getCallers(bb) and
    caller != bb and
    result = bb.getEnclosingFunction() and
    va.getParent*() = fc
  )
}

from Variable v, FunctionCall fcAcc, Function f1
where
  v.getType().toString().matches("%IO_REMOVE_LOCK") and
  fcAcc.getTarget().getName().matches("IoAcquireRemoveLock%") and
  f1 = getReachableParentFuncion(v.getAnAccess(), fcAcc) and
  not exists(FunctionCall fcRel, Function f2 |
    fcRel.getTarget().getName().matches("IoReleaseRemoveLock%") and
    f2 = getReachableParentFuncion(v.getAnAccess(), fcRel) and
    f1 != f2
  )
select v, "IO_REMOVE_LOCK object $@ acquired here $@ but not released", v, v.toString(), f1, f1.toString()
*/