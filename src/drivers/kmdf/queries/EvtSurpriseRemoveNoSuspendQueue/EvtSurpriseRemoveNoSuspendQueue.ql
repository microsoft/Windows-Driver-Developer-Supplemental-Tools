// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/kmdf/evt-surprise-remove-no-suspend-queue
 * @kind problem
 * @name EvtSurpriseRemoveNoSuspendQueue
 * @description WDF drivers should not drain, stop, or purge I/O queues from the
 *              EvtDeviceSurpriseRemoval callback. This callback is not synchronized with
 *              the power-down path, so manipulating queues here can cause race conditions.
 *              Use self-managed I/O callbacks instead.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text The driver calls a queue drain/stop/purge API from EvtDeviceSurpriseRemoval.
 * @owner.email sdat@microsoft.com
 * @opaqueid SDV-EvtSurpriseRemoveNoSuspendQueue
 * @problem.severity warning
 * @precision high
 * @tags correctness
 *       wdf
 *       sdv-ported
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.kmdf.libraries.KmdfDrivers

/**
 * A WDF I/O queue suspend function that must not be called from
 * the EvtDeviceSurpriseRemoval callback.
 *
 * These APIs drain, stop, or purge an I/O queue. Calling them from
 * EvtDeviceSurpriseRemoval is unsafe because that callback is not
 * synchronized with the power-down path.
 */
class QueueSuspendFunction extends Function {
  QueueSuspendFunction() {
    this.getName() =
      [
        "WdfIoQueueStop", "WdfIoQueueStopSynchronously",
        "WdfIoQueueDrain", "WdfIoQueueDrainSynchronously",
        "WdfIoQueuePurge", "WdfIoQueuePurgeSynchronously",
        "WdfIoQueueStopAndPurge", "WdfIoQueueStopAndPurgeSynchronously"
      ]
  }
}

/**
 * Holds if `caller` may (directly or transitively) reach `fc`.
 *
 * A function call `fc` is reachable from `caller` when:
 *   - `fc` appears directly inside `caller`, or
 *   - `caller` calls some intermediate function that itself can reach `fc`.
 */
predicate callReachableFrom(Function caller, FunctionCall fc) {
  fc.getEnclosingFunction() = caller
  or
  exists(FunctionCall intermediate |
    intermediate.getEnclosingFunction() = caller and
    callReachableFrom(intermediate.getTarget(), fc)
  )
}

from KmdfEVTWdfDeviceSurpriseRemoval surpriseRemovalCallback, FunctionCall suspendCall
where
  suspendCall.getTarget() instanceof QueueSuspendFunction and
  callReachableFrom(surpriseRemovalCallback, suspendCall)
select suspendCall,
  suspendCall.getTarget().getName() +
    " should not be called from the EvtDeviceSurpriseRemoval callback (directly or indirectly). " +
    "EvtDeviceSurpriseRemoval is not synchronized with the power-down path. " +
    "Use self-managed I/O callbacks (e.g., EvtDeviceSelfManagedIoCleanup) instead."
