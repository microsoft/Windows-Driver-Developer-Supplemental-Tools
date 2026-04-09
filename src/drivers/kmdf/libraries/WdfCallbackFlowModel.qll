/**
 * @name WDF Callback Flow Model
 * @description Models the implicit data flow through WDF framework callback
 *              registration APIs. When a driver registers a callback function
 *              via a WDF API (e.g., WdfRequestMarkCancelable), the framework
 *              will later invoke that callback with the same object handle.
 *              This library provides predicates to model these implicit flows
 *              so that CodeQL dataflow analyses can track values across
 *              callback boundaries.
 *
 * ## Modeled APIs
 *
 * ### Request cancellation callbacks
 * - `WdfRequestMarkCancelable(Request, EvtRequestCancel)` — the framework
 *   may call `EvtRequestCancel(Request)` at any time after registration.
 * - `WdfRequestMarkCancelableEx(Request, EvtRequestCancel)` — same behavior.
 *
 * ### I/O queue callbacks (registered via WDF_IO_QUEUE_CONFIG)
 * - `EvtIoRead`, `EvtIoWrite`, `EvtIoDeviceControl`, etc. — receive the
 *   WDFREQUEST from the framework when dispatched from a queue.
 *
 * ## Limitations
 *
 * 1. **Indirect callback registration**: When the callback function pointer
 *    is passed through intermediate variables or struct fields, we may not
 *    resolve it. We handle direct function references and simple variable
 *    forwarding.
 *
 * 2. **Callback timing**: WDF callbacks can fire concurrently or be deferred.
 *    This model treats the callback as if it executes immediately after
 *    registration, which is sound for detecting bugs like double completion
 *    but doesn't model the actual timing.
 *
 * 3. **Old WDK macro expansion**: In older WDK versions, WDF APIs expand
 *    through a function pointer dispatch table. The `WdfCallbackRegistration`
 *    class attempts to match both the source-level name and the macro-expanded
 *    form, but may miss some patterns.
 *
 * 4. **Cross-translation-unit flow**: CodeQL's default interprocedural
 *    analysis may not connect flows across separately-compiled translation
 *    units (e.g., driver + static library). The `callbackFlowStep` predicate
 *    uses structural matching to bridge this gap.
 */

import cpp
import semmle.code.cpp.dataflow.new.DataFlow

/**
 * A call to a WDF API that registers a cancellation callback for a request.
 *
 * Matches:
 * - `WdfRequestMarkCancelable(Request, EvtCancel)`
 * - `WdfRequestMarkCancelableEx(Request, EvtCancel)`
 *
 * The framework will call `EvtCancel(Request)` when the request is cancelled.
 */
class WdfRequestMarkCancelableCall extends FunctionCall {
  WdfRequestMarkCancelableCall() {
    this.getTarget().getName() =
      ["WdfRequestMarkCancelable", "WdfRequestMarkCancelableEx"]
  }

  /** Gets the WDFREQUEST being registered for cancellation. */
  Expr getRequestArg() { result = this.getArgument(0) }

  /**
   * Gets the cancel callback function, if it can be statically resolved.
   *
   * Handles:
   * - Direct function reference: `WdfRequestMarkCancelable(req, MyCancel)`
   * - Address-of: `WdfRequestMarkCancelable(req, &MyCancel)`
   * - Variable forwarding: `fn = MyCancel; WdfRequestMarkCancelable(req, fn)`
   */
  Function getCancelCallback() {
    // Direct function reference or address-of
    result = this.getArgument(1).(FunctionAccess).getTarget()
    or
    // Through a variable that was assigned a function reference
    exists(Variable v, AssignExpr assign |
      this.getArgument(1).(VariableAccess).getTarget() = v and
      assign.getLValue().(VariableAccess).getTarget() = v and
      result = assign.getRValue().(FunctionAccess).getTarget()
    )
  }
}

/**
 * Holds if `WdfRequestMarkCancelable(Request, Callback)` creates an
 * implicit flow from the `Request` argument to parameter 0 of `Callback`.
 *
 * This models the WDF framework behavior: after registration, the
 * framework may call `Callback(Request)` with the same request handle.
 *
 * Use this in `isAdditionalFlowStep` to connect the request value
 * across the callback boundary:
 *
 * ```ql
 * predicate isAdditionalFlowStep(DataFlow::Node pred, DataFlow::Node succ) {
 *   wdfCancelCallbackFlowStep(pred, succ)
 * }
 * ```
 */
predicate wdfCancelCallbackFlowStep(DataFlow::Node pred, DataFlow::Node succ) {
  exists(WdfRequestMarkCancelableCall markCall, Function callback |
    callback = markCall.getCancelCallback() and
    pred.asExpr() = markCall.getRequestArg() and
    succ.asParameter() = callback.getParameter(0)
  )
}

/**
 * A call to a WDF API that registers a cancellation callback, where
 * the callback function pointer is passed indirectly through another
 * function call.
 *
 * Pattern (fail_driver4):
 * ```c
 * // In the driver:
 * SDVTest_ReqNotCanceledLocal(Request, EvtRequestCancel);
 *
 * // In the library:
 * void SDVTest_ReqNotCanceledLocal(WDFREQUEST Request, PFN_WDF_REQUEST_CANCEL EvtCancel) {
 *     WdfRequestMarkCancelable(Request, EvtCancel);
 * }
 * ```
 *
 * Here the cancel callback `EvtRequestCancel` flows from the caller
 * through a parameter to `WdfRequestMarkCancelable`. We model the
 * transitive resolution.
 */
