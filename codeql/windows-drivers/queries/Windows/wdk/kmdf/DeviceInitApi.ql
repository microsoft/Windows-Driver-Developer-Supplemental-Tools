import KmdfDrivers
import semmle.code.cpp.controlflow.StackVariableReachability

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

from StackVariableReachability svr, BannedAPICall apiCall, FunctionCall driverCreateCall, Variable v
where  svr.reaches(driverCreateCall, v, apiCall)
select driverCreateCall, v, apiCall

/*
from BannedAPICall apiCall, FunctionCall driverCreateCall, StackVariableReachabilityWithReassignment svr
where driverCreateCall.getTarget().getName().matches("WdfDeviceCreate")
and driverCreateCall.getASuccessor*() = apiCall
and svr.reaches(driverCreateCall, driverCreateCall.getArgument(0).getAChild*().(Access).getTarget() , apiCall)
select apiCall*/