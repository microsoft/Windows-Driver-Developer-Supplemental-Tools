/**
 * This QL library defines classes and predicates for analyzing NDIS drivers.
 * It provides definitions for NDIS dispatch routines, callback routines, and role types.
 * The library also includes a typedef for the standard NDIS callback routines.
 */

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
import cpp
import drivers.libraries.SAL

/**
 * NDIS dispatch routine class.
 * We hold a routine to be a dispatch routine if there is
 * an assignment in DriverEntry that assigns the function to
 * the dispatch table.
 */
cached
class NdisDispatchRoutine extends NdisRoleTypeFunction {
  /**
   * The OID type covered by this dispatch routine.
   */
  Literal dispatchType;
  /** The DriverEntry function this dispatch routine was assigned in. */
  NdisDriverEntry driverEntry;

  /**
   * Dispatch routines are defined by assignments of the form
   * MiniportDriverObject->DriverDispatch->MiniportXxxHandler = XxxHandler;
   * This characteristic predicate thus looks for assignments of this form
   * where the right-side value is a function with the NDIS_DISPATCH typedef.
   */
  cached
  NdisDispatchRoutine() {
    roleType.getName().matches("NDIS_DISPATCH") and
    exists(
      CallbackRoutineAssignment cra, PointerFieldAccess dispatchTable,
      PointerFieldAccess fieldAccess, VariableAccess driverObjectAccess
    |
      cra.getLValue() = fieldAccess and
      fieldAccess.getQualifier() = dispatchTable and
      dispatchTable.getQualifier() = driverObjectAccess and
      driverObjectAccess.getTarget().getType().getName().matches("PNDIS_MINIPORT_BLOCK") and
      cra.getTarget() = this and
      cra.getEnclosingFunction() = driverEntry
    )
  }

  /** Gets the OID type this dispatch routine handles, as a number. */
  cached
  Literal getDispatchType() { result = dispatchType }

  /** Gets the DriverEntry this dispatch routine was assigned in. */
  cached
  NdisDriverEntry getDriverEntry() { result = driverEntry }
}

/** An assignment where the right-hand side is a NDIS callback routine. */
class CallbackRoutineAssignment extends AssignExpr {
  /*
   * A common paradigm in dispatch routine setup is to chain assignments to cover multiple IRPs.
   * As such, it's necessary to recursively walk the assignment to handle cases such as
   *   DriverObject->MajorFunction[IRP_MJ_CREATE] =
   *   DriverObject->MajorFunction[IRP_MJ_OPEN] =
   *   MyMultiFunctionIrpHandler;
   * However, characterstic predicates cannot be recurisve, so the logic is placed in a separate
   * predicate below, isCallbackRoutineAssignment.
   */

  CallbackRoutineAssignment() { isCallbackRoutineAssignment(this) }

  /** Gets the callback routine that this dispatch routine assignment is targeting. */
  cached
  NdisCallbackRoutine getTarget() {
    if
      exists(FunctionAccess fa |
        this.getRValue() = fa and
        fa.getTarget() instanceof NdisCallbackRoutine
      )
    then result = this.getRValue().(FunctionAccess).getTarget()
    else result = getTarget_aux(this.getRValue())
  }

  /** Auxilliary function to getTarget(). */
  private NdisCallbackRoutine getTarget_aux(AssignExpr ae) {
    if
      exists(FunctionAccess fa |
        ae.getRValue() = fa and
        fa.getTarget() instanceof NdisCallbackRoutine
      )
    then result = ae.getRValue().(FunctionAccess).getTarget()
    else result = getTarget_aux(ae.getRValue())
  }
}

/** Determines if a given assignment, recursively, has a NDIS callback routine as the right-hand side. */
private predicate isCallbackRoutineAssignment(AssignExpr ae) {
  exists(FunctionAccess fa |
    ae.getRValue() = fa and
    fa.getTarget() instanceof NdisCallbackRoutine
  )
  or
  ae.getRValue() instanceof AssignExpr and
  isCallbackRoutineAssignment(ae.getRValue().(AssignExpr))
}

