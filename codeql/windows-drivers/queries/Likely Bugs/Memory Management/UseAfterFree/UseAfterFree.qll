// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

import cpp
import microsoft.code.cpp.windows.kernel.KernelMode
import microsoft.code.cpp.aliasing.LocalAliasing
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.dataflow.TaintTracking
import semmle.code.cpp.controlflow.Guards
private import semmle.code.cpp.dataflow.RecursionPrevention

/**
 * Data flow configuration tracking flow from expressions or parameters of pointer type
 * to their accesses.
 */
class PointerConfig extends DataFlow::Configuration {
  PointerConfig() { this = "PointerConfig" }
  
  override predicate isSource(DataFlow::Node n) {
    hasPointerType(n) and
    // restrict to non-null values, as these are safe to repeatedly free
    not n.asExpr() instanceof NullValue
  }
  
  override predicate isSink(DataFlow::Node n) {
    hasPointerType(n) and
    n.asExpr() instanceof VariableAccess
  }
}

/** Holds if the data flow node `n` is an expression or parameter of pointer type. */
predicate hasPointerType(DataFlow::Node n) {
  n.asExpr().getFullyConverted() instanceof PointerExpr or
  n.asParameter().getType().getUnderlyingType().getUnspecifiedType() instanceof PointerType
}

/**
 * A call that frees an argument, either directly or
 * by interprocedurally passing it to a free call within the callee.
 */
class EffectiveFreeCall extends FunctionCall {
  Expr freedArg;
  EffectiveFreeCall() {
    freedArg = this.getAnArgument() and
    exists(FreeCall freeCall, VariableAccess freedAccess, PointerConfig config |
      freeCall.getFreedVariableAccess() = freedAccess and
      // the argument of this call flows to the freed variable access
      config.hasFlow(DataFlow::exprNode(freedArg), DataFlow::exprNode(freedAccess)) and
      // but the result of this call does not; this avoids spuriously flagging pass-through functions
      not config.hasFlow(DataFlow::exprNode(this), DataFlow::exprNode(freedAccess))
    )
  }
  
  /** Gets an argument of this call that is freed. */
  Expr getAFreedArgument() {
    result = freedArg
  }
}

/**
 * Holds if `n` is a transitive control flow successor of `freeCall`, without going
 * through any reassignments or dereferences of the freed variable.
 */
private predicate reachesWithoutReassignment(EffectiveFreeCall freeCall, ControlFlowNode n) {
  // base case
  n = freeCall or
  // recursive step
  exists(ControlFlowNode mid | reachesWithoutReassignment(freeCall, mid) |
    n = mid.getASuccessor() and
    not mid.(Dereference) = freeCall.getAFreedArgument().(VariableAccess).getTarget().getAnAccess() and
    // avoid reassignments to the freed variable, its qualifier, or a directly aliased pointer
    not exists(Variable v, VariableAccess freedArg | freedArg = freeCall.getAFreedArgument() and n = getAReassignment(v) |
      v.getAnAccess() = freedArg or
      v.getAnAccess() = freedArg.getQualifier().getAChild*() or
      v.getAnAccess() = freedArg.getTarget().getAnAssignedValue()
    )
  )
}

/** Gets a control flow node that reassigns or accesses the address of the variable `v`. */
private ControlFlowNode getAReassignment(Variable v) {
  result = v.getAnAssignedValue() or
  result.(CrementOperation).getOperand() = v.getAnAccess() or
  result.(Assignment).getLValue() = v.getAnAccess() or
  (result = v.getAnAccess() and result.(Expr).getParent() instanceof AddressOfExpr)
}

/**
 * Holds if `va1` and `va2` are variable accesses that may reference the same memory value from `source`,
 * `va1` may be freed by `call`, and `va2` occurs after `call`. This means `va2` is a likely use after free.
 */
predicate useAfterFree(DataFlow::Node source, EffectiveFreeCall call, VariableAccess va1, VariableAccess va2) {
  va1 = call.getAFreedArgument() and
  // the same source value is accessed
  exists(PointerConfig config |
    config.hasFlow(source, DataFlow::exprNode(va1)) and
    config.hasFlow(source, DataFlow::exprNode(va2))
  ) and
  // the second access is a successor of the free call
  reachesWithoutReassignment(call, va2) and
  // if the source value is null, ensure the accesses are not guarded by null checks on the freed variable
  (
    (source.asExpr() instanceof NullValue) implies
    (
      not (falseCheck(_, va1.getTarget().getAnAccess(), va1.getBasicBlock(), true)) and
      not (falseCheck(_, va2.getTarget().getAnAccess(), va2.getBasicBlock(), true))
    )
  ) and
  // simple exclusions
  not va2 = any(Variable v).getAnAssignedValue() and
  not va2 = any(EqualityOperation o).getAnOperand() and
  not va2 = any(SizeofExprOperator s).getAChild*()
}


/**
 * Holds if `guard` ensures the variable accessed by `checked` has
 * the truth value `truthValueInBlock` within the basic block `block`
 * (by either examining it directly or comparing it with a constant such as `NULL`).
 */
private predicate falseCheck(GuardCondition guard, VariableAccess checked, BasicBlock block, boolean truthValueInBlock) {
  guard.controls(block, _) and
  (
    // if(p)
    (guard = checked and truthValueInBlock = true) or
    // if(!p)
    (guard.(NotExpr).getAnOperand() = checked and truthValueInBlock = false) or
    // if(p == NULL), if(p != NULL)
    exists(Expr left, Expr right |
      guard.ensuresEq(left, right, 0, block, truthValueInBlock.booleanNot()) and
      (
        left = checked and right instanceof NullValue or
        right = checked and left instanceof NullValue
      )
    )
  )
}
