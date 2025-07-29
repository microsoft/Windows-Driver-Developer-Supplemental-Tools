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
class NdisDispatchRoutine extends NdisCallbackRoutine {
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
  NdisDispatchRoutine() {
    callbackType.getName().matches("NDIS_DISPATCH") and
    exists(
      NdisCallbackRoutineAssignment cra, PointerFieldAccess dispatchTable,
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
  
  Literal getDispatchType() { result = dispatchType }

  /** Gets the DriverEntry this dispatch routine was assigned in. */
  
  NdisDriverEntry getDriverEntry() { result = driverEntry }
}

/** An assignment where the right-hand side is a NDIS callback routine. */
class NdisCallbackRoutineAssignment extends AssignExpr {
  /*
   * A common paradigm in dispatch routine setup is to chain assignments to cover multiple IRPs.
   * As such, it's necessary to recursively walk the assignment to handle cases such as
   *   DriverObject->MajorFunction[IRP_MJ_CREATE] =
   *   DriverObject->MajorFunction[IRP_MJ_OPEN] =
   *   MyMultiFunctionIrpHandler;
   * However, characterstic predicates cannot be recurisve, so the logic is placed in a separate
   * predicate below, isNdisCallbackRoutineAssignment.
   */

  NdisCallbackRoutineAssignment() { isNdisCallbackRoutineAssignment(this) }

  /** Gets the callback routine that this dispatch routine assignment is targeting. */
  
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
private predicate isNdisCallbackRoutineAssignment(AssignExpr ae) {
  exists(FunctionAccess fa |
    ae.getRValue() = fa and
    fa.getTarget() instanceof NdisCallbackRoutine
  )
  or
  ae.getRValue() instanceof AssignExpr and
  isNdisCallbackRoutineAssignment(ae.getRValue().(AssignExpr))
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


/** A NDIS DriverEntry callback routine. */
class NdisDriverEntry extends NdisCallbackRoutine {
  NdisDriverEntry() { callbackType.getName().matches("DRIVER_INITIALIZE") }
}

/** A NDIS MiniportAllocateSharedMemoryComplete callback routine. */
class NdisMiniportAllocateSharedMemoryComplete extends NdisCallbackRoutine {
  NdisMiniportAllocateSharedMemoryComplete() {
    callbackType.getName().matches("MINIPORT_ALLOCATE_SHARED_MEM_COMPLETE")
  }
}

/** A NDIS MiniportHalt callback routine. */
class NdisMiniportHalt extends NdisCallbackRoutine {
  NdisMiniportHalt() { callbackType.getName().matches("MINIPORT_HALT") }
}

/** A NDIS MiniportSetOptions callback routine. */
class NdisMiniportSetOptions extends NdisCallbackRoutine {
  NdisMiniportSetOptions() { callbackType.getName().matches("MINIPORT_SET_OPTIONS") }
}

/** A NDIS MiniportInitialize callback routine. */
class NdisMiniportInitialize extends NdisCallbackRoutine {
  NdisMiniportInitialize() { callbackType.getName().matches("MINIPORT_INITIALIZE") }
}

/** A NDIS MiniportPause callback routine. */
class NdisMiniportPause extends NdisCallbackRoutine {
  NdisMiniportPause() { callbackType.getName().matches("MINIPORT_PAUSE") }
}

/** A NDIS MiniportRestart callback routine. */
class NdisMiniportRestart extends NdisCallbackRoutine {
  NdisMiniportRestart() { callbackType.getName().matches("MINIPORT_RESTART") }
}

/** A NDIS MiniportOidRequest callback routine. */
class NdisMiniportOidRequest extends NdisCallbackRoutine {
  NdisMiniportOidRequest() { callbackType.getName().matches("MINIPORT_OID_REQUEST") }
}

/** A NDIS MiniportInterruptDpc callback routine. */
class NdisMiniportInterruptDpc extends NdisCallbackRoutine {
  NdisMiniportInterruptDpc() { callbackType.getName().matches("MINIPORT_INTERRUPT_DPC") }
}

/** A NDIS MiniportIsr callback routine. */
class NdisMiniportIsr extends NdisCallbackRoutine {
  NdisMiniportIsr() { callbackType.getName().matches("MINIPORT_ISR") }
}

/** A NDIS MiniportReset callback routine. */
class NdisMiniportReset extends NdisCallbackRoutine {
  NdisMiniportReset() { callbackType.getName().matches("MINIPORT_RESET") }
}

/** A NDIS MiniportReturnNetBufferLists callback routine. */
class NdisMiniportReturnNetBufferLists extends NdisCallbackRoutine {
  NdisMiniportReturnNetBufferLists() {
    callbackType.getName().matches("MINIPORT_RETURN_NET_BUFFER_LISTS")
  }
}

/** A NDIS MiniportCancelOidRequest callback routine. */
class NdisMiniportCancelOidRequest extends NdisCallbackRoutine {
  NdisMiniportCancelOidRequest() { callbackType.getName().matches("MINIPORT_CANCEL_OID_REQUEST") }
}

/** A NDIS MiniportShutdown callback routine. */
class NdisMiniportShutdown extends NdisCallbackRoutine {
  NdisMiniportShutdown() { callbackType.getName().matches("MINIPORT_SHUTDOWN") }
}

/** A NDIS MiniportSendNetBufferLists callback routine. */
class NdisMiniportSendNetBufferLists extends NdisCallbackRoutine {
  NdisMiniportSendNetBufferLists() {
    callbackType.getName().matches("MINIPORT_SEND_NET_BUFFER_LISTS")
  }
}

/** A NDIS MiniportCancelSend callback routine. */
class NdisMiniportCancelSend extends NdisCallbackRoutine {
  NdisMiniportCancelSend() { callbackType.getName().matches("MINIPORT_CANCEL_SEND") }
}

/** A NDIS MiniportDevicePnpEventNotify callback routine. */
class NdisMiniportDevicePnpEventNotify extends NdisCallbackRoutine {
  NdisMiniportDevicePnpEventNotify() {
    callbackType.getName().matches("MINIPORT_DEVICE_PNP_EVENT_NOTIFY")
  }
}

/** A NDIS MiniportUnload callback routine. */
class NdisMiniportUnload extends NdisCallbackRoutine {
  NdisMiniportUnload() { callbackType.getName().matches("MINIPORT_UNLOAD") }
}

/** A NDIS MiniportCheckForHang callback routine. */
class NdisMiniportCheckForHang extends NdisCallbackRoutine {
  NdisMiniportCheckForHang() { callbackType.getName().matches("MINIPORT_CHECK_FOR_HANG") }
}

/** A NDIS MiniportEnableInterrupt callback routine. */
class NdisMiniportEnableInterrupt extends NdisCallbackRoutine {
  NdisMiniportEnableInterrupt() { callbackType.getName().matches("MINIPORT_ENABLE_INTERRUPT") }
}

/** A NDIS MiniportDisableInterrupt callback routine. */
class NdisMiniportDisableInterrupt extends NdisCallbackRoutine {
  NdisMiniportDisableInterrupt() { callbackType.getName().matches("MINIPORT_DISABLE_INTERRUPT") }
}

/** A NDIS MiniportSynchronizeInterrupt callback routine. */
class NdisMiniportSynchronizeInterrupt extends NdisCallbackRoutine {
  NdisMiniportSynchronizeInterrupt() {
    callbackType.getName().matches("MINIPORT_SYNCHRONIZE_INTERRUPT")
  }
}

/** A NDIS MiniportProcessSgList callback routine. */
class NdisMiniportProcessSgList extends NdisCallbackRoutine {
  NdisMiniportProcessSgList() { callbackType.getName().matches("MINIPORT_PROCESS_SG_LIST") }
}

/** A NDIS timer callback routine. */
class NdisTimerFunction extends NdisCallbackRoutine {
  NdisTimerFunction() { callbackType.getName().matches("NDIS_TIMER_FUNCTION") }
}

/** A NDIS I/O work item callback routine. */
class NdisIoWorkitem extends NdisCallbackRoutine {
  NdisIoWorkitem() { callbackType.getName().matches("NDIS_IO_WORKITEM") }
}

/** A NDIS MiniportAddDevice callback routine. */
class NdisMiniportAddDevice extends NdisCallbackRoutine {
  NdisMiniportAddDevice() { callbackType.getName().matches("MINIPORT_ADD_DEVICE") }
}

/** A NDIS MiniportCancelDirectOidRequest callback routine. */
class NdisMiniportCancelDirectOidRequest extends NdisCallbackRoutine {
  NdisMiniportCancelDirectOidRequest() {
    callbackType.getName().matches("MINIPORT_CANCEL_DIRECT_OID_REQUEST")
  }
}

/** A NDIS MiniportDirectOidRequest callback routine. */
class NdisMiniportDirectOidRequest extends NdisCallbackRoutine {
  NdisMiniportDirectOidRequest() { callbackType.getName().matches("MINIPORT_DIRECT_OID_REQUEST") }
}

/** A NDIS MiniportFilterResourceRequirements callback routine. */
class NdisMiniportFilterResourceRequirements extends NdisCallbackRoutine {
  NdisMiniportFilterResourceRequirements() {
    callbackType.getName().matches("MINIPORT_FILTER_RESOURCE_REQUIREMENTS")
  }
}

/** A NDIS MiniportStartDevice callback routine. */
class NdisMiniportStartDevice extends NdisCallbackRoutine {
  NdisMiniportStartDevice() { callbackType.getName().matches("MINIPORT_START_DEVICE") }
}

/** A NDIS MiniportSynchronizeMessageInterrupt callback routine. */
class NdisMiniportSynchronizeMessageInterrupt extends NdisCallbackRoutine {
  NdisMiniportSynchronizeMessageInterrupt() {
    callbackType.getName().matches("MINIPORT_SYNCHRONIZE_MESSAGE_INTERRUPT")
  }
}

/** A NDIS IoWorkItemFunction callback routine. */
class NdisIoWorkItemFunction extends NdisCallbackRoutine {
  NdisIoWorkItemFunction() { callbackType.getName().matches("NDIS_IO_WORKITEM_FUNCTION") }
}

/** A NDIS filter attach callback routine. */
class NdisFilterAttach extends NdisCallbackRoutine {
  NdisFilterAttach() { callbackType.getName().matches("FILTER_ATTACH") }
}

/** A NDIS filter cancel direct OID request callback routine. */
class NdisFilterCancelDirectOidRequest extends NdisCallbackRoutine {
  NdisFilterCancelDirectOidRequest() {
    callbackType.getName().matches("FILTER_CANCEL_DIRECT_OID_REQUEST")
  }
}

/** A NDIS filter cancel send net buffer lists callback routine. */
class NdisFilterCancelSendNetBufferLists extends NdisCallbackRoutine {
  NdisFilterCancelSendNetBufferLists() {
    callbackType.getName().matches("FILTER_CANCEL_SEND_NET_BUFFER_LISTS")
  }
}

/** A NDIS filter cancel OID request callback routine. */
class NdisFilterCancelOidRequest extends NdisCallbackRoutine {
  NdisFilterCancelOidRequest() { callbackType.getName().matches("FILTER_CANCEL_OID_REQUEST") }
}

/** A NDIS filter detach callback routine. */
class NdisFilterDetach extends NdisCallbackRoutine {
  NdisFilterDetach() { callbackType.getName().matches("FILTER_DETACH") }
}

/** A NDIS filter device PNP event notify callback routine. */
class NdisFilterDevicePnpEventNotify extends NdisCallbackRoutine {
  NdisFilterDevicePnpEventNotify() {
    callbackType.getName().matches("FILTER_DEVICE_PNP_EVENT_NOTIFY")
  }
}

/** A NDIS filter direct OID request callback routine. */
class NdisFilterDirectOidRequest extends NdisCallbackRoutine {
  NdisFilterDirectOidRequest() { callbackType.getName().matches("FILTER_DIRECT_OID_REQUEST") }
}

/** A NDIS filter direct OID request complete callback routine. */
class NdisFilterDirectOidRequestComplete extends NdisCallbackRoutine {
  NdisFilterDirectOidRequestComplete() {
    callbackType.getName().matches("FILTER_DIRECT_OID_REQUEST_COMPLETE")
  }
}

/** A NDIS driver unload callback routine. */
class NdisDriverUnload extends NdisCallbackRoutine {
  NdisDriverUnload() { callbackType.getName().matches("DRIVER_UNLOAD") }
}

/** A NDIS filter net PNP event callback routine. */
class NdisFilterNetPnpEvent extends NdisCallbackRoutine {
  NdisFilterNetPnpEvent() { callbackType.getName().matches("FILTER_NET_PNP_EVENT") }
}

/** A NDIS filter OID request callback routine. */
class NdisFilterOidRequest extends NdisCallbackRoutine {
  NdisFilterOidRequest() { callbackType.getName().matches("FILTER_OID_REQUEST") }
}

/** A NDIS filter OID request complete callback routine. */
class NdisFilterOidRequestComplete extends NdisCallbackRoutine {
  NdisFilterOidRequestComplete() { callbackType.getName().matches("FILTER_OID_REQUEST_COMPLETE") }
}

/** A NDIS filter pause callback routine. */
class NdisFilterPause extends NdisCallbackRoutine {
  NdisFilterPause() { callbackType.getName().matches("FILTER_PAUSE") }
}

/** A NDIS filter receive net buffer lists callback routine. */
class NdisFilterReceiveNetBufferLists extends NdisCallbackRoutine {
  NdisFilterReceiveNetBufferLists() {
    callbackType.getName().matches("FILTER_RECEIVE_NET_BUFFER_LISTS")
  }
}

/** A NDIS filter restart callback routine. */
class NdisFilterRestart extends NdisCallbackRoutine {
  NdisFilterRestart() { callbackType.getName().matches("FILTER_RESTART") }
}

/** A NDIS filter return net buffer lists callback routine. */
class NdisFilterReturnNetBufferLists extends NdisCallbackRoutine {
  NdisFilterReturnNetBufferLists() {
    callbackType.getName().matches("FILTER_RETURN_NET_BUFFER_LISTS")
  }
}

/** A NDIS filter send net buffer lists callback routine. */
class NdisFilterSendNetBufferLists extends NdisCallbackRoutine {
  NdisFilterSendNetBufferLists() { callbackType.getName().matches("FILTER_SEND_NET_BUFFER_LISTS") }
}

/** A NDIS filter send net buffer lists complete callback routine. */
class NdisFilterSendNetBufferListsComplete extends NdisCallbackRoutine {
  NdisFilterSendNetBufferListsComplete() {
    callbackType.getName().matches("FILTER_SEND_NET_BUFFER_LISTS_COMPLETE")
  }
}

/** A NDIS filter set module options callback routine. */
class NdisFilterSetModuleOptions extends NdisCallbackRoutine {
  NdisFilterSetModuleOptions() { callbackType.getName().matches("FILTER_SET_MODULE_OPTIONS") }
}

/** A NDIS filter set options callback routine. */
class NdisFilterSetOptions extends NdisCallbackRoutine {
  NdisFilterSetOptions() { callbackType.getName().matches("FILTER_SET_OPTIONS") }
}

/** A NDIS filter status callback routine. */
class NdisFilterStatus extends NdisCallbackRoutine {
  NdisFilterStatus() { callbackType.getName().matches("FILTER_STATUS") }
}

/** A NDIS miniport CO activate VC callback routine. */
class NdisMiniportCoActivateVc extends NdisCallbackRoutine {
  NdisMiniportCoActivateVc() { callbackType.getName().matches("MINIPORT_CO_ACTIVATE_VC") }
}

/** A NDIS miniport CO create VC callback routine. */
class NdisMiniportCoCreateVc extends NdisCallbackRoutine {
  NdisMiniportCoCreateVc() { callbackType.getName().matches("MINIPORT_CO_CREATE_VC") }
}

/** A NDIS miniport CO deactivate VC callback routine. */
class NdisMiniportCoDeactivateVc extends NdisCallbackRoutine {
  NdisMiniportCoDeactivateVc() { callbackType.getName().matches("MINIPORT_CO_DEACTIVATE_VC") }
}

/** A NDIS miniport CO delete VC callback routine. */
class NdisMiniportCoDeleteVc extends NdisCallbackRoutine {
  NdisMiniportCoDeleteVc() { callbackType.getName().matches("MINIPORT_CO_DELETE_VC") }
}

/** A NDIS miniport CO OID request callback routine. */
class NdisMiniportCoOidRequest extends NdisCallbackRoutine {
  NdisMiniportCoOidRequest() { callbackType.getName().matches("MINIPORT_CO_OID_REQUEST") }
}

/** A NDIS miniport CO send net buffer lists callback routine. */
class NdisMiniportCoSendNetBufferLists extends NdisCallbackRoutine {
  NdisMiniportCoSendNetBufferLists() {
    callbackType.getName().matches("MINIPORT_CO_SEND_NET_BUFFER_LISTS")
  }
}

/** A NDIS protocol bind adapter ex callback routine. */
class NdisProtocolBindAdapterEx extends NdisCallbackRoutine {
  NdisProtocolBindAdapterEx() { callbackType.getName().matches("PROTOCOL_BIND_ADAPTER_EX") }
}

/** A NDIS protocol close adapter complete ex callback routine. */
class NdisProtocolCloseAdapterCompleteEx extends NdisCallbackRoutine {
  NdisProtocolCloseAdapterCompleteEx() {
    callbackType.getName().matches("PROTOCOL_CLOSE_ADAPTER_COMPLETE_EX")
  }
}

/** A NDIS protocol direct OID request complete callback routine. */
class NdisProtocolDirectOidRequestComplete extends NdisCallbackRoutine {
  NdisProtocolDirectOidRequestComplete() {
    callbackType.getName().matches("PROTOCOL_DIRECT_OID_REQUEST_COMPLETE")
  }
}

/** A NDIS protocol net PNP event callback routine. */
class NdisProtocolNetPnpEvent extends NdisCallbackRoutine {
  NdisProtocolNetPnpEvent() { callbackType.getName().matches("PROTOCOL_NET_PNP_EVENT") }
}

/** A NDIS protocol OID request complete callback routine. */
class NdisProtocolOidRequestComplete extends NdisCallbackRoutine {
  NdisProtocolOidRequestComplete() {
    callbackType.getName().matches("PROTOCOL_OID_REQUEST_COMPLETE")
  }
}

/** A NDIS protocol open adapter complete ex callback routine. */
class NdisProtocolOpenAdapterCompleteEx extends NdisCallbackRoutine {
  NdisProtocolOpenAdapterCompleteEx() {
    callbackType.getName().matches("PROTOCOL_OPEN_ADAPTER_COMPLETE_EX")
  }
}

/** A NDIS protocol receive net buffer lists callback routine. */
class NdisProtocolReceiveNetBufferLists extends NdisCallbackRoutine {
  NdisProtocolReceiveNetBufferLists() {
    callbackType.getName().matches("PROTOCOL_RECEIVE_NET_BUFFER_LISTS")
  }
}

/** A NDIS protocol send net buffer lists complete callback routine. */
class NdisProtocolSendNetBufferListsComplete extends NdisCallbackRoutine {
  NdisProtocolSendNetBufferListsComplete() {
    callbackType.getName().matches("PROTOCOL_SEND_NET_BUFFER_LISTS_COMPLETE")
  }
}

/** A NDIS protocol set options callback routine. */
class NdisProtocolSetOptions extends NdisCallbackRoutine {
  NdisProtocolSetOptions() { callbackType.getName().matches("PROTOCOL_SET_OPTIONS") }
}

/** A NDIS protocol status ex callback routine. */
class NdisProtocolStatusEx extends NdisCallbackRoutine {
  NdisProtocolStatusEx() { callbackType.getName().matches("PROTOCOL_STATUS_EX") }
}

/** A NDIS protocol unbind adapter ex callback routine. */
class NdisProtocolUnbindAdapterEx extends NdisCallbackRoutine {
  NdisProtocolUnbindAdapterEx() { callbackType.getName().matches("PROTOCOL_UNBIND_ADAPTER_EX") }
}

/** A NDIS protocol uninstall callback routine. */
class NdisProtocolUninstall extends NdisCallbackRoutine {
  NdisProtocolUninstall() { callbackType.getName().matches("PROTOCOL_UNINSTALL") }
}

/** A NDIS protocol call manager add party complete callback routine. */
class NdisProtocolClAddPartyComplete extends NdisCallbackRoutine {
  NdisProtocolClAddPartyComplete() {
    callbackType.getName().matches("PROTOCOL_CL_ADD_PARTY_COMPLETE")
  }
}

/** A NDIS protocol call manager call connected callback routine. */
class NdisProtocolClCallConnected extends NdisCallbackRoutine {
  NdisProtocolClCallConnected() { callbackType.getName().matches("PROTOCOL_CL_CALL_CONNECTED") }
}

/** A NDIS protocol call manager close AF complete callback routine. */
class NdisProtocolClCloseAfComplete extends NdisCallbackRoutine {
  NdisProtocolClCloseAfComplete() {
    callbackType.getName().matches("PROTOCOL_CL_CLOSE_AF_COMPLETE")
  }
}

/** A NDIS protocol call manager close call complete callback routine. */
class NdisProtocolClCloseCallComplete extends NdisCallbackRoutine {
  NdisProtocolClCloseCallComplete() {
    callbackType.getName().matches("PROTOCOL_CL_CLOSE_CALL_COMPLETE")
  }
}

/** A NDIS protocol call manager deregister SAP complete callback routine. */
class NdisProtocolClDeregisterSapComplete extends NdisCallbackRoutine {
  NdisProtocolClDeregisterSapComplete() {
    callbackType.getName().matches("PROTOCOL_CL_DEREGISTER_SAP_COMPLETE")
  }
}

/** A NDIS protocol call manager drop party complete callback routine. */
class NdisProtocolClDropPartyComplete extends NdisCallbackRoutine {
  NdisProtocolClDropPartyComplete() {
    callbackType.getName().matches("PROTOCOL_CL_DROP_PARTY_COMPLETE")
  }
}

/** A NDIS protocol call manager incoming call callback routine. */
class NdisProtocolClIncomingCall extends NdisCallbackRoutine {
  NdisProtocolClIncomingCall() { callbackType.getName().matches("PROTOCOL_CL_INCOMING_CALL") }
}

/** A NDIS protocol call manager incoming call QoS change callback routine. */
class NdisProtocolClIncomingCallQosChange extends NdisCallbackRoutine {
  NdisProtocolClIncomingCallQosChange() {
    callbackType.getName().matches("PROTOCOL_CL_INCOMING_CALL_QOS_CHANGE")
  }
}

/** A NDIS protocol call manager incoming close call callback routine. */
class NdisProtocolClIncomingCloseCall extends NdisCallbackRoutine {
  NdisProtocolClIncomingCloseCall() {
    callbackType.getName().matches("PROTOCOL_CL_INCOMING_CLOSE_CALL")
  }
}

/** A NDIS protocol call manager incoming drop party callback routine. */
class NdisProtocolClIncomingDropParty extends NdisCallbackRoutine {
  NdisProtocolClIncomingDropParty() {
    callbackType.getName().matches("PROTOCOL_CL_INCOMING_DROP_PARTY")
  }
}

/** A NDIS protocol call manager make call complete callback routine. */
class NdisProtocolClMakeCallComplete extends NdisCallbackRoutine {
  NdisProtocolClMakeCallComplete() {
    callbackType.getName().matches("PROTOCOL_CL_MAKE_CALL_COMPLETE")
  }
}

/** A NDIS protocol call manager modify call QoS complete callback routine. */
class NdisProtocolClModifyCallQosComplete extends NdisCallbackRoutine {
  NdisProtocolClModifyCallQosComplete() {
    callbackType.getName().matches("PROTOCOL_CL_MODIFY_CALL_QOS_COMPLETE")
  }
}

/** A NDIS protocol call manager notify close AF callback routine. */
class NdisProtocolClNotifyCloseAf extends NdisCallbackRoutine {
  NdisProtocolClNotifyCloseAf() { callbackType.getName().matches("PROTOCOL_CL_NOTIFY_CLOSE_AF") }
}

/** A NDIS protocol call manager open AF complete callback routine. */
class NdisProtocolClOpenAfComplete extends NdisCallbackRoutine {
  NdisProtocolClOpenAfComplete() { callbackType.getName().matches("PROTOCOL_CL_OPEN_AF_COMPLETE") }
}

/** A NDIS protocol call manager open AF complete ex callback routine. */
class NdisProtocolClOpenAfCompleteEx extends NdisCallbackRoutine {
  NdisProtocolClOpenAfCompleteEx() {
    callbackType.getName().matches("PROTOCOL_CL_OPEN_AF_COMPLETE_EX")
  }
}

/** A NDIS protocol call manager register SAP complete callback routine. */
class NdisProtocolClRegisterSapComplete extends NdisCallbackRoutine {
  NdisProtocolClRegisterSapComplete() {
    callbackType.getName().matches("PROTOCOL_CL_REGISTER_SAP_COMPLETE")
  }
}

/** A NDIS protocol connection manager activate VC complete callback routine. */
class NdisProtocolCmActivateVcComplete extends NdisCallbackRoutine {
  NdisProtocolCmActivateVcComplete() {
    callbackType.getName().matches("PROTOCOL_CM_ACTIVATE_VC_COMPLETE")
  }
}

/** A NDIS protocol connection manager add party callback routine. */
class NdisProtocolCmAddParty extends NdisCallbackRoutine {
  NdisProtocolCmAddParty() { callbackType.getName().matches("PROTOCOL_CM_ADD_PARTY") }
}

/** A NDIS protocol connection manager close AF callback routine. */
class NdisProtocolCmCloseAf extends NdisCallbackRoutine {
  NdisProtocolCmCloseAf() { callbackType.getName().matches("PROTOCOL_CM_CLOSE_AF") }
}

/** A NDIS protocol connection manager close call callback routine. */
class NdisProtocolCmCloseCall extends NdisCallbackRoutine {
  NdisProtocolCmCloseCall() { callbackType.getName().matches("PROTOCOL_CM_CLOSE_CALL") }
}

/** A NDIS protocol connection manager deactivate VC complete callback routine. */
class NdisProtocolCmDeactivateVcComplete extends NdisCallbackRoutine {
  NdisProtocolCmDeactivateVcComplete() {
    callbackType.getName().matches("PROTOCOL_CM_DEACTIVATE_VC_COMPLETE")
  }
}

/** A NDIS protocol connection manager deregister SAP callback routine. */
class NdisProtocolCmDeregisterSap extends NdisCallbackRoutine {
  NdisProtocolCmDeregisterSap() { callbackType.getName().matches("PROTOCOL_CM_DEREGISTER_SAP") }
}

/** A NDIS protocol connection manager drop party callback routine. */
class NdisProtocolCmDropParty extends NdisCallbackRoutine {
  NdisProtocolCmDropParty() { callbackType.getName().matches("PROTOCOL_CM_DROP_PARTY") }
}

/** A NDIS protocol connection manager incoming call complete callback routine. */
class NdisProtocolCmIncomingCallComplete extends NdisCallbackRoutine {
  NdisProtocolCmIncomingCallComplete() {
    callbackType.getName().matches("PROTOCOL_CM_INCOMING_CALL_COMPLETE")
  }
}

/** A NDIS protocol connection manager make call callback routine. */
class NdisProtocolCmMakeCall extends NdisCallbackRoutine {
  NdisProtocolCmMakeCall() { callbackType.getName().matches("PROTOCOL_CM_MAKE_CALL") }
}

/** A NDIS protocol connection manager modify QoS call callback routine. */
class NdisProtocolCmModifyQosCall extends NdisCallbackRoutine {
  NdisProtocolCmModifyQosCall() { callbackType.getName().matches("PROTOCOL_CM_MODIFY_QOS_CALL") }
}

/** A NDIS protocol connection manager notify close AF complete callback routine. */
class NdisProtocolCmNotifyCloseAfComplete extends NdisCallbackRoutine {
  NdisProtocolCmNotifyCloseAfComplete() {
    callbackType.getName().matches("PROTOCOL_CM_NOTIFY_CLOSE_AF_COMPLETE")
  }
}

/** A NDIS protocol connection manager open AF callback routine. */
class NdisProtocolCmOpenAf extends NdisCallbackRoutine {
  NdisProtocolCmOpenAf() { callbackType.getName().matches("PROTOCOL_CM_OPEN_AF") }
}

/** A NDIS protocol connection manager register SAP callback routine. */
class NdisProtocolCmRegSap extends NdisCallbackRoutine {
  NdisProtocolCmRegSap() { callbackType.getName().matches("PROTOCOL_CM_REG_SAP") }
}

/** A NDIS protocol CO AF register notify callback routine. */
class NdisProtocolCoAfRegisterNotify extends NdisCallbackRoutine {
  NdisProtocolCoAfRegisterNotify() {
    callbackType.getName().matches("PROTCOL_CO_AF_REGISTER_NOTIFY")
  }
}

/** A NDIS protocol CO create VC callback routine. */
class NdisProtocolCoCreateVc extends NdisCallbackRoutine {
  NdisProtocolCoCreateVc() { callbackType.getName().matches("PROTOCOL_CO_CREATE_VC") }
}

/** A NDIS protocol CO delete VC callback routine. */
class NdisProtocolCoDeleteVc extends NdisCallbackRoutine {
  NdisProtocolCoDeleteVc() { callbackType.getName().matches("PROTOCOL_CO_DELETE_VC") }
}

/** A NDIS protocol CO OID request callback routine. */
class NdisProtocolCoOidRequest extends NdisCallbackRoutine {
  NdisProtocolCoOidRequest() { callbackType.getName().matches("PROTOCOL_CO_OID_REQUEST") }
}

/** A NDIS protocol CO OID request complete callback routine. */
class NdisProtocolCoOidRequestComplete extends NdisCallbackRoutine {
  NdisProtocolCoOidRequestComplete() {
    callbackType.getName().matches("PROTOCOL_CO_OID_REQUEST_COMPLETE")
  }
}

/** A NDIS protocol CO receive net buffer lists callback routine. */
class NdisProtocolCoReceiveNetBufferLists extends NdisCallbackRoutine {
  NdisProtocolCoReceiveNetBufferLists() {
    callbackType.getName().matches("PROTOCOL_CO_RECEIVE_NET_BUFFER_LISTS")
  }
}

/** A NDIS protocol CO send net buffer lists complete callback routine. */
class NdisProtocolCoSendNetBufferListsComplete extends NdisCallbackRoutine {
  NdisProtocolCoSendNetBufferListsComplete() {
    callbackType.getName().matches("PROTOCOL_CO_SEND_NET_BUFFER_LISTS_COMPLETE")
  }
}

/** A NDIS protocol CO status ex callback routine. */
class NdisProtocolCoStatusEx extends NdisCallbackRoutine {
  NdisProtocolCoStatusEx() { callbackType.getName().matches("PROTOCOL_CO_STATUS_EX") }
}