/** A typedef for Role Types */
class NdisRoleTypeType extends TypedefType {
  NdisRoleTypeType() {
    (
      this.getName().matches("MINIPORT_PROCESS_SG_LIST") or
      this.getName().matches("NDIS_TIMER_FUNCTION") or
      this.getName().matches("NDIS_IO_WORKITEM") or
      this.getName().matches("MINIPORT_ADD_DEVICE") or
      this.getName().matches("MINIPORT_CANCEL_DIRECT_OID_REQUEST") or
      this.getName().matches("MINIPORT_DIRECT_OID_REQUEST") or
      this.getName().matches("MINIPORT_FILTER_RESOURCE_REQUIREMENTS") or
      this.getName().matches("MINIPORT_START_DEVICE") or
      this.getName().matches("MINIPORT_SYNCHRONIZE_MESSAGE_INTERRUPT") or
      this.getName().matches("NDIS_IO_WORKITEM_FUNCTION") or
      this.getName().matches("FILTER_ATTACH") or
      this.getName().matches("FILTER_CANCEL_DIRECT_OID_REQUEST") or
      this.getName().matches("FILTER_CANCEL_SEND_NET_BUFFER_LISTS") or
      this.getName().matches("FILTER_CANCEL_OID_REQUEST") or
      this.getName().matches("FILTER_DETACH") or
      this.getName().matches("FILTER_DEVICE_PNP_EVENT_NOTIFY") or
      this.getName().matches("FILTER_DIRECT_OID_REQUEST") or
      this.getName().matches("FILTER_DIRECT_OID_REQUEST_COMPLETE") or
      this.getName().matches("DRIVER_UNLOAD") or
      this.getName().matches("FILTER_NET_PNP_EVENT") or
      this.getName().matches("FILTER_OID_REQUEST") or
      this.getName().matches("FILTER_OID_REQUEST_COMPLETE") or
      this.getName().matches("FILTER_PAUSE") or
      this.getName().matches("FILTER_RECEIVE_NET_BUFFER_LISTS") or
      this.getName().matches("MINIPORT_PROCESS_SG_LIST") or
      this.getName().matches("NDIS_TIMER_FUNCTION") or
      this.getName().matches("NDIS_IO_WORKITEM") or
      this.getName().matches("MINIPORT_ADD_DEVICE") or
      this.getName().matches("MINIPORT_CANCEL_DIRECT_OID_REQUEST") or
      this.getName().matches("MINIPORT_DIRECT_OID_REQUEST") or
      this.getName().matches("MINIPORT_FILTER_RESOURCE_REQUIREMENTS") or
      this.getName().matches("MINIPORT_START_DEVICE") or
      this.getName().matches("MINIPORT_SYNCHRONIZE_MESSAGE_INTERRUPT") or
      this.getName().matches("NDIS_IO_WORKITEM_FUNCTION") or
      this.getName().matches("FILTER_ATTACH") or
      this.getName().matches("FILTER_CANCEL_DIRECT_OID_REQUEST") or
      this.getName().matches("FILTER_CANCEL_SEND_NET_BUFFER_LISTS") or
      this.getName().matches("FILTER_CANCEL_OID_REQUEST") or
      this.getName().matches("FILTER_DETACH") or
      this.getName().matches("FILTER_DEVICE_PNP_EVENT_NOTIFY") or
      this.getName().matches("FILTER_DIRECT_OID_REQUEST") or
      this.getName().matches("FILTER_DIRECT_OID_REQUEST_COMPLETE") or
      this.getName().matches("DRIVER_UNLOAD") or
      this.getName().matches("FILTER_NET_PNP_EVENT") or
      this.getName().matches("FILTER_OID_REQUEST") or
      this.getName().matches("FILTER_OID_REQUEST_COMPLETE") or
      this.getName().matches("FILTER_PAUSE") or
      this.getName().matches("FILTER_RECEIVE_NET_BUFFER_LISTS") or
      this.getName().matches("FILTER_RESTART") or
      this.getName().matches("FILTER_RETURN_NET_BUFFER_LISTS") or
      this.getName().matches("FILTER_SEND_NET_BUFFER_LISTS") or
      this.getName().matches("FILTER_SEND_NET_BUFFER_LISTS_COMPLETE") or
      this.getName().matches("FILTER_SET_MODULE_OPTIONS") or
      this.getName().matches("FILTER_SET_OPTIONS") or
      this.getName().matches("FILTER_STATUS") or
      this.getName().matches("MINIPORT_CO_ACTIVATE_VC") or
      this.getName().matches("MINIPORT_CO_CREATE_VC") or
      this.getName().matches("MINIPORT_CO_DEACTIVATE_VC") or
      this.getName().matches("MINIPORT_CO_DELETE_VC") or
      this.getName().matches("MINIPORT_CO_OID_REQUEST") or
      this.getName().matches("MINIPORT_CO_SEND_NET_BUFFER_LISTS") or
      this.getName().matches("PROTOCOL_BIND_ADAPTER_EX") or
      this.getName().matches("PROTOCOL_CLOSE_ADAPTER_COMPLETE_EX") or
      this.getName().matches("PROTOCOL_DIRECT_OID_REQUEST_COMPLETE") or
      this.getName().matches("PROTOCOL_NET_PNP_EVENT") or
      this.getName().matches("PROTOCOL_OID_REQUEST_COMPLETE") or
      this.getName().matches("PROTOCOL_OPEN_ADAPTER_COMPLETE_EX") or
      this.getName().matches("PROTOCOL_RECEIVE_NET_BUFFER_LISTS") or
      this.getName().matches("PROTOCOL_SEND_NET_BUFFER_LISTS_COMPLETE") or
      this.getName().matches("PROTOCOL_SEND_NET_BUFFER_LISTS_COMPLETE") or
      this.getName().matches("PROTOCOL_SET_OPTIONS") or
      this.getName().matches("PROTOCOL_STATUS_EX") or
      this.getName().matches("PROTOCOL_UNBIND_ADAPTER_EX") or
      this.getName().matches("PROTOCOL_UNINSTALL") or
      this.getName().matches("PROTOCOL_CL_ADD_PARTY_COMPLETE") or
      this.getName().matches("PROTOCOL_CL_CALL_CONNECTED") or
      this.getName().matches("PROTOCOL_CL_CLOSE_AF_COMPLETE") or
      this.getName().matches("PROTOCOL_CL_CLOSE_CALL_COMPLETE") or
      this.getName().matches("PROTOCOL_CL_DEREGISTER_SAP_COMPLETE") or
      this.getName().matches("PROTOCOL_CL_DROP_PARTY_COMPLETE") or
      this.getName().matches("PROTOCOL_CL_INCOMING_CALL") or
      this.getName().matches("PROTOCOL_CL_INCOMING_CALL_QOS_CHANGE") or
      this.getName().matches("PROTOCOL_CL_INCOMING_CLOSE_CALL") or
      this.getName().matches("PROTOCOL_CL_INCOMING_DROP_PARTY") or
      this.getName().matches("PROTOCOL_CL_MAKE_CALL_COMPLETE") or
      this.getName().matches("PROTOCOL_CL_MODIFY_CALL_QOS_COMPLETE") or
      this.getName().matches("PROTOCOL_CL_NOTIFY_CLOSE_AF") or
      this.getName().matches("PROTOCOL_CL_OPEN_AF_COMPLETE") or
      this.getName().matches("PROTOCOL_CL_OPEN_AF_COMPLETE_EX") or
      this.getName().matches("PROTOCOL_CL_REGISTER_SAP_COMPLETE") or
      this.getName().matches("PROTOCOL_CM_ACTIVATE_VC_COMPLETE") or
      this.getName().matches("PROTOCOL_CM_ADD_PARTY") or
      this.getName().matches("PROTOCOL_CM_CLOSE_AF") or
      this.getName().matches("PROTOCOL_CM_CLOSE_CALL") or
      this.getName().matches("PROTOCOL_CM_DEACTIVATE_VC_COMPLETE") or
      this.getName().matches("PROTOCOL_CM_DEREGISTER_SAP") or
      this.getName().matches("PROTOCOL_CM_DROP_PARTY") or
      this.getName().matches("PROTOCOL_CM_INCOMING_CALL_COMPLETE") or
      this.getName().matches("PROTOCOL_CM_MAKE_CALL") or
      this.getName().matches("PROTOCOL_CM_MODIFY_QOS_CALL") or
      this.getName().matches("PROTOCOL_CM_NOTIFY_CLOSE_AF_COMPLETE") or
      this.getName().matches("PROTOCOL_CM_OPEN_AF") or
      this.getName().matches("PROTOCOL_CM_REG_SAP") or
      this.getName().matches("PROTCOL_CO_AF_REGISTER_NOTIFY") or
      this.getName().matches("PROTOCOL_CO_CREATE_VC") or
      this.getName().matches("PROTOCOL_CO_DELETE_VC") or
      this.getName().matches("PROTOCOL_CO_OID_REQUEST") or
      this.getName().matches("PROTOCOL_CO_OID_REQUEST_COMPLETE") or
      this.getName().matches("PROTOCOL_CO_RECEIVE_NET_BUFFER_LISTS") or
      this.getName().matches("PROTOCOL_CO_SEND_NET_BUFFER_LISTS_COMPLETE") or
      this.getName().matches("PROTOCOL_CO_STATUS_EX")
    )
  }
}

