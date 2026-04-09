// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/kmdf/double-completion
 * @kind problem
 * @name DoubleCompletion
 * @description A WDF driver must not complete the same I/O request twice. Calling
 *              WdfRequestComplete, WdfRequestCompleteWithInformation, or
 *              WdfRequestCompleteWithPriorityBoost a second time on a request that
 *              has already been completed causes a double-free that can corrupt the
 *              framework's internal state and crash the system.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Exploitable Design Issue
 * @repro.text The driver calls a request-completion API twice on the same WDFREQUEST handle.
 * @owner.email sdat@microsoft.com
 * @opaqueid SDV-DoubleCompletion
 * @problem.severity error
 * @precision high
 * @tags correctness
 *       wdf
 *       sdv-ported
 * @scope domainspecific
 * @query-version v2
 */

import cpp
import drivers.kmdf.libraries.KmdfDrivers
import drivers.kmdf.libraries.WdfCallbackFlowModel
import semmle.code.cpp.dataflow.new.DataFlow
import semmle.code.cpp.controlflow.Guards
import semmle.code.cpp.controlflow.Dominance

/**
 * A WDF request completion function.
 */
class WdfRequestCompleteFunction extends Function {
  WdfRequestCompleteFunction() {
    this.getName() =
      [
        "WdfRequestComplete", "WdfRequestCompleteWithInformation",
        "WdfRequestCompleteWithPriorityBoost"
      ]
  }
}

/**
 * A call to a WDF request completion function.
 */
class WdfRequestCompleteCall extends FunctionCall {
  WdfRequestCompleteCall() { this.getTarget() instanceof WdfRequestCompleteFunction }

  /** Gets the request handle argument (always the first parameter). */
  Expr getRequestArg() { result = this.getArgument(0) }
}

/**
 * A WDF API that outputs a new WDFREQUEST handle, overwriting any previous
 * value in the output parameter. These functions have `_Out_ WDFREQUEST*`
 * parameters.
 *
 * Because WDF APIs dispatch through a function-pointer table, CodeQL cannot
 * see the actual write to `*OutRequest`. We model this explicitly in
 * `isBarrier` so the old request value does not flow through these calls.
 */
class WdfRequestOutputFunction extends Function {
  WdfRequestOutputFunction() {
    this.getName() =
      [
        "WdfIoQueueRetrieveNextRequest", "WdfIoQueueRetrieveFoundRequest",
        "WdfIoQueueRetrieveRequestByFileObject", "WdfRequestCreate",
        "WdfRequestCreateFromIrp"
      ]
  }
}

/**
 * Dataflow configuration to track the same WDFREQUEST value flowing
 * from a first completion call site to a second completion call site.
 *
 * The path shows how the request handle travels from the point it was
 * first completed to the point it is (erroneously) completed again.
 *
 * `isBarrier` prevents the old WDFREQUEST value from flowing through
 * calls to WDF APIs that overwrite their `_Out_ WDFREQUEST*` parameter.
 * CodeQL cannot see the write through the WDF function-pointer dispatch
 * table, so without this barrier the old value appears to survive.
 */
module DoubleCompletionConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(WdfRequestCompleteCall call | source.asExpr() = call.getRequestArg())
  }

  predicate isSink(DataFlow::Node sink) {
    exists(WdfRequestCompleteCall call | sink.asExpr() = call.getRequestArg())
  }

  predicate isBarrier(DataFlow::Node node) {
    exists(FunctionCall fc |
      fc.getTarget() instanceof WdfRequestOutputFunction and
      node.asDefiningArgument() = fc.getAnArgument()
    )
  }

  predicate isAdditionalFlowStep(DataFlow::Node pred, DataFlow::Node succ) {
    // Model flow from a call argument to the callee's parameter.
    exists(FunctionCall call, Function callee, int i |
      callee = call.getTarget() and
      pred.asExpr() = call.getArgument(i) and
      succ.asParameter() = callee.getParameter(i)
    )
    or
    // Model implicit flow through WDF callback registration.
    // E.g., WdfRequestMarkCancelable(Request, Callback) means the
    // framework will call Callback(Request) — Request flows to param 0.
    wdfCallbackFlowStep(pred, succ)
  }
}

module DoubleCompletionFlow = DataFlow::Global<DoubleCompletionConfig>;

/**
 * Holds if `earlier` and `later` are two distinct completion calls in the
 * same function where `later` is a control-flow successor of `earlier`.
 */
predicate completionFollowsInSameFunction(
  WdfRequestCompleteCall earlier, WdfRequestCompleteCall later
) {
  earlier != later and
  earlier.getEnclosingFunction() = later.getEnclosingFunction() and
  earlier.getASuccessor+() = later
}

/**
 * Holds if `completeCall` is a completion call that is reachable from
 * `callerSite` — i.e. `callerSite` calls a function that (directly or
 * transitively) contains `completeCall`.
 */
