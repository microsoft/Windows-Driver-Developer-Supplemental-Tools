// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

/**
 * @id cpp/infiniteloop
 * @name Comparison of narrow type with wide type in loop condition
 * @description Comparisons between types of different widths in a loop
 *              condition can cause the loop to fail to terminate.
 * @kind problem
 * @problem.severity error
 * @tags reliability
 *       security
 *       external/cwe/cwe-190
 *       external/cwe/cwe-197
 * @opaqueid SM02323
 * @microsoft.severity Important
 */

import cpp
import microsoft.commons.Literals

class ReferenceFix extends ReferenceType {
	override int getSize() { result = this.getBaseType().getSize() }
}

/**
 * Get the known maximum size for the expression, if any.
 */
float getKnownMaxSize(Expr e) {
	// e is a constant value
	result = e.getValue().toInt().log2() or
	// e is an access of a variable which is only assigned literal values
	result = max(e.(LiteralAccess).getALiteralInt()).log2() or
	// e is a call to specific methods, which have been observed to have a max size
	e.(FunctionCall).getTarget().getName().matches("Vms%GetNumberOfIndirectionTableEntries") and result = 8
}

from Loop l, RelationalOperation rel, Expr small, Expr large
where small = rel.getLesserOperand()
  and large = rel.getGreaterOperand()
  and rel = l.getCondition().getAChild*()
  // The size of the type of small is less than the size of the type of large
  and small.getExplicitlyConverted().getType().getSize() < large.getExplicitlyConverted().getType().getSize()
  // The small isn't a literal value
  and not exists(small.getValue())
  // Ignore cases where integer promotion has occurred on / or - expressions.
  and not large.(DivExpr).getLeftOperand().getType().getSize() = small.getType().getSize()
  and not large.(SubExpr).getLeftOperand().getType().getSize() = small.getType().getSize()
  // No obvious check against the large size
  and not exists(Variable bound | bound.getAnAccess() = large |
  	any(RelationalOperation r).getLesserOperand() = bound.getAnAccess()
  )
  // Filter results where the max value is known to be less than the max small size. 
  and not getKnownMaxSize(large) <= (small.getType().getSize() * 8)
select rel, "In " + rel.getEnclosingFunction() + " comparison between $@ of type " + small.getType().getName() + " and $@ of wider type " + large.getType().getName() + ".", small, small.toString(), large, large.toString()
