// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/ndis/init-register-interrupt
 * @kind problem
 * @name InitRegisterInterrupt
 * @description If NdisMRegisterInterruptEx is called during miniport initialization,
 *              NdisMDeregisterInterruptEx must be called during MiniportHaltEx to properly
 *              clean up the interrupt resource. Failing to deregister the interrupt during
 *              halt causes resource leaks and can lead to system instability.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Exploitable Design Issue
 * @repro.text The driver registers an interrupt in MiniportInitializeEx but does not
 *             deregister it in MiniportHaltEx.
 * @owner.email sdat@microsoft.com
 * @opaqueid SDV-Init_RegisterInterrupt
 * @problem.severity warning
 * @precision high
 * @tags correctness
 *       ndis
 *       resource-leak
 *       sdv-ported
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.ndis.libraries.NdisDrivers

/**
 * A call to `NdisMRegisterInterruptEx`, which registers a miniport
 * interrupt with NDIS.
 */
class NdisRegisterInterruptCall extends FunctionCall {
  NdisRegisterInterruptCall() {
    this.getTarget().getName() = "NdisMRegisterInterruptEx"
  }
}

/**
 * A call to `NdisMDeregisterInterruptEx`, which deregisters a
 * previously registered miniport interrupt.
 */
class NdisDeregisterInterruptCall extends FunctionCall {
  NdisDeregisterInterruptCall() {
    this.getTarget().getName() = "NdisMDeregisterInterruptEx"
  }
}

/**
 * A function that serves as the MiniportInitializeEx callback.
 * Uses NdisMiniportInitializeFunction from the library which
 * detects by both role type and struct field assignment.
 */
class MiniportInitFunction extends NdisMiniportInitializeFunction { }

/**
 * A function that serves as the MiniportHaltEx callback.
 * Uses NdisMiniportHaltFunction from the library.
 */
class MiniportHaltFunction extends NdisMiniportHaltFunction { }

/**
 * Holds if `NdisMRegisterInterruptEx` is called within `func`
 * or within any function transitively called from `func`.
 */
predicate registersInterruptIn(Function func) {
  exists(NdisRegisterInterruptCall rc | rc.getEnclosingFunction() = func)
  or
  exists(FunctionCall fc |
    fc.getEnclosingFunction() = func and
    registersInterruptIn(fc.getTarget())
  )
}

/**
 * Holds if `NdisMDeregisterInterruptEx` is called within `func`
 * or within any function transitively called from `func`.
 */
predicate deregistersInterruptIn(Function func) {
  exists(NdisDeregisterInterruptCall dc | dc.getEnclosingFunction() = func)
  or
  exists(FunctionCall fc |
    fc.getEnclosingFunction() = func and
    deregistersInterruptIn(fc.getTarget())
  )
}

from NdisRegisterInterruptCall registerCall, MiniportInitFunction initFunc
where
  // The register call is in the init function (directly or transitively)
  (
    registerCall.getEnclosingFunction() = initFunc
    or
    exists(FunctionCall fc |
      fc.getEnclosingFunction() = initFunc and
      registersInterruptIn(fc.getTarget()) and
      registerCall.getEnclosingFunction() = fc.getTarget()
    )
  ) and
  // No MiniportHalt function deregisters the interrupt
  not exists(MiniportHaltFunction haltFunc | deregistersInterruptIn(haltFunc))
select registerCall,
  "NdisMRegisterInterruptEx is called during miniport initialization ($@), but " +
    "NdisMDeregisterInterruptEx is not called in any MiniportHaltEx callback. " +
    "The interrupt must be deregistered during halt to prevent resource leaks.",
  initFunc, initFunc.getName()