predicate completionInCallee(FunctionCall callerSite, WdfRequestCompleteCall completeCall) {
  completeCall.getEnclosingFunction() = callerSite.getTarget()
  or
  exists(FunctionCall intermediate |
    intermediate.getEnclosingFunction() = callerSite.getTarget() and
    completionInCallee(intermediate, completeCall)
  )
}

/**
 * Holds if a function call overwrites the request variable between
 * `firstComplete` and `secondComplete`, meaning the second completion
 * operates on a new request, not the same one.
 *
 * Detects ANY function that takes `&requestVar` as an argument between
 * the two completions. This covers:
 * - WDF APIs like WdfIoQueueRetrieveNextRequest(Queue, &Request)
 * - Driver-internal helpers like NICGetIoctlRequest(..., &request)
 * - Any function with an _Out_ pointer parameter
 *
 * Covers two cases:
 * 1. Same function: output call between the two completions in CFG order.
 * 2. Cross function: `firstComplete` is in a caller, the output call
 *    also in the caller comes after `firstComplete`, and `secondComplete`
 *    is in a callee called after the output call.
 */
predicate requestOverwrittenBetweenCompletions(
  WdfRequestCompleteCall firstComplete, WdfRequestCompleteCall secondComplete
) {
  // Case 1: All in the same function
  exists(
    FunctionCall outputCall, AddressOfExpr addrOf, Variable v |
    addrOf = outputCall.getAnArgument() and
    addrOf.getOperand().(VariableAccess).getTarget() = v and
    secondComplete.getRequestArg().(VariableAccess).getTarget() = v and
    firstComplete.getEnclosingFunction() = outputCall.getEnclosingFunction() and
    outputCall.getASuccessor+() = secondComplete
  )
  or
  // Case 2: Cross function
  exists(
    FunctionCall outputCall, AddressOfExpr addrOf, Variable v,
    FunctionCall callerSite |
    addrOf = outputCall.getAnArgument() and
    addrOf.getOperand().(VariableAccess).getTarget() = v and
    outputCall.getEnclosingFunction() = callerSite.getEnclosingFunction() and
    outputCall.getASuccessor+() = callerSite and
    completionInCallee(callerSite, secondComplete)
  )
}

/**
 * Holds if the second completion is guarded by a condition that is
 * guaranteed to be false on any path where the first completion executed.
 *
 * Handles three patterns:
 *
 * Pattern A (boolean flag):
 *   firstComplete(Request);
 *   guardVar = TRUE;
 *   if (!guardVar) { secondComplete(Request); }  // unreachable
 *
 * Pattern B (status code guard):
 *   guardVar = STATUS_SUCCESS;     // or any value != guardConst
 *   firstComplete(Request);
 *   if (guardVar == guardConst) { secondComplete(Request); }  // unreachable
 *
 * We verify that the guard condition's required value for the second
 * completion is contradicted by an assignment on every path through
 * the first completion.
 */
predicate completionGuardedByFlag(
  WdfRequestCompleteCall firstComplete, WdfRequestCompleteCall secondComplete
) {
  firstComplete.getEnclosingFunction() = secondComplete.getEnclosingFunction() and
  exists(
    GuardCondition guard, Variable guardVar, BasicBlock secondBlock
  |
    secondBlock = secondComplete.getBasicBlock() and
    (
      // --- Boolean patterns (guardVar must be zero for second to execute) ---
      (
        (
          // Pattern: if (!guardVar) { secondComplete; }
          exists(NotExpr notExpr |
            guard = notExpr and
            notExpr.getOperand().(VariableAccess).getTarget() = guardVar and
            guard.controls(secondBlock, true)
          )
          or
          // Pattern: if (guardVar) { ... } else { secondComplete; }
          guard.(VariableAccess).getTarget() = guardVar and
          guard.controls(secondBlock, false)
          or
          // Pattern: if (guardVar == 0) { secondComplete; }
          exists(EqualityOperation eq |
            guard = eq and
            eq.getAnOperand().(VariableAccess).getTarget() = guardVar and
            eq.getAnOperand().getValue() = "0" and
            guard.controls(secondBlock, true)
          )
        ) and
        // Verify: after the first completion, guardVar is assigned a non-zero constant
        exists(AssignExpr flagSet |
          flagSet.getLValue().(VariableAccess).getTarget() = guardVar and
          not flagSet.getRValue().getValue() = "0" and
          firstComplete.getASuccessor+() = flagSet and
          flagSet.getEnclosingFunction() = firstComplete.getEnclosingFunction()
        )
      )
      or
      // --- Equality pattern (guardVar must equal a specific constant for second to execute) ---
      // Pattern: if (guardVar == CONST_A) { secondComplete; }
      // And before firstComplete, guardVar is assigned CONST_B where CONST_B != CONST_A
      exists(EqualityOperation eq, string guardConst |
        guard = eq and
        guard.controls(secondBlock, true) and
        eq instanceof EQExpr and
        eq.getAnOperand().(VariableAccess).getTarget() = guardVar and
        guardConst = eq.getAnOperand().getValue() and
        // Verify: before the first completion, guardVar is assigned a value
        // that differs from the guard constant, so the guard will be false
        exists(AssignExpr statusSet |
          statusSet.getLValue().(VariableAccess).getTarget() = guardVar and
          statusSet.getRValue().getValue() != guardConst and
          // The assignment dominates the first completion (happens before it)
          statusSet.getASuccessor+() = firstComplete and
          statusSet.getEnclosingFunction() = firstComplete.getEnclosingFunction()
        )
      )
    )
  )
}

