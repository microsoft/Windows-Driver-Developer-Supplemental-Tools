// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/init-not-cleared
 * @name Failure to clear DO_DEVICE_INITIALIZING (C28152)
 * @description The driver exited its AddDevice routine without clearing the DO_DEVICE_INITIALIZING flag of the new FDO.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text The driver exited its AddDevice routine without clearing the DO_DEVICE_INITIALIZING flag of the new FDO.
 * @owner.email sdat@microsoft.com
 * @kind problem
 * @opaqueid CQLD-C28152
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.wdm.libraries.WdmDrivers
import semmle.code.cpp.dataflow.new.DataFlow

/**
 * Represents a call to IoCreateDevice.
 */
class IoCreateFunction extends Function {
  IoCreateFunction() {
    this.getName().matches("IoCreateDevice") and
    this.getFile().getBaseName().matches("wdm.h")
  }
}

/**
 * Represents a data-flow path from the DriverObject parameter of
 * a WDM AddDevice function.
 */
module AddDeviceFlowConfig implements DataFlow::ConfigSig {

  predicate isSource(DataFlow::Node node) {
   exists(WdmAddDevice wad | node.asParameter() = wad.getParameter(0))
 }

  predicate isSink(DataFlow::Node node) { any() }
}

module AddDeviceFlow = DataFlow::Global<AddDeviceFlowConfig>;

/**
 * Represents a data-flow path from a FDO created via a call to
 * IoDeviceCreate to a use in an AssignAnd expression that clears
 * the DO_DEVICE_INITIALIZING flag.
 */
module FdoFlowConfig implements DataFlow::ConfigSig {

  predicate isSource(DataFlow::Node node) {
    exists(FunctionCall fc, DataFlow::Node pdo |
      fc.getTarget() instanceof IoCreateFunction and
      fc.getArgument(6) = node.asPartialDefinition() and
      pdo.asExpr().getAChild*() = fc.getArgument(0) and
      AddDeviceFlow::flow(_, pdo)
    )
  }

  predicate isSink(DataFlow::Node node) {
    exists(AssignAndExpr aae |
      node.asExpr() = aae.getLValue().getAChild*() and
      aae.getLValue().getAChild*().(PointerFieldAccess).getTarget().getName().matches("Flags") and
      aae.getRValue().getAChild*().(ComplementExpr).getOperand().(Literal).getValue().matches("128") // Literal value of the flag
    )
  }
}

module FdoFlow = DataFlow::Global<FdoFlowConfig>;
/*
 * We look for any AddDevice routine that does not have a corresponding
 * call to IoCreateDevice where the resulting FDO later has its DO_DEVICE_INITIALIZING
 * flag cleared.
 */

from WdmAddDevice wad
where
  not exists(FunctionCall fc |
    fc.getTarget() instanceof IoCreateFunction and
    AddDeviceFlow::flow(DataFlow::parameterNode(wad.getParameter(0)), DataFlow::exprNode(fc.getArgument(0))) and
    FdoFlow::flow(DataFlow::definitionByReferenceNodeFromArgument(fc.getArgument(6)), _)
  )
select wad,
  "The AddDevice routine $@ does not clear the DO_DEVICE_INITIALIZING flag from the FDO it creates.",
  wad, wad.toString()
