// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name ExaminedValue
 * @kind problem
 * @description The returned value is annotated with the _Check_return_ or _Must_inspect_result_ annotation, but the calling function is either not using the value or is overwriting the value without examining it. For more information please refer C28193 Code Analysis rule.
 * @problem.severity warning
 * @id cpp/portedqueries/examined-value
 * @platform Desktop
 * @feature.area Multiple
 * @repro.text The following code locations potentially contain function calls whose return values are not checked.
 * @version 1.0
 */

import cpp
import drivers.libraries.SAL

//Represents functions that are annotated with either _Check_return_ or _Must_inspect_result_
class ReturnMustBeCheckedFunction extends Function {
  SALCheckReturn scr;

  ReturnMustBeCheckedFunction() { this.getADeclarationEntry() = scr.getDeclarationEntry() }
}

class ReturnMustBeCheckedFunctionCall extends FunctionCall {
  ReturnMustBeCheckedFunctionCall() { this.getTarget() instanceof ReturnMustBeCheckedFunction }
}

//Holds if an expression (a call to ReturnMustBeCheckedFunction in this case) is occuring in a void context.
predicate unUsed(Expr e) {
  e instanceof ExprInVoidContext
  or
  definition(_, e.getParent()) and
  not definitionUsePair(_, e.getParent(), _)
}

/**
 * In the general case this predicate is used to calculate the number of checked & total calls to a ReturnMustBeCheckedFunction. In the other case (if the two lines below are uncommented), it evaluates to true for ReturnMustBeCheckedFunctionCall's whose return values have been used in at aleast "X" % of the total number of calls.
 */
predicate callFrequency(ReturnMustBeCheckedFunction f, string message) {
  exists(Options opts, int used, int total, int percentage |
    used =
      count(ReturnMustBeCheckedFunctionCall fc |
        fc.getTarget() = f and not opts.okToIgnoreReturnValue(fc) and not unUsed(fc)
      ) and
    total =
      count(ReturnMustBeCheckedFunctionCall fc |
        fc.getTarget() = f and not opts.okToIgnoreReturnValue(fc)
      ) and
    used != total and
    percentage = used * 100 / total and
    percentage >= 75 and
    message =
      percentage.toString() +
        "% of calls to this function have their result checked. Checked return values = " +
        used.toString() + " total calls = " + total.toString()
  )
}

from ReturnMustBeCheckedFunctionCall unused, string message
where
  unUsed(unused) and
  not exists(Options opts | opts.okToIgnoreReturnValue(unused)) and
  callFrequency(unused.getTarget(), message) and
  not unused.getTarget().getName().matches("operator%") // exclude user defined operators
select unused, "Result of call to " + unused.getTarget().getName() + " is ignored; " + message