/**
 * Holds if a cross-function double completion can be confirmed structurally:
 * the first completion's function calls a callee passing the same request
 * variable, and the callee (or its transitive callees) contains the second
 * completion.
 */
predicate crossFunctionSameRequest(
  WdfRequestCompleteCall firstComplete, WdfRequestCompleteCall secondComplete
) {
  exists(FunctionCall callerSite, int argIdx |
    // The caller site is in the same function as the first completion
    firstComplete.getEnclosingFunction() = callerSite.getEnclosingFunction() and
    // The first completion dominates the caller site
    (
      bbDominates(firstComplete.getBasicBlock(), callerSite.getBasicBlock())
      or
      firstComplete.getBasicBlock() = callerSite.getBasicBlock()
    ) and
    firstComplete.getASuccessor+() = callerSite and
    // The same request variable is passed as an argument
    firstComplete.getRequestArg().(VariableAccess).getTarget() =
      callerSite.getArgument(argIdx).(VariableAccess).getTarget() and
    // The second completion is in the callee (directly or transitively)
    completionInCallee(callerSite, secondComplete)
  )
}

from WdfRequestCompleteCall firstComplete, WdfRequestCompleteCall secondComplete
where
  firstComplete != secondComplete and
  (
    // Case 1: Same function — use dataflow to confirm same request value
    (
      completionFollowsInSameFunction(firstComplete, secondComplete) and
      DoubleCompletionFlow::flow(
        DataFlow::exprNode(firstComplete.getRequestArg()),
        DataFlow::exprNode(secondComplete.getRequestArg())
      )
    )
    or
    // Case 2: Cross function — use structural analysis (same variable passed)
    crossFunctionSameRequest(firstComplete, secondComplete)
    or
    // Case 3: Cancel callback double completion.
    // A request is completed on the normal path, AND a cancel callback
    // registered for the same request also completes it.
    // Pattern: WdfRequestMarkCancelable(Request, Callback) ... Complete(Request)
    //          where Callback also calls Complete(Request).
    // EXCLUDED if WdfRequestUnmarkCancelable(Request) is called between
    // the mark and the completion — this deregisters the cancel callback.
    (
      // Direct registration: WdfRequestMarkCancelable is in the same function
      exists(WdfRequestMarkCancelableCall markCall |
        markCall.getEnclosingFunction() = firstComplete.getEnclosingFunction() and
        markCall.getRequestArg().(VariableAccess).getTarget() =
          firstComplete.getRequestArg().(VariableAccess).getTarget() and
        markCall.getASuccessor+() = firstComplete and
        completionInCancelCallback(markCall, secondComplete) and
        // Exclude: WdfRequestUnmarkCancelable called between mark and complete
        not exists(FunctionCall unmarkCall |
          unmarkCall.getTarget().getName() =
            ["WdfRequestUnmarkCancelable", "WdfRequestUnmarkCancelableEx"] and
          unmarkCall.getArgument(0).(VariableAccess).getTarget() =
            markCall.getRequestArg().(VariableAccess).getTarget() and
          markCall.getASuccessor+() = unmarkCall and
          unmarkCall.getASuccessor+() = firstComplete
        )
      )
      or
      // Transitive registration: WdfRequestMarkCancelable is inside a helper
      exists(FunctionCall callerSite |
        callerSite.getEnclosingFunction() = firstComplete.getEnclosingFunction() and
        callerSite.getASuccessor+() = firstComplete and
        callerSite.getAnArgument().(VariableAccess).getTarget() =
          firstComplete.getRequestArg().(VariableAccess).getTarget() and
        completionInCancelCallbackTransitive(callerSite, secondComplete) and
        // Exclude: unmark between the caller site and the completion
        not exists(FunctionCall unmarkCall |
          unmarkCall.getTarget().getName() =
            ["WdfRequestUnmarkCancelable", "WdfRequestUnmarkCancelableEx"] and
          unmarkCall.getArgument(0).(VariableAccess).getTarget() =
            firstComplete.getRequestArg().(VariableAccess).getTarget() and
          callerSite.getASuccessor+() = unmarkCall and
          unmarkCall.getASuccessor+() = firstComplete
        )
      )
    )
  ) and
  not requestOverwrittenBetweenCompletions(firstComplete, secondComplete) and
  not completionGuardedByFlag(firstComplete, secondComplete)
select secondComplete,
  "This call to " + secondComplete.getTarget().getName() +
    " completes a WDFREQUEST that was $@ by a previous call to " +
    firstComplete.getTarget().getName() +
    ". Double-completing a request corrupts framework state and can crash the system.",
  firstComplete, "already completed"
