// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

import cpp
import semmle.code.cpp.controlflow.StackVariableReachability
import semmle.code.cpp.controlflow.ControlFlowGraph
import semmle.code.cpp.controlflow.Guards
import semmle.code.cpp.controlflow.SSA
import semmle.code.cpp.dataflow.DataFlow


/** `e` is an expression that frees the memory pointed to by `v`. 
 *  `va` is the corresponding access to the variable `v`. 
 **/
predicate isFreeExpr(Expr e, Variable v, Access va) {
  exists(| va.getTarget() = v or va.getAChild*().(Access).getTarget() = v |
    exists(FunctionCall fc | fc = e |
      (
        (
          fc.getTarget().hasGlobalOrStdName("ExFreePool") or
          fc.getTarget().hasGlobalOrStdName("ExFreePoolWithTag") or
          fc.getTarget().hasGlobalOrStdName("IoFreeMdl") or
          fc.getTarget().hasGlobalOrStdName("IoFreeIrp") or
          fc.getTarget().hasGlobalOrStdName("NdisFreeMemory") or
          fc.getTarget().hasGlobalOrStdName("NdisFreeMemoryWithTag") or
          fc.getTarget().hasGlobalOrStdName("NdisFreeMdl") or
          fc.getTarget().hasGlobalOrStdName("NdisFreeGenericObject") or
          fc.getTarget().hasGlobalOrStdName("NdisFreeNetBufferPool") or
          fc.getTarget().hasGlobalOrStdName("NdisFreeNetBufferListPool") or
          fc.getTarget().hasGlobalOrStdName("free")
        ) and
        va = fc.getArgument(0)
      ) or
      (
        (
          fc.getTarget().hasGlobalOrStdName("NdisFreeMemoryWithTagPriority") or
          fc.getTarget().hasGlobalOrStdName("StorPortFreePool") or // (forceinlined)
          fc.getTarget().hasGlobalOrStdName("StorPortFreeMdl")     // (forceinlined)
        ) and
        va = fc.getArgument(1)
      )
    )
    or
    e.(DeleteExpr).getExpr() = va
    or
    e.(DeleteArrayExpr).getExpr() = va
  )
}

/** True if the argument `n` of function `f` may be called in a free (`isFreeExpr`) call **/
predicate isPotentiallyFreeFunction( Function f, int n )
{
	exists( VariableAccess va, Variable v, ArgumentFLowsToFreeCallConfiguration config,  DataFlow::Node sink, DataFlow::Node source | 
		config.hasFlow(source, sink) and
		va = source.asExpr() and
		(va.getTarget() = v or va.getAChild*().(Access).getTarget() = v or va.(PointerFieldAccess).getQualifier() = v.getAnAccess()) and
		f = va.getEnclosingFunction() and
		f.getParameter(n) = v
	)
}

/** `e` is an expression that frees the memory pointed to by `v` or that may call a wrapper function. 
 *  `va` is the corresponding access to the variable `v`. 
 **/
predicate isPotentiallyFreeExpr(Expr e, Variable v, Access va) {
  isFreeExpr(e, v, va) or
  exists(| va.getTarget() = v or va.getAChild*().(Access).getTarget() = v |
    exists(FunctionCall fc, Function f, int n | fc = e |
      isPotentiallyFreeFunction( f, n) and 
      fc.getTarget() = f and
      va = fc.getArgument(n)
    )
  )
}

/** source of type `access` flows to the parameter of a `isFreeExpr` */
class ArgumentFLowsToFreeCallConfiguration extends DataFlow::Configuration {
  ArgumentFLowsToFreeCallConfiguration() {
    this = "ArgumentFLowsToFreeCallConfiguration"
  }
  