/** A typedef for the standard NDIS callback routines. Aka Role Types */
class NdisCallbackRoutineTypedef extends NdisRoleTypeType {
  NdisCallbackRoutineTypedef() { this.getFile().getBaseName().matches("ndis.h") }
}

/**
 * Represents a function implementing a NDIS callback routine.
 * Defines a function to be a callback routine iff it has a typedef
 * in its definition which matches the NDIS callback typedefs, and it
 * is in a NDIS driver (includes wdm.h.)
 */
class NdisCallbackRoutine extends Function {
  /** The callback routine type, i.e. DRIVER_UNLOAD. */
  NdisCallbackRoutineTypedef callbackType;

  NdisCallbackRoutine() {
    exists(FunctionDeclarationEntry fde |
      fde.getFunction() = this and
      fde.getTypedefType() = callbackType
    )
  }
}

/**
 * Similar to NdisCallbackRoutine, but specifically for Role Types
 */
abstract class NdisRoleTypeFunction extends Function {
  NdisCallbackRoutineTypedef roleType;

  NdisRoleTypeFunction() {
    exists(FunctionDeclarationEntry fde |
      fde.getFunction() = this and
      fde.getTypedefType() = roleType
    )
  }

  string getRoleTypeString() { result = roleType.getName() }

  NdisRoleTypeType getRoleTypeType() { result = roleType }
}

predicate hasRoleType(Function f) { f instanceof NdisRoleTypeFunction }

predicate roleTypeAssignment(AssignExpr ae) {
  exists(FunctionAccess fa |
    ae.getRValue() = fa and
    fa.getTarget() instanceof NdisDispatchRoutine
  )
  or
  ae.getRValue() instanceof AssignExpr and
  roleTypeAssignment(ae.getRValue().(AssignExpr))
}

class NdisDriverObjectFunctionAccess extends FunctionAccess {
  NdisRoleTypeType rttExpected;

  NdisDriverObjectFunctionAccess() {
    exists(VariableAccess driverObjectAccess, AssignExpr driverObjectAssign |
      driverObjectAccess.getTarget().getType().getName().matches("PDRIVER_OBJECT") and
      this = driverObjectAssign.getRValue() and
      rttExpected = driverObjectAssign.getLValue().getUnderlyingType().(PointerType).getBaseType()
    )
  }

  NdisRoleTypeType getExpectedRoleTypeType() { result = rttExpected }
}

