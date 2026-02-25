/**
 * @name Result of call that may return NULL dereferenced unconditionally
 * @description If a call is known to return NULL, the result should be checked
 *              before dereferencing.
 * @kind problem
 * @problem.severity error
 * @tags security
 *       external/cwe/cwe-476
 * @id cpp/unguardednullreturndereference
 */

import microsoft.code.cpp.commons.Literals
import microsoft.code.cpp.commons.MemoryAllocation
import microsoft.code.cpp.controlflow.Dereferences
import microsoft.code.cpp.controlflow.Reachability
import drivers.libraries.SAL
import semmle.code.cpp.controlflow.StackVariableReachability

/**
 * Holds if `call` may return `null`.
 */
predicate possiblyNull(Call call) {
  exists(Function f |
    f = call.getTarget() and
    // NdisGetDataBuffer only returns null if the size parameter is not statically assigned
    (
      call.getTarget().hasName("NdisGetDataBuffer")
      implies
      not call.getArgument(1) instanceof StaticValue
    )
  |
    mayReturnNull(f) or
    // SAL annotation indicates the result should be checked.
    any(SALAnnotation a | a.getMacroName() = "_Must_inspect_result_").getDeclaration() = f or
    any(SALAnnotation a | a.getMacroName() = "_Result_nullonfailure_").getDeclaration() = f
  )
  or
  // Heap allocations should be checked for null.
  call instanceof HeapAllocation
}

/**
 * Holds if `call` is assigned to variable `v` in control flow node
 * `cfn`, where `call` may return `null`.
 */
predicate possiblyNullAssignment(ControlFlowNode cfn, Call call, StackVariable v) {
  possiblyNull(call) and
  v.getType().getUnspecifiedType() instanceof PointerType and
  (
    cfn =
      any(AssignExpr ae |
        ae.getLValue() = v.getAnAccess() and
        ae.getRValue() = call
      )
    or
    exists(Initializer i |
      i = v.getInitializer() and
      i.getExpr() = call and
      cfn = call
    )
  ) and
  not exists(ConditionDeclExpr cde | cde.getVariable() = v)
}

class UnguardedNullReturnDereferenceReachability extends StackVariableReachability {
  UnguardedNullReturnDereferenceReachability() { this = "UnguardedNullReturnDereference" }

  override predicate isSource(ControlFlowNode node, StackVariable v) {
    possiblyNullAssignment(node, _, v)
  }

  override predicate isSink(ControlFlowNode node, StackVariable v) {
    node instanceof Dereference and
    node = v.getAnAccess() and
    not node.(Dereference)
        .getDereferencingOperation()
        .(FunctionCall)
        .getTarget()
        .hasGlobalName("free")
  }

  override predicate isBarrier(ControlFlowNode node, StackVariable v) {
    // Variable is redefined
    definitionBarrier(v, node)
    or
    // Only report the first dereference on any path
    isSink(node, v)
    or
    // Any indication that this variable is checked
    nullCheckExpr(node, v)
    or
    validCheckExpr(node, v)
    or
    exists(VariableAccess va |
      va = node and
      va = v.getAnAccess()
    |
      va =
        any(EqualityOperation o |
          o.getAnOperand() instanceof NullValue
        ).getAnOperand() or
      va = any(IfStmt i).getCondition() or
      va.getParent() instanceof LogicalAndExpr or
      va.getParent() instanceof NotExpr or
      va.getParent() = any(ConditionalExpr c).getCondition()
      // TODO: Handle asserts?
    )
    or
    // Eliminating FP - the variable is initialized within the `IfStmt`
    exists(IfStmt ifs, Initializer init |
      ifs = node.getEnclosingStmt() and
      v = init.getDeclaration() and
      ifs = init.getEnclosingStmt()
    )
    or
    // Elminating FP - the variable is assigned within the `IfStmt`
    exists(IfStmt ifs, AssignExpr ae |
      v.getAnAssignment() = ae and
      ifs.getAChild*() = node
    |
      ae.getEnclosingStmt() = ifs
    )
    or
    //      TODO: this is a workaround to address the inability to detect when a pointer check guards an exit condition.
    //            Currently using specific check function names, but this should be replaced with a more general mechanism.
    //            We are currently working on a generic query but it is on hold.
    exists(Call c |
      c.getTarget().getName() = ["_checked_malloc_impl", "_checked_realloc_impl", "_checked_calloc_impl",
        "_checked_pointer_impl", "_fail_on_unexpected_null_pointer", "_fail_on_memory_op"]
      and c.getAnArgument().getAChild*() = v.getAnAccess()
      and c = node)
  }
}

from
  UnguardedNullReturnDereferenceReachability r, StackVariable v, ControlFlowNode source, Call call,
  Expr use
where
  r.reaches(source, v, use) and
  possiblyNullAssignment(source, call, v)
select use,
  "In " + use.getEnclosingFunction() + " result of $@ to $@ is dereferenced here and may be null.",
  call, "call", call.getTarget(), call.getTarget().toString()
