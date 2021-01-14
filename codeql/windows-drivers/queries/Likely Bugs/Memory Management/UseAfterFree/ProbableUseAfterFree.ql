// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

/**
 * @name Potential use after free (low precision, for drivers)
 * @description An allocated memory block is used after it has been freed. Behavior in such cases is undefined and can cause memory corruption.
 * @kind problem
 * @id cpp/probable-use-after-free
 * @problem.severity warning
 * @tags reliability
 *       security
 *       external/cwe/cwe-416
 * @precision low
 */
 
import cpp
import UseAfterFreeLib

from UseAfterPotentiallyFreeReachability r, Variable v, Expr free, Expr e, Access va, Expr actualFree
where
  r.reaches(free, v, e) and
  isPotentiallyFreeExprEx(free, v, va, actualFree) and
  not correlatedExprs(free, e) and
  ( 
    va.getTarget() = v or // same variable
    exists( Variable v2, Access va2| 
    	v2 = va.getTarget() and va2 = v2.getAnAccess() |   
    	va2.getAChild*() = e and // same dereferrenced value
    	not exists( AssignExpr ae | ae = va2.getEnclosingElement*() |
    		ae.getRValue().getValue().toInt() = 0  // filter any assignment to NULL usage 
    	)
    )
  )
select e, "Memory pointed to by '" + v.getName().toString() + "' may have been previously freed $@",
  free, "here"
