// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

/**
 * @name Calling WDF object initialization API after WdfDeviceCreate
 * @description Calling a WDF init API on a WDFDEVICE_INIT structure after calling WdfDeviceCreate can cause system instability, as the framework takes ownership of the structure. 
 * Partially ported from the Static Driver Verifier (SDV) rule DeviceInitAPI; see https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/kmdf-deviceinitapi for details.
 * @kind path-problem
 * @problem.severity error
 * @precision medium
 * @id cpp/windows/wdk/kmdf/DeviceInitApi
 * @tags correctness
 */

import Windows.wdk.kmdf.KmdfDrivers
import semmle.code.cpp.dataflow.DataFlow
import DataFlow::PathGraph

/** A function that initializes or changes a WDFDEVICE_INIT struct, and which must not be called after WDFDeviceCreate. */
class WdfInitializationApi extends Function {
    WdfInitializationApi() {
        this.getName() = 
        ["WdfDeviceInitSetPnpPowerEventCallbacks",
        "WdfDeviceInitSetFileObjectConfig",
        "WdfDeviceInitSetExclusive",
        "WdfDeviceInitSetPowerPolicyEventCallbacks",
        "WdfDeviceInitSetPowerPolicyOwnership",
        "WdfDeviceInitRegisterPnpStateChangeCallback",
        "WdfDeviceInitRegisterPowerStateChangeCallback",
        "WdfDeviceInitRegisterPowerPolicyStateChangeCallback",
        "WdfDeviceInitSetIoType",
        "WdfDeviceInitSetPowerNotPageable",
        "WdfDeviceInitSetPowerPageable",
        "WdfDeviceInitSetPowerInrush",
        "WdfDeviceInitSetDeviceType",
        "WdfDeviceInitAssignName",
        "WdfDeviceInitAssignSDDLString",
        "WdfDeviceInitSetDeviceClass",
        "WdfDeviceInitSetCharacteristics",
        "WdfDeviceInitSetRequestAttributes",
        "WdfDeviceInitAssignWdmIrpPreprocessCallback",
        "WdfDeviceInitSetIoInCallerContextCallback",
        "WdfFdoInitSetFilter",
        "WdfFdoInitWdmGetPhysicalDevice",
        "WdfFdoInitOpenRegistryKey",
        "WdfFdoInitQueryProperty",
        "WdfFdoInitAllocAndQueryProperty",
        "WdfFdoInitSetEventCallbacks",
        "WdfFdoInitSetDefaultChildListConfig"]
    }
}

/** A call to a WDF initialization API. */
class WdfInitiailzationApiCall extends FunctionCall{
    WdfInitiailzationApiCall() {
        isWdfInitializationApiCall_aux(this)
    }
}
/** Recursive predicate to determine if a function call directly or 
 * indirectly calls a WDF initialization API.
 */
predicate isWdfInitializationApiCall_aux(FunctionCall fc)
{
    fc.getTarget() instanceof WdfInitializationApi
    or exists (FunctionCall fc2 | 
        fc2.getControlFlowScope() = fc.getTarget()
        and isWdfInitializationApiCall_aux(fc2))
}
/** A predicate to determine if a given expression is a direct or indirect
 * child of a given function call.
 */
predicate isChildExpr(Expr e, FunctionCall func) {
    func.getAChild*() = e or
    exists (FunctionCall fc2 | 
        fc2.getControlFlowScope() = func.getTarget()
        and isChildExpr(e, fc2))
}

/** A data-flow model to determine if a use of a WDFDEVICE_INIT struct is 
 * used in an initialization function after WdfDeviceCreate is called.
*/
class InitAPIDataFlow extends DataFlow::Configuration {
    InitAPIDataFlow() {
        this = "KMDFDeviceInitApiFlow"
    }

    override predicate isSource(DataFlow::Node source) {        
        exists (FunctionCall fc | 
            fc.getTarget().getName().matches("WdfDeviceCreate")
            and fc.getArgument(0).getAChild*() = source.asExpr())
    }

    override predicate isSink(DataFlow::Node sink) {
        exists (FunctionCall fc | 
            fc.getTarget() instanceof WdfInitializationApi 
            and fc.getArgument(0).getAChild*() = sink.asExpr())
    }

    override predicate isAdditionalFlowStep(DataFlow::Node source, DataFlow::Node sink) {
        exists (FunctionCall fc | 
            fc.getTarget().getName().matches("WdfDeviceCreate")
            and fc.getTarget() = sink.getFunction()
            and fc.getArgument(0).getAChild*() = source.asExpr())
    }

}

from InitAPIDataFlow iadf, DataFlow::PathNode e1, DataFlow::PathNode e2
where exists (FunctionCall driverCreateCall, WdfInitiailzationApiCall apiCall |
    driverCreateCall.getAChild*() = e1.getNode().asExpr()
    and isChildExpr(e2.getNode().asExpr(), apiCall)
    and driverCreateCall.getASuccessor*() = apiCall)
    and iadf.hasFlowPath(e1, e2)
select e1.getNode(), e1, e2, "A WDF device object initialization method was called after WdfDeviceCreate was called on the same WDFDEVICE_INIT struct.  This can lead to system instability."