class NdisDriverEntryPoint extends FunctionAccess {
  NdisDriverEntryPoint() { this instanceof NdisDriverObjectFunctionAccess }
}

// declared functions that are used as if they have a role type, wether or not they do
class NdisImplicitRoleTypeFunction extends Function {
  NdisRoleTypeType rttExpected;
  FunctionAccess funcUse;

  NdisImplicitRoleTypeFunction() {
    exists(FunctionCall fc, int n | fc.getArgument(n) instanceof FunctionAccess |
      this = fc.getArgument(n).(FunctionAccess).getTarget() and
      fc.getTarget().getParameter(n).getUnderlyingType().(PointerType).getBaseType() instanceof
        NdisRoleTypeType and
      rttExpected = fc.getTarget().getParameter(n).getUnderlyingType().(PointerType).getBaseType() and
      fc.getTarget().getParameter(n).getUnderlyingType().(PointerType).getBaseType() instanceof
        NdisRoleTypeType and
      funcUse = fc.getArgument(n)
    )
    or
    exists(NdisDriverObjectFunctionAccess funcAssign |
      funcAssign.getTarget() = this and
      rttExpected = funcAssign.getExpectedRoleTypeType() and
      funcUse = funcAssign
    )
  }

  string getExpectedRoleTypeString() { result = rttExpected.toString() }

  NdisRoleTypeType getExpectedRoleTypeType() { result = rttExpected }

  string getActualRoleTypeString() {
    if this instanceof NdisRoleTypeFunction
    then result = this.(NdisRoleTypeFunction).getRoleTypeType().toString()
    else result = "<NO_ROLE_TYPE>"
  }

  FunctionAccess getFunctionUse() { result = funcUse }
}

/** A NDIS DriverEntry callback routine. */
class NdisDriverEntry extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisDriverEntry() { callbackType.getName().matches("DRIVER_INITIALIZE") }
}

/** A NDIS MiniportAllocateSharedMemoryComplete callback routine. */
class NdisMiniportAllocateSharedMemoryComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportAllocateSharedMemoryComplete() {
    callbackType.getName().matches("MINIPORT_ALLOCATE_SHARED_MEM_COMPLETE")
  }
}

/** A NDIS MiniportHalt callback routine. */
class NdisMiniportHalt extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportHalt() { callbackType.getName().matches("MINIPORT_HALT") }
}

/** A NDIS MiniportSetOptions callback routine. */
class NdisMiniportSetOptions extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportSetOptions() { callbackType.getName().matches("MINIPORT_SET_OPTIONS") }
}

/** A NDIS MiniportInitialize callback routine. */
class NdisMiniportInitialize extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportInitialize() { callbackType.getName().matches("MINIPORT_INITIALIZE") }
}

/** A NDIS MiniportPause callback routine. */
class NdisMiniportPause extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportPause() { callbackType.getName().matches("MINIPORT_PAUSE") }
}

/** A NDIS MiniportRestart callback routine. */
class NdisMiniportRestart extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportRestart() { callbackType.getName().matches("MINIPORT_RESTART") }
}

/** A NDIS MiniportOidRequest callback routine. */
class NdisMiniportOidRequest extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportOidRequest() { callbackType.getName().matches("MINIPORT_OID_REQUEST") }
}

/** A NDIS MiniportInterruptDpc callback routine. */
class NdisMiniportInterruptDpc extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportInterruptDpc() { callbackType.getName().matches("MINIPORT_INTERRUPT_DPC") }
}

/** A NDIS MiniportIsr callback routine. */
class NdisMiniportIsr extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportIsr() { callbackType.getName().matches("MINIPORT_ISR") }
}

/** A NDIS MiniportReset callback routine. */
class NdisMiniportReset extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportReset() { callbackType.getName().matches("MINIPORT_RESET") }
}

/** A NDIS MiniportReturnNetBufferLists callback routine. */
class NdisMiniportReturnNetBufferLists extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportReturnNetBufferLists() {
    callbackType.getName().matches("MINIPORT_RETURN_NET_BUFFER_LISTS")
  }
}

/** A NDIS MiniportCancelOidRequest callback routine. */
class NdisMiniportCancelOidRequest extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportCancelOidRequest() { callbackType.getName().matches("MINIPORT_CANCEL_OID_REQUEST") }
}

/** A NDIS MiniportShutdown callback routine. */
class NdisMiniportShutdown extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportShutdown() { callbackType.getName().matches("MINIPORT_SHUTDOWN") }
}

/** A NDIS MiniportSendNetBufferLists callback routine. */
class NdisMiniportSendNetBufferLists extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportSendNetBufferLists() {
    callbackType.getName().matches("MINIPORT_SEND_NET_BUFFER_LISTS")
  }
}

/** A NDIS MiniportCancelSend callback routine. */
class NdisMiniportCancelSend extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportCancelSend() { callbackType.getName().matches("MINIPORT_CANCEL_SEND") }
}

/** A NDIS MiniportDevicePnpEventNotify callback routine. */
class NdisMiniportDevicePnpEventNotify extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportDevicePnpEventNotify() {
    callbackType.getName().matches("MINIPORT_DEVICE_PNP_EVENT_NOTIFY")
  }
}

