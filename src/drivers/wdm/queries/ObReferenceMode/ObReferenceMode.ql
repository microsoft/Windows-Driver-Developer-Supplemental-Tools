// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/ob-reference-mode
 * @name The AccessMode parameter to ObReferenceObject* should be IRP->RequestorMode (C28126)
 * @description In a dispatch routine call to ObReferenceObjectByHandle or ObReferenceObjectByPointer, the driver is passing UserMode or KernelMode for the AccessMode parameter, instead of using Irp->RequestorMode.  This warning can be ignored or suppressed for drivers that are not the top-level driver.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Exploitable Design
 * @repro.text The driver did not pass Irp->RequestorMode to a call to ObReferenceObjectByHandle or ObReferenceObjectByPointer.  This warning can be ignored or suppressed for drivers that are not the top-level driver.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28126
 * @kind problem
 * @problem.severity warning
 * @precision high
 * @tags correctness
 *       ca_ported
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.wdm.libraries.WdmDrivers

/** Represents a call to one of the ObReferenceObject functions. */
class ObReferenceCall extends FunctionCall {
  ObReferenceCall() {
    this.getTarget().getName().matches(["ObReferenceObjectByHandle", "ObReferenceObjectByPointer"])
  }
}

from ObReferenceCall oc
where
  oc.getControlFlowScope() instanceof WdmDispatchRoutine and
  not (
    oc.getArgument(3).(PointerFieldAccess).getTarget().getName().matches("RequestorMode") and
    oc.getArgument(3)
        .(PointerFieldAccess)
        .getQualifier()
        .(VariableAccess)
        .getTarget()
        .getName()
        .matches("Irp")
  )
select oc, "This call to ObReference* in a dispatch routine does not pass IRP->RequestorMode as the AccessMode argument.  If this is a top-level driver, it should pass this to respect the IRP context."