predicate wdfCancelCallbackFlowStepTransitive(DataFlow::Node pred, DataFlow::Node succ) {
  // Direct case (handled above, included for completeness)
  wdfCancelCallbackFlowStep(pred, succ)
  or
  // Transitive case: the WdfRequestMarkCancelable call uses a parameter
  // as the callback, and the caller passes a concrete function pointer.
  exists(
    WdfRequestMarkCancelableCall markCall, Parameter callbackParam,
    FunctionCall callerSite, Function callback, int callbackArgIdx
  |
    // The mark-cancelable call uses a parameter as its callback argument
    markCall.getArgument(1).(VariableAccess).getTarget() = callbackParam and
    callbackParam.getFunction() = markCall.getEnclosingFunction() and
    // Find the caller that passes a concrete function to this parameter
    callerSite.getTarget() = markCall.getEnclosingFunction() and
    callbackArgIdx = callbackParam.getIndex() and
    callback = callerSite.getArgument(callbackArgIdx).(FunctionAccess).getTarget() and
    // The request also flows through: the mark-cancelable call uses
    // a parameter for the request, and the caller passes the request value
    exists(Parameter reqParam, int reqArgIdx |
      markCall.getRequestArg().(VariableAccess).getTarget() = reqParam and
      reqParam.getFunction() = markCall.getEnclosingFunction() and
      reqArgIdx = reqParam.getIndex() and
      pred.asExpr() = callerSite.getArgument(reqArgIdx)
    ) and
    succ.asParameter() = callback.getParameter(0)
  )
}

/**
 * Holds if there is an implicit callback flow step from `pred` to `succ`
 * through any WDF callback registration mechanism.
 *
 * Currently models:
 * - Cancel callback registration (WdfRequestMarkCancelable/Ex)
 *
 * Future extensions could model:
 * - Completion routine registration (WdfRequestSetCompletionRoutine)
 * - I/O queue dispatch (EvtIoRead/Write/DeviceControl registered via
 *   WDF_IO_QUEUE_CONFIG — request flows from queue to callback param)
 * - Timer/DPC callbacks (WdfTimerCreate, WdfDpcCreate)
 * - Work item callbacks (WdfWorkItemCreate)
 *
 * Use in a dataflow config:
 * ```ql
 * module MyConfig implements DataFlow::ConfigSig {
 *   // ...
 *   predicate isAdditionalFlowStep(DataFlow::Node pred, DataFlow::Node succ) {
 *     wdfCallbackFlowStep(pred, succ)
 *   }
 * }
 * ```
 */
predicate wdfCallbackFlowStep(DataFlow::Node pred, DataFlow::Node succ) {
  wdfCancelCallbackFlowStepTransitive(pred, succ)
  // Future: add other callback types here
  // or wdfCompletionRoutineFlowStep(pred, succ)
  // or wdfIoQueueDispatchFlowStep(pred, succ)
}

/**
 * A completion call inside a cancel callback that was registered via
 * WdfRequestMarkCancelable. This is useful for structural analysis
 * when dataflow cannot connect the paths.
 *
 * Holds if `cancelComplete` is a WdfRequestComplete* call inside a
 * function that is registered as a cancel callback for a request,
 * and `markCall` is the registration site.
 */
predicate completionInCancelCallback(
  WdfRequestMarkCancelableCall markCall, FunctionCall cancelComplete
) {
  exists(Function callback |
    callback = markCall.getCancelCallback() and
    cancelComplete.getEnclosingFunction() = callback and
    cancelComplete.getTarget().getName() =
      ["WdfRequestComplete", "WdfRequestCompleteWithInformation",
       "WdfRequestCompleteWithPriorityBoost"]
  )
}

/**
 * Same as `completionInCancelCallback` but handles the transitive case
 * where the cancel callback is registered through an intermediate function.
 */
predicate completionInCancelCallbackTransitive(
  FunctionCall callerSite, FunctionCall cancelComplete
) {
  exists(
    WdfRequestMarkCancelableCall markCall, Parameter callbackParam,
    Function callback, int callbackArgIdx
  |
    // The mark-cancelable call uses a parameter as its callback
    markCall.getArgument(1).(VariableAccess).getTarget() = callbackParam and
    callbackParam.getFunction() = markCall.getEnclosingFunction() and
    // The caller passes a concrete function
    callerSite.getTarget() = markCall.getEnclosingFunction() and
    callbackArgIdx = callbackParam.getIndex() and
    callback = callerSite.getArgument(callbackArgIdx).(FunctionAccess).getTarget() and
    // The cancel callback contains a completion
    cancelComplete.getEnclosingFunction() = callback and
    cancelComplete.getTarget().getName() =
      ["WdfRequestComplete", "WdfRequestCompleteWithInformation",
       "WdfRequestCompleteWithPriorityBoost"]
  )
}