/** A NDIS MiniportUnload callback routine. */
class NdisMiniportUnload extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportUnload() { callbackType.getName().matches("MINIPORT_UNLOAD") }
}

/** A NDIS MiniportCheckForHang callback routine. */
class NdisMiniportCheckForHang extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportCheckForHang() { callbackType.getName().matches("MINIPORT_CHECK_FOR_HANG") }
}

/** A NDIS MiniportEnableInterrupt callback routine. */
class NdisMiniportEnableInterrupt extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportEnableInterrupt() { callbackType.getName().matches("MINIPORT_ENABLE_INTERRUPT") }
}

/** A NDIS MiniportDisableInterrupt callback routine. */
class NdisMiniportDisableInterrupt extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportDisableInterrupt() { callbackType.getName().matches("MINIPORT_DISABLE_INTERRUPT") }
}

/** A NDIS MiniportSynchronizeInterrupt callback routine. */
class NdisMiniportSynchronizeInterrupt extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportSynchronizeInterrupt() {
    callbackType.getName().matches("MINIPORT_SYNCHRONIZE_INTERRUPT")
  }
}

/** A NDIS MiniportProcessSgList callback routine. */
class NdisMiniportProcessSgList extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportProcessSgList() { callbackType.getName().matches("MINIPORT_PROCESS_SG_LIST") }
}

/** A NDIS timer callback routine. */
class NdisTimerFunction extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisTimerFunction() { callbackType.getName().matches("NDIS_TIMER_FUNCTION") }
}

/** A NDIS I/O work item callback routine. */
class NdisIoWorkitem extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisIoWorkitem() { callbackType.getName().matches("NDIS_IO_WORKITEM") }
}

/** A NDIS MiniportAddDevice callback routine. */
class NdisMiniportAddDevice extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportAddDevice() { callbackType.getName().matches("MINIPORT_ADD_DEVICE") }
}

/** A NDIS MiniportCancelDirectOidRequest callback routine. */
class NdisMiniportCancelDirectOidRequest extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportCancelDirectOidRequest() {
    callbackType.getName().matches("MINIPORT_CANCEL_DIRECT_OID_REQUEST")
  }
}

/** A NDIS MiniportDirectOidRequest callback routine. */
class NdisMiniportDirectOidRequest extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportDirectOidRequest() { callbackType.getName().matches("MINIPORT_DIRECT_OID_REQUEST") }
}

/** A NDIS MiniportFilterResourceRequirements callback routine. */
class NdisMiniportFilterResourceRequirements extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportFilterResourceRequirements() {
    callbackType.getName().matches("MINIPORT_FILTER_RESOURCE_REQUIREMENTS")
  }
}

/** A NDIS MiniportStartDevice callback routine. */
class NdisMiniportStartDevice extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportStartDevice() { callbackType.getName().matches("MINIPORT_START_DEVICE") }
}

/** A NDIS MiniportSynchronizeMessageInterrupt callback routine. */
class NdisMiniportSynchronizeMessageInterrupt extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportSynchronizeMessageInterrupt() {
    callbackType.getName().matches("MINIPORT_SYNCHRONIZE_MESSAGE_INTERRUPT")
  }
}

/** A NDIS IoWorkItemFunction callback routine. */
class NdisIoWorkItemFunction extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisIoWorkItemFunction() { callbackType.getName().matches("NDIS_IO_WORKITEM_FUNCTION") }
}

/** A NDIS filter attach callback routine. */
class NdisFilterAttach extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterAttach() { callbackType.getName().matches("FILTER_ATTACH") }
}

/** A NDIS filter cancel direct OID request callback routine. */
class NdisFilterCancelDirectOidRequest extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterCancelDirectOidRequest() {
    callbackType.getName().matches("FILTER_CANCEL_DIRECT_OID_REQUEST")
  }
}

/** A NDIS filter cancel send net buffer lists callback routine. */
class NdisFilterCancelSendNetBufferLists extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterCancelSendNetBufferLists() {
    callbackType.getName().matches("FILTER_CANCEL_SEND_NET_BUFFER_LISTS")
  }
}

/** A NDIS filter cancel OID request callback routine. */
class NdisFilterCancelOidRequest extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterCancelOidRequest() { callbackType.getName().matches("FILTER_CANCEL_OID_REQUEST") }
}

/** A NDIS filter detach callback routine. */
class NdisFilterDetach extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterDetach() { callbackType.getName().matches("FILTER_DETACH") }
}

/** A NDIS filter device PNP event notify callback routine. */
class NdisFilterDevicePnpEventNotify extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterDevicePnpEventNotify() {
    callbackType.getName().matches("FILTER_DEVICE_PNP_EVENT_NOTIFY")
  }
}

/** A NDIS filter direct OID request callback routine. */
class NdisFilterDirectOidRequest extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterDirectOidRequest() { callbackType.getName().matches("FILTER_DIRECT_OID_REQUEST") }
}

/** A NDIS filter direct OID request complete callback routine. */
class NdisFilterDirectOidRequestComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterDirectOidRequestComplete() {
    callbackType.getName().matches("FILTER_DIRECT_OID_REQUEST_COMPLETE")
  }
}

/** A NDIS driver unload callback routine. */
class NdisDriverUnload extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisDriverUnload() { callbackType.getName().matches("DRIVER_UNLOAD") }
}

