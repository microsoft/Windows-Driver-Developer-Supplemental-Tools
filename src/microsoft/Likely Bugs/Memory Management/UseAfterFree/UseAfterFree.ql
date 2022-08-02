// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

/**
 * @name Potential use after free (high precision, for drivers)
 * @description An allocated memory block is used after it has been freed. Behavior in such cases is undefined and can cause memory corruption.
 * @kind problem
 * @id cpp/use-after-free
 * @problem.severity warning
 * @tags reliability
 *       security
 *       external/cwe/cwe-416
 * @precision high
 */

import cpp
import UseAfterFreeLib

predicate isExpressionGuardedByTryFinallyAbnormalTerminationInC(Expr e) {
	exists( Compilation c, MicrosoftTryFinallyStmt mtf, FunctionCall fc, Function f |
    	c.getAFileCompiled().compiledAsC() and
		mtf.getFile() = c.getAFileCompiled() and
		e = mtf.getFinally().getAChild*() and
		f.getName() = "_abnormal_termination" and
		fc = f.getACallToThisFunction() and
		fc = mtf.getFinally().getAChild*() and 
		fc.(GuardCondition).controls(e.getEnclosingBlock(), _)
	)
}

predicate areExpressionsGuardedBySimilarConditionsThatMayCallReturnStatement( Expr e1, Expr e2 ) {
	exists( GuardCondition gc1, GuardCondition gc2, Expr exitExpr, boolean b |
		gc1 != gc2 and
		gc1.controls(e1.getBasicBlock(), _) and
		gc2.controls(exitExpr.getBasicBlock(), b) and
		gc2.controls(e2.getBasicBlock(), b.booleanNot()) and
		gc1.getEnclosingFunction() = gc2.getEnclosingFunction() and
		gc1.getASuccessor*() = gc2 and
		forall( Variable v | 
		  	v.getAnAccess() = gc1.getAChild() |
		  	v.getAnAccess() = gc2.getAChild() ) and
		exitExpr.getEnclosingElement() instanceof ReturnStmt
	)
}


from UseAfterFreeReachability r, Variable v, Expr free, Expr e, Access va
where
  r.reaches(free, v, e) and
  isFreeExpr(free, v, va) and
  not isExpressionGuardedByTryFinallyAbnormalTerminationInC(free) and
  not areExpressionsGuardedBySimilarConditionsThatMayCallReturnStatement( free, e) and
  not correlatedExprs(free, e) and
  va.getTarget() = v
select e, "Memory pointed to by '" + v.getName().toString() + "' may have been previously freed $@",
  free, "here"
