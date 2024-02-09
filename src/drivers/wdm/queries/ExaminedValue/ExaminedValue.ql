// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Return value not examined (C28193)
 * @id cpp/drivers/examined-value
 * @kind problem
 * @description The returned value is annotated with the _Check_return_ or _Must_inspect_result_ annotation, but the calling function is either not using the value or is overwriting the value without examining it.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Attack Surface Reduction
 * @repro.text The following code location calls a function annotated with _Check_return_ or _Must_inspect_result_ but does not check the returned value.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28193
 * @problem.severity warning
 * @precision high
 * @tags correctness
 *       wddst
 * @scope general
 * @query-version v1
 */

import cpp
import drivers.libraries.SAL

/** A function that is annotated with either _Check_return_ or _Must_inspect_result_. */
class ReturnMustBeCheckedFunction extends Function {
  SALCheckReturn scr;

  ReturnMustBeCheckedFunction() { this.getADeclarationEntry() = scr.getDeclarationEntry() }
}

/** A function call to a function annotated with either _Check_return_ or _Must_inspect_result_. */
class ReturnMustBeCheckedFunctionCall extends FunctionCall {
  ReturnMustBeCheckedFunctionCall() { this.getTarget() instanceof ReturnMustBeCheckedFunction }
}

/** Holds if an expression (a call to ReturnMustBeCheckedFunction in this case) is occuring in a void context. */
predicate unUsed(Expr e) {
  e instanceof ExprInVoidContext
  or
  definition(_, e.getParent()) and
  not definitionUsePair(_, e.getParent(), _)
}

/**
 * Returns true if a ReturnMustBeCheckedFunction has its return value checked more than 75% of the time.
 */
predicate callFrequency(ReturnMustBeCheckedFunction f, string message) {
  exists(Options opts, int used, int total, int percentage |
    (
      used =
        count(ReturnMustBeCheckedFunctionCall fc |
          fc.getTarget() = f and not opts.okToIgnoreReturnValue(fc) and not unUsed(fc)
        ) and
      total =
        count(ReturnMustBeCheckedFunctionCall fc |
          fc.getTarget() = f and not opts.okToIgnoreReturnValue(fc)
        )
    ) and
    (
      used != total and
      percentage = used * 100 / total and
      percentage >= 75 and
      message =
        percentage.toString() +
          "% of calls to this function have their result checked. Checked return values = " +
          used.toString() + " total calls = " + total.toString()
    )
  )
}

from ReturnMustBeCheckedFunctionCall unused, string message
where
  unUsed(unused) and
  not exists(Options opts | opts.okToIgnoreReturnValue(unused)) and
  callFrequency(unused.getTarget(), message) and
  not unused.getTarget().getName().matches("operator%") // exclude user defined operators
select unused, "Result of call to " + unused.getTarget().getName() + " is ignored; " + message