/** A NDIS filter net PNP event callback routine. */
class NdisFilterNetPnpEvent extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterNetPnpEvent() { callbackType.getName().matches("FILTER_NET_PNP_EVENT") }
}

/** A NDIS filter OID request callback routine. */
class NdisFilterOidRequest extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterOidRequest() { callbackType.getName().matches("FILTER_OID_REQUEST") }
}

/** A NDIS filter OID request complete callback routine. */
class NdisFilterOidRequestComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterOidRequestComplete() { callbackType.getName().matches("FILTER_OID_REQUEST_COMPLETE") }
}

/** A NDIS filter pause callback routine. */
class NdisFilterPause extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterPause() { callbackType.getName().matches("FILTER_PAUSE") }
}

/** A NDIS filter receive net buffer lists callback routine. */
class NdisFilterReceiveNetBufferLists extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterReceiveNetBufferLists() {
    callbackType.getName().matches("FILTER_RECEIVE_NET_BUFFER_LISTS")
  }
}

/** A NDIS filter restart callback routine. */
class NdisFilterRestart extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterRestart() { callbackType.getName().matches("FILTER_RESTART") }
}

/** A NDIS filter return net buffer lists callback routine. */
class NdisFilterReturnNetBufferLists extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterReturnNetBufferLists() {
    callbackType.getName().matches("FILTER_RETURN_NET_BUFFER_LISTS")
  }
}

/** A NDIS filter send net buffer lists callback routine. */
class NdisFilterSendNetBufferLists extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterSendNetBufferLists() { callbackType.getName().matches("FILTER_SEND_NET_BUFFER_LISTS") }
}

/** A NDIS filter send net buffer lists complete callback routine. */
class NdisFilterSendNetBufferListsComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterSendNetBufferListsComplete() {
    callbackType.getName().matches("FILTER_SEND_NET_BUFFER_LISTS_COMPLETE")
  }
}

/** A NDIS filter set module options callback routine. */
class NdisFilterSetModuleOptions extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterSetModuleOptions() { callbackType.getName().matches("FILTER_SET_MODULE_OPTIONS") }
}

/** A NDIS filter set options callback routine. */
class NdisFilterSetOptions extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterSetOptions() { callbackType.getName().matches("FILTER_SET_OPTIONS") }
}

/** A NDIS filter status callback routine. */
class NdisFilterStatus extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisFilterStatus() { callbackType.getName().matches("FILTER_STATUS") }
}

/** A NDIS miniport CO activate VC callback routine. */
class NdisMiniportCoActivateVc extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportCoActivateVc() { callbackType.getName().matches("MINIPORT_CO_ACTIVATE_VC") }
}

/** A NDIS miniport CO create VC callback routine. */
class NdisMiniportCoCreateVc extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportCoCreateVc() { callbackType.getName().matches("MINIPORT_CO_CREATE_VC") }
}

/** A NDIS miniport CO deactivate VC callback routine. */
class NdisMiniportCoDeactivateVc extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportCoDeactivateVc() { callbackType.getName().matches("MINIPORT_CO_DEACTIVATE_VC") }
}

/** A NDIS miniport CO delete VC callback routine. */
class NdisMiniportCoDeleteVc extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportCoDeleteVc() { callbackType.getName().matches("MINIPORT_CO_DELETE_VC") }
}

/** A NDIS miniport CO OID request callback routine. */
class NdisMiniportCoOidRequest extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportCoOidRequest() { callbackType.getName().matches("MINIPORT_CO_OID_REQUEST") }
}

/** A NDIS miniport CO send net buffer lists callback routine. */
class NdisMiniportCoSendNetBufferLists extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisMiniportCoSendNetBufferLists() {
    callbackType.getName().matches("MINIPORT_CO_SEND_NET_BUFFER_LISTS")
  }
}

/** A NDIS protocol bind adapter ex callback routine. */
class NdisProtocolBindAdapterEx extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolBindAdapterEx() { callbackType.getName().matches("PROTOCOL_BIND_ADAPTER_EX") }
}

/** A NDIS protocol close adapter complete ex callback routine. */
class NdisProtocolCloseAdapterCompleteEx extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCloseAdapterCompleteEx() {
    callbackType.getName().matches("PROTOCOL_CLOSE_ADAPTER_COMPLETE_EX")
  }
}

/** A NDIS protocol direct OID request complete callback routine. */
class NdisProtocolDirectOidRequestComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolDirectOidRequestComplete() {
    callbackType.getName().matches("PROTOCOL_DIRECT_OID_REQUEST_COMPLETE")
  }
}

/** A NDIS protocol net PNP event callback routine. */
class NdisProtocolNetPnpEvent extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolNetPnpEvent() { callbackType.getName().matches("PROTOCOL_NET_PNP_EVENT") }
}

/** A NDIS protocol OID request complete callback routine. */
class NdisProtocolOidRequestComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolOidRequestComplete() {
    callbackType.getName().matches("PROTOCOL_OID_REQUEST_COMPLETE")
  }
}

/** A NDIS protocol open adapter complete ex callback routine. */
class NdisProtocolOpenAdapterCompleteEx extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolOpenAdapterCompleteEx() {
    callbackType.getName().matches("PROTOCOL_OPEN_ADAPTER_COMPLETE_EX")
  }
}

