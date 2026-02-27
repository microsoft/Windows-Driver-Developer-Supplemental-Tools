// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/microsoft/public/likely-bugs/uninitializedptrfield
 * @name Dereference of potentially uninitialized pointer field
 * @description A pointer field which was not initialized during or since class
 *              construction will cause a null pointer dereference.
 * @kind problem
 * @problem.severity warning
 * @tags security
 *       external/cwe/cwe-476
 * @opaqueid SM02310
 * @owner.email sdat@microsoft.com
 * @microsoft.severity Important
 */

import cpp
import semmle.code.cpp.controlflow.StackVariableReachability
import semmle.code.cpp.valuenumbering.HashCons

/*
 * Utilities
 */

/**
 * Go through user-specified implicit conversions. It's a bug that the library
 * doesn't handle this
 */
Expr afterUserConversions(Expr source) {
  if result.(Call).getTarget() instanceof ImplicitConversionFunction
  then result.(Call).getQualifier() = afterUserConversions(source)
  else result = source
}

/**
 * An expression that may be returned by f.
 */
Expr mayReturn(Function f) {
  exists(ReturnStmt s |
    s.getExpr() = result and
    s.getEnclosingFunction() = f
  )
}

/**
 * An instance of unary operator & applied to a user-defined type.
 */
class OverloadedAddressOfExpr extends FunctionCall {
  OverloadedAddressOfExpr() {
    getTarget().hasName("operator&") and
    getTarget().getEffectiveNumberOfParameters() = 1
  }

  /**
   * Gets the expression this operator & applies to.
   */
  Expr getExpr() {
    result = this.getChild(0) or
    result = this.getQualifier()
  }
}

/**
 * An address of v.
 */
Expr addressOf(Expr value) {
  exists(Expr e | result = afterUserConversions(e) |
    e.(AddressOfExpr).getOperand() = value
    or
    e.(OverloadedAddressOfExpr).getExpr() = value
  )
}

Field assignedNonNull(Function f) {
  exists(Function sub, Assignment a, Expr init |
    f.calls*(sub) and
    a.getEnclosingFunction() = sub and
    a.getLValue() = result.getAnAccess() and
    a.getRValue() = init
  |
    not init instanceof NullValue
  )
}

/*
 * Main analysis
 */

/**
 * A constructor which does not initialize the given pointer field.
 */
Constructor unsafeConstructor(Field uninitialized) {
  // If no definition for the constructor, we can either assume dangerous or safe
  // to avoid false positives, we err on the side of assuming safe at least for
  // SDL-required queries
  result.hasDefinition() and
  // defined in the same type
  result.getDeclaringType() = uninitialized.getDeclaringType() and
  // all initializations in transitively called functions are null
  not uninitialized = assignedNonNull(result) and
  // all constructor initializations are null
  forall(ConstructorFieldInit i | result.getAnInitializer() = i and i.getTarget() = uninitialized |
    i.getExpr() instanceof NullValue
  ) and
  uninitialized.getUnderlyingType() instanceof PointerType
}

predicate fieldDeref(Field f, Expr qualifier, Expr deref) {
  exists(Expr ptrExpr |
    // the expression corresponding to the pointer is...
    (
      // either a call to a method that may return the field
      exists(FunctionCall c | c = ptrExpr |
        mayReturn(c.getTarget()).(FieldAccess).getTarget() = f and
        qualifier = c.getQualifier()
      )
      or
      // or a direct access to the field
      exists(FieldAccess fa | fa = ptrExpr |
        fa.getTarget() = f and
        qualifier = fa.getQualifier()
      )
    ) and
    // the pointer expression is dereferenced by deref
    dereferencedByOperation(deref, ptrExpr)
  )
}

Expr breakExpr(Expr e) {
  if e instanceof BinaryLogicalOperation
  then result = breakExpr(e.(BinaryLogicalOperation).getAnOperand())
  else
    if e instanceof UnaryLogicalOperation
    then result = breakExpr(e.(UnaryLogicalOperation).getAnOperand())
    else result = e
}

/**
 * Evaluates for any expression `e`, if `cond` is a condition that encloses `e`.
 */
bindingset[e]
Expr getEnclosingCondition(Expr e) {
  exists(IfStmt i | i.getCondition() = result |
    i.getChildStmt().getAChild*() = e.getEnclosingStmt()
  )
  or
  exists(Loop l | l.getCondition() = result | l.getChildStmt().getAChild*() = e.getEnclosingStmt())
}

predicate isInitializer(ControlFlowNode node, StackVariable v) {
  exists(Call c | c = node |
    // methods can modify fields
    c.getQualifier() = v.getAnAccess()
    or
    // if we pass in a reference then assume that anything can happen
    c.getAnArgument() = addressOf(v.getAnAccess())
    or
    // Including if pass a reference implicitly (call by reference)
    exists(Expr arg | arg = c.getAnArgument() and arg = v.getAnAccess() |
      arg.getFullyConverted() instanceof ReferenceToExpr
    )
    or
    // similarly for references to an actual field
    c.getAnArgument() = addressOf(any(FieldAccess f | f.getQualifier() = v.getAnAccess()))
  )
  or
  // FALSE NEGATIVE CAVEAT: any field access assignment is a barrier under this logic, leading to false negatives
  node.(Assignment).getLValue().(FieldAccess).getQualifier() = v.getAnAccess()
}

/**
 * Holds if for a given `node` representing a variable access of `v`,
 * if there is a predecessory ControlFlowNode that initializes fields
 * of `v` under the same/similar guarding conditions as `node`.
 */
bindingset[node, v]
predicate hasCheckedInitialize(ControlFlowNode node, StackVariable v) {
  node = v.getAnAccess() and
  exists(ControlFlowNode pred |
    //TODO: found I could not enforce a successor relationship of pred
    //      cases exist in real-world code that were still false positives
    // As such, query is extra conservative for now
    // pred.getASuccessor+() = node |
    isInitializer(pred, v) and
    exists(Expr cond1, Expr cond2 |
      cond1 = getEnclosingCondition(node) and
      cond2 = getEnclosingCondition(pred) and
      hashCons(breakExpr(cond1)) = hashCons(breakExpr(cond2)) and
      // Explicitly looking for the conditions to not be the same
      // exact expression in this case
      cond1 != cond2
    )
  )
}

class UninitializedFieldReachability extends StackVariableReachability {
  UninitializedFieldReachability() { this = "UninitializedFieldReachability" }

  override predicate isSource(ControlFlowNode node, StackVariable v) {
    definition(v, node) and
    node = unsafeConstructor(_).getACallToThisFunction() and
    node = any(Class t | | t.getAConstructor().getACallToThisFunction())
  }

  override predicate isSink(ControlFlowNode node, StackVariable v) {
    node = v.getAnAccess() and
    // There must not exist an initialing expression anywhere prior to the sink
    // where the initialilzation is performed in a guarding condition
    // that appears to be related to the guarding condition of the sink
    // e.g., if(A) initialize ... if(A) use
    not hasCheckedInitialize(node, v)
  }

  override predicate isBarrier(ControlFlowNode node, StackVariable v) { isInitializer(node, v) }
}

from Variable v, Field f, Expr def, Expr use, Expr deref
where
  any(UninitializedFieldReachability r).reaches(def, v, use) and
  def = unsafeConstructor(f).getACallToThisFunction() and
  fieldDeref(f, use, deref)
select deref, "Dereference of $@ which may not have been initialized since $@.", f, "field", def,
  "construction"