  override predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof Access
  }
 
  override predicate isSink(DataFlow::Node sink) {
  	exists( FunctionCall call, Access a |
	    ( sink.asExpr() = a or sink.asExpr().getAChild*() = a or sink.asExpr().(PointerFieldAccess).getQualifier() = a ) and  
	    isFreeExpr( call, _, a ) 
    )
	
  }
}

/**
 * Lower precision check if an Expr `e` is a free call using a variable `v` 
 **/
predicate isPotentiallyFreeExprEx(Expr e, Variable v, Access va, Expr actualFreeArg) {
	( isPotentiallyFreeExpr(e, v, va) and va = actualFreeArg ) or
	(
		exists( ArgumentFLowsToFreeCallConfiguration config, DataFlow::Node source, DataFlow::Node sink |
			source.asExpr() = va and sink.asExpr() = actualFreeArg |
			config.hasFlow(source, sink) and
			e.(FunctionCall).getAnArgument() = va and
			(va.getTarget() = v or va.getAChild*().(Access).getTarget() = v or va.(PointerFieldAccess).getQualifier() = v.getAnAccess())
		)
	)
}

/** `e` is an expression that (may) dereference `v`. */
predicate isDerefExpr(Expr e, Variable v) {
  v.getAnAccess() = e and dereferenced(e)
  or
  isDerefByCallExpr(_, _, e, v)
}

/**
 * `va` is passed by value as (part of) the `i`th argument in
 * call `c`. The target function is either a library function
 * or a source code function that dereferences the relevant
 * parameter.
 */
predicate isDerefByCallExpr(Call c, int i, Access va, Variable v) {
  v.getAnAccess() = va and
  va = c.getAnArgumentSubExpr(i) and
  not c.passesByReference(i, va) and
  (c.getTarget().hasEntryPoint() implies isDerefExpr(_, c.getTarget().getParameter(i)))
}

/**
 * StackVariable `v` is used after a `free` Expr 
 */
class UseAfterPotentiallyFreeReachability extends StackVariableReachability {
  UseAfterPotentiallyFreeReachability() { this = "UseAfterFree" }

  override predicate isSource(ControlFlowNode node, StackVariable v) { isPotentiallyFreeExprEx(node, v, _, _) }

  override predicate isSink(ControlFlowNode node, StackVariable v) { isDerefExpr(node, v) }

  override predicate isBarrier(ControlFlowNode node, StackVariable v) {
    definitionBarrier(v, node) or
    isPotentiallyFreeExprEx(node, v, _, _)
  }
}

class UseAfterFreeReachability extends StackVariableReachability {
  UseAfterFreeReachability() { this = "UseAfterFree" }

  override predicate isSource(ControlFlowNode node, StackVariable v) { isFreeExpr(node, v, _) }

  override predicate isSink(ControlFlowNode node, StackVariable v) { isDerefExpr(node, v) }

  override predicate isBarrier(ControlFlowNode node, StackVariable v) {
    definitionBarrier(v, node) or
    isFreeExpr(node, v, _)
  }
}

predicate correlatedExprs(Expr start, Expr end) {
  exists(
    GuardCondition startGuard, GuardCondition endGuard, SsaDefinition def, Variable v,
    Literal lStart, Literal lEnd, boolean b, int k
  |
    startGuard
        .ensuresEq(def.getAnUltimateSsaDefinition(v).getAUse(v), lStart, k, start.getBasicBlock(),
          b.booleanNot()) and
    endGuard.ensuresEq(def.getAUse(v), lEnd, k, end.getBasicBlock(), b)
  )
  or
  exists(
    GuardCondition startGuard, GuardCondition endGuard, SsaDefinition def, Variable v,
    Literal lStart, Literal lEnd, boolean b, int k
  |
    startGuard
        .ensuresLt(def.getAnUltimateSsaDefinition(v).getAUse(v), lStart, k, start.getBasicBlock(),
          b.booleanNot()) and
    endGuard.ensuresLt(def.getAUse(v), lEnd, k, end.getBasicBlock(), b)
  )
}