/** A NDIS protocol receive net buffer lists callback routine. */
class NdisProtocolReceiveNetBufferLists extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolReceiveNetBufferLists() {
    callbackType.getName().matches("PROTOCOL_RECEIVE_NET_BUFFER_LISTS")
  }
}

/** A NDIS protocol send net buffer lists complete callback routine. */
class NdisProtocolSendNetBufferListsComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolSendNetBufferListsComplete() {
    callbackType.getName().matches("PROTOCOL_SEND_NET_BUFFER_LISTS_COMPLETE")
  }
}

/** A NDIS protocol set options callback routine. */
class NdisProtocolSetOptions extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolSetOptions() { callbackType.getName().matches("PROTOCOL_SET_OPTIONS") }
}

/** A NDIS protocol status ex callback routine. */
class NdisProtocolStatusEx extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolStatusEx() { callbackType.getName().matches("PROTOCOL_STATUS_EX") }
}

/** A NDIS protocol unbind adapter ex callback routine. */
class NdisProtocolUnbindAdapterEx extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolUnbindAdapterEx() { callbackType.getName().matches("PROTOCOL_UNBIND_ADAPTER_EX") }
}

/** A NDIS protocol uninstall callback routine. */
class NdisProtocolUninstall extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolUninstall() { callbackType.getName().matches("PROTOCOL_UNINSTALL") }
}

/** A NDIS protocol call manager add party complete callback routine. */
class NdisProtocolClAddPartyComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolClAddPartyComplete() {
    callbackType.getName().matches("PROTOCOL_CL_ADD_PARTY_COMPLETE")
  }
}

/** A NDIS protocol call manager call connected callback routine. */
class NdisProtocolClCallConnected extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolClCallConnected() { callbackType.getName().matches("PROTOCOL_CL_CALL_CONNECTED") }
}

/** A NDIS protocol call manager close AF complete callback routine. */
class NdisProtocolClCloseAfComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolClCloseAfComplete() {
    callbackType.getName().matches("PROTOCOL_CL_CLOSE_AF_COMPLETE")
  }
}

/** A NDIS protocol call manager close call complete callback routine. */
class NdisProtocolClCloseCallComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolClCloseCallComplete() {
    callbackType.getName().matches("PROTOCOL_CL_CLOSE_CALL_COMPLETE")
  }
}

/** A NDIS protocol call manager deregister SAP complete callback routine. */
class NdisProtocolClDeregisterSapComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolClDeregisterSapComplete() {
    callbackType.getName().matches("PROTOCOL_CL_DEREGISTER_SAP_COMPLETE")
  }
}

/** A NDIS protocol call manager drop party complete callback routine. */
class NdisProtocolClDropPartyComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolClDropPartyComplete() {
    callbackType.getName().matches("PROTOCOL_CL_DROP_PARTY_COMPLETE")
  }
}

/** A NDIS protocol call manager incoming call callback routine. */
class NdisProtocolClIncomingCall extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolClIncomingCall() { callbackType.getName().matches("PROTOCOL_CL_INCOMING_CALL") }
}

/** A NDIS protocol call manager incoming call QoS change callback routine. */
class NdisProtocolClIncomingCallQosChange extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolClIncomingCallQosChange() {
    callbackType.getName().matches("PROTOCOL_CL_INCOMING_CALL_QOS_CHANGE")
  }
}

/** A NDIS protocol call manager incoming close call callback routine. */
class NdisProtocolClIncomingCloseCall extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolClIncomingCloseCall() {
    callbackType.getName().matches("PROTOCOL_CL_INCOMING_CLOSE_CALL")
  }
}

/** A NDIS protocol call manager incoming drop party callback routine. */
class NdisProtocolClIncomingDropParty extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolClIncomingDropParty() {
    callbackType.getName().matches("PROTOCOL_CL_INCOMING_DROP_PARTY")
  }
}

/** A NDIS protocol call manager make call complete callback routine. */
class NdisProtocolClMakeCallComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolClMakeCallComplete() {
    callbackType.getName().matches("PROTOCOL_CL_MAKE_CALL_COMPLETE")
  }
}

/** A NDIS protocol call manager modify call QoS complete callback routine. */
class NdisProtocolClModifyCallQosComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolClModifyCallQosComplete() {
    callbackType.getName().matches("PROTOCOL_CL_MODIFY_CALL_QOS_COMPLETE")
  }
}

/** A NDIS protocol call manager notify close AF callback routine. */
class NdisProtocolClNotifyCloseAf extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolClNotifyCloseAf() { callbackType.getName().matches("PROTOCOL_CL_NOTIFY_CLOSE_AF") }
}

/** A NDIS protocol call manager open AF complete callback routine. */
class NdisProtocolClOpenAfComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolClOpenAfComplete() { callbackType.getName().matches("PROTOCOL_CL_OPEN_AF_COMPLETE") }
}

/** A NDIS protocol call manager open AF complete ex callback routine. */
class NdisProtocolClOpenAfCompleteEx extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolClOpenAfCompleteEx() {
    callbackType.getName().matches("PROTOCOL_CL_OPEN_AF_COMPLETE_EX")
  }
}

