// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/wdm/dangling-device-object-reference
 * @kind problem
 * @name DanglingDeviceObjectReference
 * @description A driver calls IoAttachDeviceToDeviceStack but does not save the
 *              returned device object pointer. The lower device object reference
 *              is lost, preventing proper IRP forwarding and device stack teardown.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @owner.email sdat@microsoft.com
 * @opaqueid SDV-DanglingDeviceObjectReference
 * @problem.severity warning
 * @precision high
 * @tags correctness
 *       wdm
 *       resource-leak
 *       sdv-ported
 * @scope domainspecific
 * @query-version v1
 */

import cpp

/**
 * A call to IoAttachDeviceToDeviceStack, which returns the lower
 * device object that must be saved for IRP forwarding.
 */
class IoAttachDeviceCall extends FunctionCall {
  IoAttachDeviceCall() {
    this.getTarget().getName() = "IoAttachDeviceToDeviceStack"
  }
}

from IoAttachDeviceCall attachCall
where
  // The return value is not assigned to anything
  not exists(AssignExpr ae | ae.getRValue() = attachCall) and
  not exists(Variable v | v.getInitializer().getExpr() = attachCall)
select attachCall,
  "The return value of IoAttachDeviceToDeviceStack is not saved. " +
    "The lower device object pointer is needed for IoCallDriver and IoDetachDevice."
