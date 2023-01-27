// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Failure to clear DO_DEVICE_INITIALIZING (C28152)
 * @description The driver exited its AddDevice routine without clearing the DO_DEVICE_INITIALIZING flag of the DeviceObject.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @repro.text The driver exited its AddDevice routine without clearing the DO_DEVICE_INITIALIZING flag of the DeviceObject.
 * @kind problem
 * @id cpp/windows/drivers/queries/init-not-cleared
 * @problem.severity warning
 * @precision high
 * @tags correctness
 * @query-version v1
 */

import cpp
import drivers.wdm.libraries.WdmDrivers
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.dataflow.DataFlow2

class IoCreateFunction extends Function {
  IoCreateFunction() {
    this.getName().matches("IoCreateDevice") and
    this.getFile().getBaseName().matches("wdm.h")
  }
}

/**
 * Represents a data-flow path from a FDO created via a call to
 * IoDeviceCreate to a use in an AssignAnd expression.
 *
 * I think we'll also need an auxilliary flow to handle
 * interprocedural cases where the AddDevice passes the device object
 * into another function that then creates the FDO.
 */
class FdoFlow extends DataFlow::Configuration {
  FdoFlow() { this = "FdoFlow" }

  override predicate isSource(DataFlow::Node node) {
    exists(FunctionCall fc, AddDeviceFlow adf, DataFlow::Node pdo |
      fc.getTarget() instanceof IoCreateFunction and
      fc.getArgument(6) = node.asPartialDefinition() and
      pdo.asExpr().getAChild*() = fc.getArgument(0) and
      adf.hasFlow(_, pdo)
    )
  }

  override predicate isSink(DataFlow::Node node) {
    exists(AssignAndExpr aae |
      node.asExpr() = aae.getLValue().getAChild*() and
      aae.getLValue().getAChild*().(PointerFieldAccess).getTarget().getName().matches("Flags") and
      aae.getRValue().getAChild*().(ComplementExpr).getOperand().(Literal).getValue().matches("128")
    )
  }
}

class AddDeviceFlow extends DataFlow2::Configuration {
  AddDeviceFlow() { this = "AddDeviceFlow" }

  override predicate isSource(DataFlow2::Node node) {
    exists(WdmAddDevice wad | node.asParameter() = wad.getParameter(0))
  }

  override predicate isSink(DataFlow2::Node node) { any() }
}

/*
 * warning C28152: The return from an AddDevice-like function unexpectedly DO_DEVICE_INITIALIZING
 *
 * The driver has returned from its AddDevice routine, or a similar utility routine, but the DO_DEVICE_INITIALIZING bit of the Flags word (DeviceObject->Flags) in the DeviceObject routine is not cleared.
 *
 * The AddDevice routine must contain code similar to the following to clear the DO_DEVICE_INITIALIZING flag.
 *
 * FunctionalDeviceObject->Flags &= ~DO_DEVICE_INITIALIZING;
 */

// So.  First find a call to IoCreateDevice within a AddDevice function.
// Then check flow from (one of the arguments) to some clearing function... usually an AssignAndExpr
// LValue is a PointerFieldAccess (flags) to a VariableAccess (device)
// RValue is a ComplementExpr to a Literal (128)
from
  DataFlow::Node deviceObjectTarget, DataFlow::Node targetDefinition, DataFlow::Node future,
  FdoFlow fdo
where
  deviceObjectTarget.asExpr().(VariableAccess) =
    targetDefinition.asDefiningArgument().(AddressOfExpr).getOperand().(VariableAccess) and
  fdo.hasFlow(targetDefinition, future)
select deviceObjectTarget, targetDefinition, future
/*
 * from WdmAddDevice wad
 * where
 *  not exists(
 *    DataFlow::Node deviceObject, DataFlow::Node deviceObjectTarget, DataFlow::Node targetDefinition,
 *    FdoFlow fdo, AddDeviceFlow adf
 *  |
 *    deviceObject.asParameter() = wad.getParameter(0) and
 *    adf.hasFlow(deviceObject, deviceObjectTarget) and
 *    deviceObjectTarget.asExpr().(VariableAccess) =
 *      targetDefinition.asDefiningArgument().(AddressOfExpr).getOperand().(VariableAccess) and
 *    fdo.hasFlow(targetDefinition, _)
 *  )
 * select wad,
 *  "The AddDevice routine $@ does not clear the DO_DEVICE_INITIALIZING flags in the FDO before returning."
 */