/** A NDIS protocol call manager register SAP complete callback routine. */
class NdisProtocolClRegisterSapComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolClRegisterSapComplete() {
    callbackType.getName().matches("PROTOCOL_CL_REGISTER_SAP_COMPLETE")
  }
}

/** A NDIS protocol connection manager activate VC complete callback routine. */
class NdisProtocolCmActivateVcComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCmActivateVcComplete() {
    callbackType.getName().matches("PROTOCOL_CM_ACTIVATE_VC_COMPLETE")
  }
}

/** A NDIS protocol connection manager add party callback routine. */
class NdisProtocolCmAddParty extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCmAddParty() { callbackType.getName().matches("PROTOCOL_CM_ADD_PARTY") }
}

/** A NDIS protocol connection manager close AF callback routine. */
class NdisProtocolCmCloseAf extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCmCloseAf() { callbackType.getName().matches("PROTOCOL_CM_CLOSE_AF") }
}

/** A NDIS protocol connection manager close call callback routine. */
class NdisProtocolCmCloseCall extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCmCloseCall() { callbackType.getName().matches("PROTOCOL_CM_CLOSE_CALL") }
}

/** A NDIS protocol connection manager deactivate VC complete callback routine. */
class NdisProtocolCmDeactivateVcComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCmDeactivateVcComplete() {
    callbackType.getName().matches("PROTOCOL_CM_DEACTIVATE_VC_COMPLETE")
  }
}

/** A NDIS protocol connection manager deregister SAP callback routine. */
class NdisProtocolCmDeregisterSap extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCmDeregisterSap() { callbackType.getName().matches("PROTOCOL_CM_DEREGISTER_SAP") }
}

/** A NDIS protocol connection manager drop party callback routine. */
class NdisProtocolCmDropParty extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCmDropParty() { callbackType.getName().matches("PROTOCOL_CM_DROP_PARTY") }
}

/** A NDIS protocol connection manager incoming call complete callback routine. */
class NdisProtocolCmIncomingCallComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCmIncomingCallComplete() {
    callbackType.getName().matches("PROTOCOL_CM_INCOMING_CALL_COMPLETE")
  }
}

/** A NDIS protocol connection manager make call callback routine. */
class NdisProtocolCmMakeCall extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCmMakeCall() { callbackType.getName().matches("PROTOCOL_CM_MAKE_CALL") }
}

/** A NDIS protocol connection manager modify QoS call callback routine. */
class NdisProtocolCmModifyQosCall extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCmModifyQosCall() { callbackType.getName().matches("PROTOCOL_CM_MODIFY_QOS_CALL") }
}

/** A NDIS protocol connection manager notify close AF complete callback routine. */
class NdisProtocolCmNotifyCloseAfComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCmNotifyCloseAfComplete() {
    callbackType.getName().matches("PROTOCOL_CM_NOTIFY_CLOSE_AF_COMPLETE")
  }
}

/** A NDIS protocol connection manager open AF callback routine. */
class NdisProtocolCmOpenAf extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCmOpenAf() { callbackType.getName().matches("PROTOCOL_CM_OPEN_AF") }
}

/** A NDIS protocol connection manager register SAP callback routine. */
class NdisProtocolCmRegSap extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCmRegSap() { callbackType.getName().matches("PROTOCOL_CM_REG_SAP") }
}

/** A NDIS protocol CO AF register notify callback routine. */
class NdisProtocolCoAfRegisterNotify extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCoAfRegisterNotify() {
    callbackType.getName().matches("PROTCOL_CO_AF_REGISTER_NOTIFY")
  }
}

/** A NDIS protocol CO create VC callback routine. */
class NdisProtocolCoCreateVc extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCoCreateVc() { callbackType.getName().matches("PROTOCOL_CO_CREATE_VC") }
}

/** A NDIS protocol CO delete VC callback routine. */
class NdisProtocolCoDeleteVc extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCoDeleteVc() { callbackType.getName().matches("PROTOCOL_CO_DELETE_VC") }
}

/** A NDIS protocol CO OID request callback routine. */
class NdisProtocolCoOidRequest extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCoOidRequest() { callbackType.getName().matches("PROTOCOL_CO_OID_REQUEST") }
}

/** A NDIS protocol CO OID request complete callback routine. */
class NdisProtocolCoOidRequestComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCoOidRequestComplete() {
    callbackType.getName().matches("PROTOCOL_CO_OID_REQUEST_COMPLETE")
  }
}

/** A NDIS protocol CO receive net buffer lists callback routine. */
class NdisProtocolCoReceiveNetBufferLists extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCoReceiveNetBufferLists() {
    callbackType.getName().matches("PROTOCOL_CO_RECEIVE_NET_BUFFER_LISTS")
  }
}

/** A NDIS protocol CO send net buffer lists complete callback routine. */
class NdisProtocolCoSendNetBufferListsComplete extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCoSendNetBufferListsComplete() {
    callbackType.getName().matches("PROTOCOL_CO_SEND_NET_BUFFER_LISTS_COMPLETE")
  }
}

/** A NDIS protocol CO status ex callback routine. */
class NdisProtocolCoStatusEx extends NdisCallbackRoutine, NdisRoleTypeFunction {
  NdisProtocolCoStatusEx() { callbackType.getName().matches("PROTOCOL_CO_STATUS_EX") }
}
