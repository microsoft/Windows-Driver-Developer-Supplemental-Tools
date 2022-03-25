/**
 * @name Access of WDF init API after WdfDeviceCreate
 * @description Calling a WDF init API on a device init object after calling WdfDeviceCreate can cause system instability.
 * @kind path-problem
 * @problem.severity error
 * @precision medium
 * @id cpp/windows/wdk/kmdf/DeviceInitApi
 * @tags correctness
 */

import Windows.wdk.kmdf.KmdfDrivers
import semmle.code.cpp.controlflow.StackVariableReachability
import semmle.code.cpp.dataflow.DataFlow
import DataFlow::PathGraph

class PostInitApi extends Function {
    PostInitApi() {
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

class BannedAPICall extends FunctionCall{
    BannedAPICall() {
        isBannedAPICall(this)
    }
}

predicate isBannedAPICall(FunctionCall fc)
{
    fc.getTarget() instanceof PostInitApi
    or exists (FunctionCall fc2 | 
        fc2.getControlFlowScope() = fc.getTarget()
        and isBannedAPICall(fc2))
}

predicate isChildExpr(Expr e, FunctionCall func) {
    func.getAChild*() = e or
    exists (FunctionCall fc2 | 
        fc2.getControlFlowScope() = func.getTarget()
        and isChildExpr(e, fc2))
}

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
            fc.getTarget() instanceof PostInitApi 
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
where exists (FunctionCall driverCreateCall, BannedAPICall apiCall |
    driverCreateCall.getAChild*() = e1.getNode().asExpr()
    and isChildExpr(e2.getNode().asExpr(), apiCall)
    and driverCreateCall.getASuccessor*() = apiCall)
    and iadf.hasFlowPath(e1, e2)
select e1.getNode(), e1, e2, "Called a WDF API after DeviceCreate"