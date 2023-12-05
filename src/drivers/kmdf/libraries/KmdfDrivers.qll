// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
import cpp

/**
 * A KMDF Typedef type. This class is incomplete.  It is used to represent a TypedefType in the KMDF library.
 */
class KmdfRoleTypeType extends TypedefType {
  /* Callbacks */
  KmdfRoleTypeType() {

    this.getName().matches("EVT_WDF_CHILD_LIST_CREATE_DEVICE") or
    this.getName().matches("EVT_WDF_CHILD_LIST_SCAN_FOR_CHILDREN") or
    this.getName().matches("EVT_WDF_CHILD_LIST_IDENTIFICATION_DESCRIPTION_COPY") or
    this.getName().matches("EVT_WDF_CHILD_LIST_IDENTIFICATION_DESCRIPTION_DUPLICATE") or
    this.getName().matches("EVT_WDF_CHILD_LIST_IDENTIFICATION_DESCRIPTION_COMPARE") or
    this.getName().matches("EVT_WDF_CHILD_LIST_IDENTIFICATION_DESCRIPTION_CLEANUP") or
    this.getName().matches("EVT_WDF_CHILD_LIST_ADDRESS_DESCRIPTION_COPY") or
    this.getName().matches("EVT_WDF_CHILD_LIST_ADDRESS_DESCRIPTION_DUPLICATE") or
    this.getName().matches("EVT_WDF_CHILD_LIST_ADDRESS_DESCRIPTION_CLEANUP") or
    this.getName().matches("EVT_WDF_CHILD_LIST_DEVICE_REENUMERATED") or
    this.getName().matches("EVT_WDF_DEVICE_SHUTDOWN_NOTIFICATION") or
    this.getName().matches("EVT_WDF_DEVICE_FILE_CREATE") or
    this.getName().matches("EVT_WDF_FILE_CLOSE") or
    this.getName().matches("EVT_WDF_FILE_CLEANUP") or
    this.getName().matches("EVT_WDF_DEVICE_PNP_STATE_CHANGE_NOTIFICATION") or
    this.getName().matches("EVT_WDF_DEVICE_POWER_STATE_CHANGE_NOTIFICATION") or
    this.getName().matches("EVT_WDF_DEVICE_POWER_POLICY_STATE_CHANGE_NOTIFICATION") or
    this.getName().matches("EVT_WDF_DEVICE_D0_ENTRY") or
    this.getName().matches("EVT_WDF_DEVICE_D0_ENTRY_POST_INTERRUPTS_ENABLED") or
    this.getName().matches("EVT_WDF_DEVICE_D0_ENTRY_POST_HARDWARE_ENABLED") or
    this.getName().matches("EVT_WDF_DEVICE_D0_EXIT") or
    this.getName().matches("EVT_WDF_DEVICE_D0_EXIT_PRE_INTERRUPTS_DISABLED") or
    this.getName().matches("EVT_WDF_DEVICE_D0_EXIT_PRE_HARDWARE_DISABLED") or
    this.getName().matches("EVT_WDF_DEVICE_PREPARE_HARDWARE") or
    this.getName().matches("EVT_WDF_DEVICE_RELEASE_HARDWARE") or
    this.getName().matches("EVT_WDF_DEVICE_SELF_MANAGED_IO_CLEANUP") or
    this.getName().matches("EVT_WDF_DEVICE_SELF_MANAGED_IO_FLUSH") or
    this.getName().matches("EVT_WDF_DEVICE_SELF_MANAGED_IO_INIT") or
    this.getName().matches("EVT_WDF_DEVICE_SELF_MANAGED_IO_SUSPEND") or
    this.getName().matches("EVT_WDF_DEVICE_SELF_MANAGED_IO_RESTART") or
    this.getName().matches("EVT_WDF_DEVICE_QUERY_STOP") or
    this.getName().matches("EVT_WDF_DEVICE_QUERY_REMOVE") or
    this.getName().matches("EVT_WDF_DEVICE_SURPRISE_REMOVAL") or
    this.getName().matches("EVT_WDF_DEVICE_USAGE_NOTIFICATION") or
    this.getName().matches("EVT_WDF_DEVICE_USAGE_NOTIFICATION_EX") or
    this.getName().matches("EVT_WDF_DEVICE_RELATIONS_QUERY") or
    this.getName().matches("EVT_WDF_DEVICE_ARM_WAKE_FROM_S0") or
    this.getName().matches("EVT_WDF_DEVICE_ARM_WAKE_FROM_SX") or
    this.getName().matches("EVT_WDF_DEVICE_ARM_WAKE_FROM_SX_WITH_REASON") or
    this.getName().matches("EVT_WDF_DEVICE_DISARM_WAKE_FROM_S0") or
    this.getName().matches("EVT_WDF_DEVICE_DISARM_WAKE_FROM_SX") or
    this.getName().matches("EVT_WDF_DEVICE_WAKE_FROM_S0_TRIGGERED") or
    this.getName().matches("EVT_WDF_DEVICE_WAKE_FROM_SX_TRIGGERED") or
    this.getName().matches("EVT_WDFDEVICE_WDM_IRP_PREPROCESS") or
    this.getName().matches("EVT_WDFDEVICE_WDM_IRP_DISPATCH") or
    this.getName().matches("EVT_WDF_IO_IN_CALLER_CONTEXT") or
    this.getName().matches("EVT_WDFDEVICE_WDM_POST_PO_FX_REGISTER_DEVICE") or
    this.getName().matches("EVT_WDFDEVICE_WDM_PRE_PO_FX_UNREGISTER_DEVICE") or
    this.getName().matches("EVT_WDF_DMA_ENABLER_FILL") or
    this.getName().matches("EVT_WDF_DMA_ENABLER_FLUSH") or
    this.getName().matches("EVT_WDF_DMA_ENABLER_ENABLE") or
    this.getName().matches("EVT_WDF_DMA_ENABLER_DISABLE") or
    this.getName().matches("EVT_WDF_DMA_ENABLER_SELFMANAGED_IO_START") or
    this.getName().matches("EVT_WDF_DMA_ENABLER_SELFMANAGED_IO_STOP") or
    this.getName().matches("EVT_WDF_PROGRAM_DMA") or
    this.getName().matches("EVT_WDF_DMA_TRANSACTION_CONFIGURE_DMA_CHANNEL") or
    this.getName().matches("EVT_WDF_DMA_TRANSACTION_DMA_TRANSFER_COMPLETE") or
    this.getName().matches("EVT_WDF_RESERVE_DMA") or
    this.getName().matches("EVT_WDF_DPC") or
    this.getName().matches("EVT_WDF_DRIVER_DEVICE_ADD") or
    this.getName().matches("EVT_WDF_DRIVER_UNLOAD") or
    this.getName().matches("EVT_WDF_TRACE_CALLBACK") or
    this.getName().matches("EVT_WDF_DEVICE_FILTER_RESOURCE_REQUIREMENTS") or
    this.getName().matches("EVT_WDF_DEVICE_REMOVE_ADDED_RESOURCES") or
    this.getName().matches("EVT_WDF_INTERRUPT_ISR") or
    this.getName().matches("EVT_WDF_INTERRUPT_SYNCHRONIZE") or
    this.getName().matches("EVT_WDF_INTERRUPT_DPC") or
    this.getName().matches("EVT_WDF_INTERRUPT_WORKITEM") or
    this.getName().matches("EVT_WDF_INTERRUPT_ENABLE") or
    this.getName().matches("EVT_WDF_INTERRUPT_DISABLE") or
    this.getName().matches("EVT_WDF_IO_QUEUE_IO_DEFAULT") or
    this.getName().matches("EVT_WDF_IO_QUEUE_IO_STOP") or
    this.getName().matches("EVT_WDF_IO_QUEUE_IO_RESUME") or
    this.getName().matches("EVT_WDF_IO_QUEUE_IO_READ") or
    this.getName().matches("EVT_WDF_IO_QUEUE_IO_WRITE") or
    this.getName().matches("EVT_WDF_IO_QUEUE_IO_DEVICE_CONTROL") or
    this.getName().matches("EVT_WDF_IO_QUEUE_IO_INTERNAL_DEVICE_CONTROL") or
    this.getName().matches("EVT_WDF_IO_QUEUE_IO_CANCELED_ON_QUEUE") or
    this.getName().matches("EVT_WDF_IO_QUEUE_STATE") or
    this.getName().matches("EVT_WDF_IO_ALLOCATE_RESOURCES_FOR_RESERVED_REQUEST") or
    this.getName().matches("EVT_WDF_IO_ALLOCATE_REQUEST_RESOURCES") or
    this.getName().matches("EVT_WDF_IO_WDM_IRP_FOR_FORWARD_PROGRESS") or
    this.getName().matches("EVT_WDF_IO_TARGET_QUERY_REMOVE") or
    this.getName().matches("EVT_WDF_IO_TARGET_REMOVE_CANCELED") or
    this.getName().matches("EVT_WDF_IO_TARGET_REMOVE_COMPLETE") or
    this.getName().matches("EVT_WDF_%_CONTEXT_CLEANUP%") or
    this.getName().matches("EVT_WDF_%_CONTEXT_DESTROY%") or
    this.getName().matches("EVT_WDF_DEVICE_RESOURCES_QUERY") or
    this.getName().matches("EVT_WDF_DEVICE_RESOURCE_REQUIREMENTS_QUERY") or
    this.getName().matches("EVT_WDF_DEVICE_EJECT") or
    this.getName().matches("EVT_WDF_DEVICE_SET_LOCK") or
    this.getName().matches("EVT_WDF_DEVICE_ENABLE_WAKE_AT_BUS") or
    this.getName().matches("EVT_WDF_DEVICE_DISABLE_WAKE_AT_BUS") or
    this.getName().matches("EVT_WDF_DEVICE_REPORTED_MISSING") or
    this.getName().matches("EVT_WDF_DEVICE_PROCESS_QUERY_INTERFACE_REQUEST") or
    this.getName().matches("EVT_WDF_REQUEST_CANCEL") or
    this.getName().matches("EVT_WDF_REQUEST_COMPLETION_ROUTINE") or
    this.getName().matches("EVT_WDF_TIMER") or
    this.getName().matches("EVT_WDF_USB_READER_COMPLETION_ROUTINE") or
    this.getName().matches("EVT_WDF_USB_READERS_FAILED") or
    this.getName().matches("EVT_WDF_WMI_INSTANCE_QUERY_INSTANCE") or
    this.getName().matches("EVT_WDF_WMI_INSTANCE_SET_INSTANCE") or
    this.getName().matches("EVT_WDF_WMI_INSTANCE_SET_ITEM") or
    this.getName().matches("EVT_WDF_WMI_INSTANCE_EXECUTE_METHOD") or
    this.getName().matches("EVT_WDF_WMI_PROVIDER_FUNCTION_CONTROL") or
    this.getName().matches("EVT_WDF_WORKITEM") 

  }
}

class KmdfCallbackRoutineTypedef extends KmdfRoleTypeType {
  KmdfCallbackRoutineTypedef() { this.getFile().getBaseName().matches("%wdf%.h") }
}

/* Callbacks */
class KmdfEVTWdfChildListCreateDevice extends KmdfCallbackRoutine {
  KmdfEVTWdfChildListCreateDevice() {
    callbackType.getName().matches("EVT_WDF_CHILD_LIST_CREATE_DEVICE")
  }
}

class KmdfEVTWdfChildListScanForChildren extends KmdfCallbackRoutine {
  KmdfEVTWdfChildListScanForChildren() {
    callbackType.getName().matches("EVT_WDF_CHILD_LIST_SCAN_FOR_CHILDREN")
  }
}

class KmdfEVTWdfChildListIdentificationDescriptionCopy extends KmdfCallbackRoutine {
  KmdfEVTWdfChildListIdentificationDescriptionCopy() {
    callbackType.getName().matches("EVT_WDF_CHILD_LIST_IDENTIFICATION_DESCRIPTION_COPY")
  }
}

class KmdfEVTWdfChildListIdentificationDescriptionDuplicate extends KmdfCallbackRoutine {
  KmdfEVTWdfChildListIdentificationDescriptionDuplicate() {
    callbackType.getName().matches("EVT_WDF_CHILD_LIST_IDENTIFICATION_DESCRIPTION_DUPLICATE")
  }
}

class KmdfEVTWdfChildListIdentificationDescriptionCompare extends KmdfCallbackRoutine {
  KmdfEVTWdfChildListIdentificationDescriptionCompare() {
    callbackType.getName().matches("EVT_WDF_CHILD_LIST_IDENTIFICATION_DESCRIPTION_COMPARE")
  }
}

class KmdfEVTWdfChildListIdentificationDescriptionCleanup extends KmdfCallbackRoutine {
  KmdfEVTWdfChildListIdentificationDescriptionCleanup() {
    callbackType.getName().matches("EVT_WDF_CHILD_LIST_IDENTIFICATION_DESCRIPTION_CLEANUP")
  }
}

class KmdfEVTWdfChildListAddressDescriptionCopy extends KmdfCallbackRoutine {
  KmdfEVTWdfChildListAddressDescriptionCopy() {
    callbackType.getName().matches("EVT_WDF_CHILD_LIST_ADDRESS_DESCRIPTION_COPY")
  }
}

class KmdfEVTWdfChildListAddressDescriptionDuplicate extends KmdfCallbackRoutine {
  KmdfEVTWdfChildListAddressDescriptionDuplicate() {
    callbackType.getName().matches("EVT_WDF_CHILD_LIST_ADDRESS_DESCRIPTION_DUPLICATE")
  }
}

class KmdfEVTWdfChildListAddressDescriptionCleanup extends KmdfCallbackRoutine {
  KmdfEVTWdfChildListAddressDescriptionCleanup() {
    callbackType.getName().matches("EVT_WDF_CHILD_LIST_ADDRESS_DESCRIPTION_CLEANUP")
  }
}

class KmdfEVTWdfChildListDeviceReenumerated extends KmdfCallbackRoutine {
  KmdfEVTWdfChildListDeviceReenumerated() {
    callbackType.getName().matches("EVT_WDF_CHILD_LIST_DEVICE_REENUMERATED")
  }
}

class KmdfEVTWdfDeviceShutdownNotification extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceShutdownNotification() {
    callbackType.getName().matches("EVT_WDF_DEVICE_SHUTDOWN_NOTIFICATION")
  }
}

class KmdfEVTWdfDeviceFileCreate extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceFileCreate() { callbackType.getName().matches("EVT_WDF_DEVICE_FILE_CREATE") }
}

class KmdfEVTWdfFileClose extends KmdfCallbackRoutine {
  KmdfEVTWdfFileClose() { callbackType.getName().matches("EVT_WDF_FILE_CLOSE") }
}

class KmdfEVTWdfFileCleanup extends KmdfCallbackRoutine {
  KmdfEVTWdfFileCleanup() { callbackType.getName().matches("EVT_WDF_FILE_CLEANUP") }
}

class KmdfEVTWdfDevicePnpStateChangeNotification extends KmdfCallbackRoutine {
  KmdfEVTWdfDevicePnpStateChangeNotification() {
    callbackType.getName().matches("EVT_WDF_DEVICE_PNP_STATE_CHANGE_NOTIFICATION")
  }
}

class KmdfEVTWdfDevicePowerStateChangeNotification extends KmdfCallbackRoutine {
  KmdfEVTWdfDevicePowerStateChangeNotification() {
    callbackType.getName().matches("EVT_WDF_DEVICE_POWER_STATE_CHANGE_NOTIFICATION")
  }
}

class KmdfEVTWdfDevicePowerPolicyStateChangeNotification extends KmdfCallbackRoutine {
  KmdfEVTWdfDevicePowerPolicyStateChangeNotification() {
    callbackType.getName().matches("EVT_WDF_DEVICE_POWER_POLICY_STATE_CHANGE_NOTIFICATION")
  }
}

class KmdfEVTWdfDeviceD0Entry extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceD0Entry() { callbackType.getName().matches("EVT_WDF_DEVICE_D0_ENTRY") }
}

class KmdfEVTWdfDeviceD0EntryPostInterruptsEnabled extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceD0EntryPostInterruptsEnabled() {
    callbackType.getName().matches("EVT_WDF_DEVICE_D0_ENTRY_POST_INTERRUPTS_ENABLED")
  }
}

class KmdfEVTWdfDeviceD0EntryPostHardwareEnabled extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceD0EntryPostHardwareEnabled() {
    callbackType.getName().matches("EVT_WDF_DEVICE_D0_ENTRY_POST_HARDWARE_ENABLED")
  }
}

class KmdfEVTWdfDeviceD0Exit extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceD0Exit() { callbackType.getName().matches("EVT_WDF_DEVICE_D0_EXIT") }
}

class KmdfEVTWdfDeviceD0ExitPreInterruptsDisabled extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceD0ExitPreInterruptsDisabled() {
    callbackType.getName().matches("EVT_WDF_DEVICE_D0_EXIT_PRE_INTERRUPTS_DISABLED")
  }
}

class KmdfEVTWdfDeviceD0ExitPreHardwareDisabled extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceD0ExitPreHardwareDisabled() {
    callbackType.getName().matches("EVT_WDF_DEVICE_D0_EXIT_PRE_HARDWARE_DISABLED")
  }
}

class KmdfEVTWdfDevicePrepareHardware extends KmdfCallbackRoutine {
  KmdfEVTWdfDevicePrepareHardware() {
    callbackType.getName().matches("EVT_WDF_DEVICE_PREPARE_HARDWARE")
  }
}

class KmdfEVTWdfDeviceReleaseHardware extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceReleaseHardware() {
    callbackType.getName().matches("EVT_WDF_DEVICE_RELEASE_HARDWARE")
  }
}

class KmdfEVTWdfDeviceSelfManagedIoCleanup extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceSelfManagedIoCleanup() {
    callbackType.getName().matches("EVT_WDF_DEVICE_SELF_MANAGED_IO_CLEANUP")
  }
}

class KmdfEVTWdfDeviceSelfManagedIoFlush extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceSelfManagedIoFlush() {
    callbackType.getName().matches("EVT_WDF_DEVICE_SELF_MANAGED_IO_FLUSH")
  }
}

class KmdfEVTWdfDeviceSelfManagedIoInit extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceSelfManagedIoInit() {
    callbackType.getName().matches("EVT_WDF_DEVICE_SELF_MANAGED_IO_INIT")
  }
}

class KmdfEVTWdfDeviceSelfManagedIoSuspend extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceSelfManagedIoSuspend() {
    callbackType.getName().matches("EVT_WDF_DEVICE_SELF_MANAGED_IO_SUSPEND")
  }
}

class KmdfEVTWdfDeviceSelfManagedIoRestart extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceSelfManagedIoRestart() {
    callbackType.getName().matches("EVT_WDF_DEVICE_SELF_MANAGED_IO_RESTART")
  }
}

class KmdfEVTWdfDeviceQueryStop extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceQueryStop() { callbackType.getName().matches("EVT_WDF_DEVICE_QUERY_STOP") }
}

class KmdfEVTWdfDeviceQueryRemove extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceQueryRemove() { callbackType.getName().matches("EVT_WDF_DEVICE_QUERY_REMOVE") }
}

class KmdfEVTWdfDeviceSurpriseRemoval extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceSurpriseRemoval() {
    callbackType.getName().matches("EVT_WDF_DEVICE_SURPRISE_REMOVAL")
  }
}

class KmdfEVTWdfDeviceUsageNotification extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceUsageNotification() {
    callbackType.getName().matches("EVT_WDF_DEVICE_USAGE_NOTIFICATION")
  }
}

class KmdfEVTWdfDeviceUsageNotificationEx extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceUsageNotificationEx() {
    callbackType.getName().matches("EVT_WDF_DEVICE_USAGE_NOTIFICATION_EX")
  }
}

class KmdfEVTWdfDeviceRelationsQuery extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceRelationsQuery() {
    callbackType.getName().matches("EVT_WDF_DEVICE_RELATIONS_QUERY")
  }
}

class KmdfEVTWdfDeviceArmWakeFromS0 extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceArmWakeFromS0() {
    callbackType.getName().matches("EVT_WDF_DEVICE_ARM_WAKE_FROM_S0")
  }
}

class KmdfEVTWdfDeviceArmWakeFromSx extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceArmWakeFromSx() {
    callbackType.getName().matches("EVT_WDF_DEVICE_ARM_WAKE_FROM_SX")
  }
}

class KmdfEVTWdfDeviceArmWakeFromSxWithReason extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceArmWakeFromSxWithReason() {
    callbackType.getName().matches("EVT_WDF_DEVICE_ARM_WAKE_FROM_SX_WITH_REASON")
  }
}

class KmdfEVTWdfDeviceDisarmWakeFromS0 extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceDisarmWakeFromS0() {
    callbackType.getName().matches("EVT_WDF_DEVICE_DISARM_WAKE_FROM_S0")
  }
}

class KmdfEVTWdfDeviceDisarmWakeFromSx extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceDisarmWakeFromSx() {
    callbackType.getName().matches("EVT_WDF_DEVICE_DISARM_WAKE_FROM_SX")
  }
}

class KmdfEVTWdfDeviceWakeFromS0Triggered extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceWakeFromS0Triggered() {
    callbackType.getName().matches("EVT_WDF_DEVICE_WAKE_FROM_S0_TRIGGERED")
  }
}

class KmdfEVTWdfDeviceWakeFromSxTriggered extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceWakeFromSxTriggered() {
    callbackType.getName().matches("EVT_WDF_DEVICE_WAKE_FROM_SX_TRIGGERED")
  }
}

class KmdfEVTWdfdeviceWdmIrpPreprocess extends KmdfCallbackRoutine {
  KmdfEVTWdfdeviceWdmIrpPreprocess() {
    callbackType.getName().matches("EVT_WDFDEVICE_WDM_IRP_PREPROCESS")
  }
}

class KmdfEVTWdfdeviceWdmIrpDispatch extends KmdfCallbackRoutine {
  KmdfEVTWdfdeviceWdmIrpDispatch() {
    callbackType.getName().matches("EVT_WDFDEVICE_WDM_IRP_DISPATCH")
  }
}

class KmdfEVTWdfIoInCallerContext extends KmdfCallbackRoutine {
  KmdfEVTWdfIoInCallerContext() { callbackType.getName().matches("EVT_WDF_IO_IN_CALLER_CONTEXT") }
}

class KmdfEVTWdfdeviceWdmPostPoFxRegisterDevice extends KmdfCallbackRoutine {
  KmdfEVTWdfdeviceWdmPostPoFxRegisterDevice() {
    callbackType.getName().matches("EVT_WDFDEVICE_WDM_POST_PO_FX_REGISTER_DEVICE")
  }
}

class KmdfEVTWdfdeviceWdmPrePoFxUnregisterDevice extends KmdfCallbackRoutine {
  KmdfEVTWdfdeviceWdmPrePoFxUnregisterDevice() {
    callbackType.getName().matches("EVT_WDFDEVICE_WDM_PRE_PO_FX_UNREGISTER_DEVICE")
  }
}

class KmdfEVTWdfDmaEnablerFill extends KmdfCallbackRoutine {
  KmdfEVTWdfDmaEnablerFill() { callbackType.getName().matches("EVT_WDF_DMA_ENABLER_FILL") }
}

class KmdfEVTWdfDmaEnablerFlush extends KmdfCallbackRoutine {
  KmdfEVTWdfDmaEnablerFlush() { callbackType.getName().matches("EVT_WDF_DMA_ENABLER_FLUSH") }
}

class KmdfEVTWdfDmaEnablerEnable extends KmdfCallbackRoutine {
  KmdfEVTWdfDmaEnablerEnable() { callbackType.getName().matches("EVT_WDF_DMA_ENABLER_ENABLE") }
}

class KmdfEVTWdfDmaEnablerDisable extends KmdfCallbackRoutine {
  KmdfEVTWdfDmaEnablerDisable() { callbackType.getName().matches("EVT_WDF_DMA_ENABLER_DISABLE") }
}

class KmdfEVTWdfDmaEnablerSelfmanagedIoStart extends KmdfCallbackRoutine {
  KmdfEVTWdfDmaEnablerSelfmanagedIoStart() {
    callbackType.getName().matches("EVT_WDF_DMA_ENABLER_SELFMANAGED_IO_START")
  }
}

class KmdfEVTWdfDmaEnablerSelfmanagedIoStop extends KmdfCallbackRoutine {
  KmdfEVTWdfDmaEnablerSelfmanagedIoStop() {
    callbackType.getName().matches("EVT_WDF_DMA_ENABLER_SELFMANAGED_IO_STOP")
  }
}

class KmdfEVTWdfProgramDma extends KmdfCallbackRoutine {
  KmdfEVTWdfProgramDma() { callbackType.getName().matches("EVT_WDF_PROGRAM_DMA") }
}

class KmdfEVTWdfDmaTransactionConfigureDmaChannel extends KmdfCallbackRoutine {
  KmdfEVTWdfDmaTransactionConfigureDmaChannel() {
    callbackType.getName().matches("EVT_WDF_DMA_TRANSACTION_CONFIGURE_DMA_CHANNEL")
  }
}

class KmdfEVTWdfDmaTransactionDmaTransferComplete extends KmdfCallbackRoutine {
  KmdfEVTWdfDmaTransactionDmaTransferComplete() {
    callbackType.getName().matches("EVT_WDF_DMA_TRANSACTION_DMA_TRANSFER_COMPLETE")
  }
}

class KmdfEVTWdfReserveDma extends KmdfCallbackRoutine {
  KmdfEVTWdfReserveDma() { callbackType.getName().matches("EVT_WDF_RESERVE_DMA") }
}

class KmdfEVTWdfDpc extends KmdfCallbackRoutine {
  KmdfEVTWdfDpc() { callbackType.getName().matches("EVT_WDF_DPC") }
}

class KmdfEVTWdfDriverDeviceAdd extends KmdfCallbackRoutine {
  KmdfEVTWdfDriverDeviceAdd() { callbackType.getName().matches("EVT_WDF_DRIVER_DEVICE_ADD") }
}

class KmdfEVTWdfDriverUnload extends KmdfCallbackRoutine {
  KmdfEVTWdfDriverUnload() { callbackType.getName().matches("EVT_WDF_DRIVER_UNLOAD") }
}

class KmdfEVTWdfTraceCallback extends KmdfCallbackRoutine {
  KmdfEVTWdfTraceCallback() { callbackType.getName().matches("EVT_WDF_TRACE_CALLBACK") }
}

class KmdfEVTWdfDeviceFilterResourceRequirements extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceFilterResourceRequirements() {
    callbackType.getName().matches("EVT_WDF_DEVICE_FILTER_RESOURCE_REQUIREMENTS")
  }
}

class KmdfEVTWdfDeviceRemoveAddedResources extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceRemoveAddedResources() {
    callbackType.getName().matches("EVT_WDF_DEVICE_REMOVE_ADDED_RESOURCES")
  }
}

class KmdfEVTWdfInterruptIsr extends KmdfCallbackRoutine {
  KmdfEVTWdfInterruptIsr() { callbackType.getName().matches("EVT_WDF_INTERRUPT_ISR") }
}

class KmdfEVTWdfInterruptSynchronize extends KmdfCallbackRoutine {
  KmdfEVTWdfInterruptSynchronize() {
    callbackType.getName().matches("EVT_WDF_INTERRUPT_SYNCHRONIZE")
  }
}

class KmdfEVTWdfInterruptDpc extends KmdfCallbackRoutine {
  KmdfEVTWdfInterruptDpc() { callbackType.getName().matches("EVT_WDF_INTERRUPT_DPC") }
}

class KmdfEVTWdfInterruptWorkitem extends KmdfCallbackRoutine {
  KmdfEVTWdfInterruptWorkitem() { callbackType.getName().matches("EVT_WDF_INTERRUPT_WORKITEM") }
}

class KmdfEVTWdfInterruptEnable extends KmdfCallbackRoutine {
  KmdfEVTWdfInterruptEnable() { callbackType.getName().matches("EVT_WDF_INTERRUPT_ENABLE") }
}

class KmdfEVTWdfInterruptDisable extends KmdfCallbackRoutine {
  KmdfEVTWdfInterruptDisable() { callbackType.getName().matches("EVT_WDF_INTERRUPT_DISABLE") }
}

class KmdfEVTWdfIoQueueIoDefault extends KmdfCallbackRoutine {
  KmdfEVTWdfIoQueueIoDefault() { callbackType.getName().matches("EVT_WDF_IO_QUEUE_IO_DEFAULT") }
}

class KmdfEVTWdfIoQueueIoStop extends KmdfCallbackRoutine {
  KmdfEVTWdfIoQueueIoStop() { callbackType.getName().matches("EVT_WDF_IO_QUEUE_IO_STOP") }
}

class KmdfEVTWdfIoQueueIoResume extends KmdfCallbackRoutine {
  KmdfEVTWdfIoQueueIoResume() { callbackType.getName().matches("EVT_WDF_IO_QUEUE_IO_RESUME") }
}

class KmdfEVTWdfIoQueueIoRead extends KmdfCallbackRoutine {
  KmdfEVTWdfIoQueueIoRead() { callbackType.getName().matches("EVT_WDF_IO_QUEUE_IO_READ") }
}

class KmdfEVTWdfIoQueueIoWrite extends KmdfCallbackRoutine {
  KmdfEVTWdfIoQueueIoWrite() { callbackType.getName().matches("EVT_WDF_IO_QUEUE_IO_WRITE") }
}

class KmdfEVTWdfIoQueueIoDeviceControl extends KmdfCallbackRoutine {
  KmdfEVTWdfIoQueueIoDeviceControl() {
    callbackType.getName().matches("EVT_WDF_IO_QUEUE_IO_DEVICE_CONTROL")
  }
}

class KmdfEVTWdfIoQueueIoInternalDeviceControl extends KmdfCallbackRoutine {
  KmdfEVTWdfIoQueueIoInternalDeviceControl() {
    callbackType.getName().matches("EVT_WDF_IO_QUEUE_IO_INTERNAL_DEVICE_CONTROL")
  }
}

class KmdfEVTWdfIoQueueIoCanceledOnQueue extends KmdfCallbackRoutine {
  KmdfEVTWdfIoQueueIoCanceledOnQueue() {
    callbackType.getName().matches("EVT_WDF_IO_QUEUE_IO_CANCELED_ON_QUEUE")
  }
}

class KmdfEVTWdfIoQueueState extends KmdfCallbackRoutine {
  KmdfEVTWdfIoQueueState() { callbackType.getName().matches("EVT_WDF_IO_QUEUE_STATE") }
}

class KmdfEVTWdfIoAllocateResourcesForReservedRequest extends KmdfCallbackRoutine {
  KmdfEVTWdfIoAllocateResourcesForReservedRequest() {
    callbackType.getName().matches("EVT_WDF_IO_ALLOCATE_RESOURCES_FOR_RESERVED_REQUEST")
  }
}

class KmdfEVTWdfIoAllocateRequestResources extends KmdfCallbackRoutine {
  KmdfEVTWdfIoAllocateRequestResources() {
    callbackType.getName().matches("EVT_WDF_IO_ALLOCATE_REQUEST_RESOURCES")
  }
}

class KmdfEVTWdfIoWdmIrpForForwardProgress extends KmdfCallbackRoutine {
  KmdfEVTWdfIoWdmIrpForForwardProgress() {
    callbackType.getName().matches("EVT_WDF_IO_WDM_IRP_FOR_FORWARD_PROGRESS")
  }
}

class KmdfEVTWdfIoTargetQueryRemove extends KmdfCallbackRoutine {
  KmdfEVTWdfIoTargetQueryRemove() {
    callbackType.getName().matches("EVT_WDF_IO_TARGET_QUERY_REMOVE")
  }
}

class KmdfEVTWdfIoTargetRemoveCanceled extends KmdfCallbackRoutine {
  KmdfEVTWdfIoTargetRemoveCanceled() {
    callbackType.getName().matches("EVT_WDF_IO_TARGET_REMOVE_CANCELED")
  }
}

class KmdfEVTWdfIoTargetRemoveComplete extends KmdfCallbackRoutine {
  KmdfEVTWdfIoTargetRemoveComplete() {
    callbackType.getName().matches("EVT_WDF_IO_TARGET_REMOVE_COMPLETE")
  }
}

class KmdfEVTWdfObjectContextCleanup extends KmdfCallbackRoutine {
  KmdfEVTWdfObjectContextCleanup() {
    callbackType.getName().matches("EVT_WDF_OBJECT_CONTEXT_CLEANUP")
  }
}

class KmdfEVTWdfObjectContextDestroy extends KmdfCallbackRoutine {
  KmdfEVTWdfObjectContextDestroy() {
    callbackType.getName().matches("EVT_WDF_OBJECT_CONTEXT_DESTROY")
  }
}

class KmdfEVTWdfDeviceResourcesQuery extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceResourcesQuery() {
    callbackType.getName().matches("EVT_WDF_DEVICE_RESOURCES_QUERY")
  }
}

class KmdfEVTWdfDeviceResourceRequirementsQuery extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceResourceRequirementsQuery() {
    callbackType.getName().matches("EVT_WDF_DEVICE_RESOURCE_REQUIREMENTS_QUERY")
  }
}

class KmdfEVTWdfDeviceEject extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceEject() { callbackType.getName().matches("EVT_WDF_DEVICE_EJECT") }
}

class KmdfEVTWdfDeviceSetLock extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceSetLock() { callbackType.getName().matches("EVT_WDF_DEVICE_SET_LOCK") }
}

class KmdfEVTWdfDeviceEnableWakeAtBus extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceEnableWakeAtBus() {
    callbackType.getName().matches("EVT_WDF_DEVICE_ENABLE_WAKE_AT_BUS")
  }
}

class KmdfEVTWdfDeviceDisableWakeAtBus extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceDisableWakeAtBus() {
    callbackType.getName().matches("EVT_WDF_DEVICE_DISABLE_WAKE_AT_BUS")
  }
}

class KmdfEVTWdfDeviceReportedMissing extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceReportedMissing() {
    callbackType.getName().matches("EVT_WDF_DEVICE_REPORTED_MISSING")
  }
}

class KmdfEVTWdfDeviceProcessQueryInterfaceRequest extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceProcessQueryInterfaceRequest() {
    callbackType.getName().matches("EVT_WDF_DEVICE_PROCESS_QUERY_INTERFACE_REQUEST")
  }
}

class KmdfEVTWdfRequestCancel extends KmdfCallbackRoutine {
  KmdfEVTWdfRequestCancel() { callbackType.getName().matches("EVT_WDF_REQUEST_CANCEL") }
}

class KmdfEVTWdfRequestCompletionRoutine extends KmdfCallbackRoutine {
  KmdfEVTWdfRequestCompletionRoutine() {
    callbackType.getName().matches("EVT_WDF_REQUEST_COMPLETION_ROUTINE")
  }
}

class KmdfEVTWdfTimer extends KmdfCallbackRoutine {
  KmdfEVTWdfTimer() { callbackType.getName().matches("EVT_WDF_TIMER") }
}

class KmdfEVTWdfUsbReaderCompletionRoutine extends KmdfCallbackRoutine {
  KmdfEVTWdfUsbReaderCompletionRoutine() {
    callbackType.getName().matches("EVT_WDF_USB_READER_COMPLETION_ROUTINE")
  }
}

class KmdfEVTWdfUsbReadersFailed extends KmdfCallbackRoutine {
  KmdfEVTWdfUsbReadersFailed() { callbackType.getName().matches("EVT_WDF_USB_READERS_FAILED") }
}

class KmdfEVTWdfWmiInstanceQueryInstance extends KmdfCallbackRoutine {
  KmdfEVTWdfWmiInstanceQueryInstance() {
    callbackType.getName().matches("EVT_WDF_WMI_INSTANCE_QUERY_INSTANCE")
  }
}

class KmdfEVTWdfWmiInstanceSetInstance extends KmdfCallbackRoutine {
  KmdfEVTWdfWmiInstanceSetInstance() {
    callbackType.getName().matches("EVT_WDF_WMI_INSTANCE_SET_INSTANCE")
  }
}

class KmdfEVTWdfWmiInstanceSetItem extends KmdfCallbackRoutine {
  KmdfEVTWdfWmiInstanceSetItem() { callbackType.getName().matches("EVT_WDF_WMI_INSTANCE_SET_ITEM") }
}

class KmdfEVTWdfWmiInstanceExecuteMethod extends KmdfCallbackRoutine {
  KmdfEVTWdfWmiInstanceExecuteMethod() {
    callbackType.getName().matches("EVT_WDF_WMI_INSTANCE_EXECUTE_METHOD")
  }
}

class KmdfEVTWdfWmiProviderFunctionControl extends KmdfCallbackRoutine {
  KmdfEVTWdfWmiProviderFunctionControl() {
    callbackType.getName().matches("EVT_WDF_WMI_PROVIDER_FUNCTION_CONTROL")
  }
}

class KmdfEVTWdfWorkitem extends KmdfCallbackRoutine {
  KmdfEVTWdfWorkitem() { callbackType.getName().matches("EVT_WDF_WORKITEM") }
}

/**
 * A KMDF callback routine, defined by having a typedef in its definition
 * that matches the standard KMDF callbacks.
 */
class KmdfCallbackRoutine extends Function {
  /** The typedef representing what callback this is. */
  KmdfRoleTypeType callbackType;

  KmdfCallbackRoutine() {
    exists(FunctionDeclarationEntry fde |
      fde.getFunction() = this and
      fde.getTypedefType() = callbackType and
      fde.getFile().getAnIncludedFile().getBaseName().matches("%wdf.h")
    )
  }
}

/** The DeviceAdd callback.  Its callback typedef is "EVT_WDF_DRIVER_DEVICE_ADD". */
class KmdfEvtDriverDeviceAdd extends KmdfCallbackRoutine {
  KmdfEvtDriverDeviceAdd() { callbackType.getName().matches("EVT_WDF_DRIVER_DEVICE_ADD") }
}

/**
 * A KMDF Function. This class is incomplete.  It is used to represent a Function in the KMDF library.
 */
class KmdfFunc extends Function {
  KmdfFunc() { this.getFile().getBaseName().matches("wdf%.h") }
}

/**
 * A KMDF Struct. This class is incomplete.  It is used to represent a Struct in the KMDF library.
 */
class KmdfStruct extends Struct {
  KmdfStruct() { this.getFile().getBaseName().matches("wdf%.h") }
}

/* KMDF Structs */
class KmdfWDFPowerRoutineTimedOutData extends KmdfStruct {
  KmdfWDFPowerRoutineTimedOutData() { this.getName().matches("_WDF_POWER_ROUTINE_TIMED_OUT_DATA") }
}

class KmdfWDFRequestFatalErrorInformationLengthMismatchData extends KmdfStruct {
  KmdfWDFRequestFatalErrorInformationLengthMismatchData() {
    this.getName().matches("_WDF_REQUEST_FATAL_ERROR_INFORMATION_LENGTH_MISMATCH_DATA")
  }
}

class KmdfWDFQueueFatalErrorData extends KmdfStruct {
  KmdfWDFQueueFatalErrorData() { this.getName().matches("_WDF_QUEUE_FATAL_ERROR_DATA") }
}

class KmdfWDFChildIdentificationDescriptionHeader extends KmdfStruct {
  KmdfWDFChildIdentificationDescriptionHeader() {
    this.getName().matches("_WDF_CHILD_IDENTIFICATION_DESCRIPTION_HEADER")
  }
}

class KmdfWDFChildAddressDescriptionHeader extends KmdfStruct {
  KmdfWDFChildAddressDescriptionHeader() {
    this.getName().matches("_WDF_CHILD_ADDRESS_DESCRIPTION_HEADER")
  }
}

class KmdfWDFChildRetrieveInfo extends KmdfStruct {
  KmdfWDFChildRetrieveInfo() { this.getName().matches("_WDF_CHILD_RETRIEVE_INFO") }
}

class KmdfWDFChildListConfig extends KmdfStruct {
  KmdfWDFChildListConfig() { this.getName().matches("_WDF_CHILD_LIST_CONFIG") }
}

class KmdfWDFChildListIterator extends KmdfStruct {
  KmdfWDFChildListIterator() { this.getName().matches("_WDF_CHILD_LIST_ITERATOR") }
}

class KmdfWDFCommonBufferConfig extends KmdfStruct {
  KmdfWDFCommonBufferConfig() { this.getName().matches("_WDF_COMMON_BUFFER_CONFIG") }
}

class KmdfWDFTaskSendOptions extends KmdfStruct {
  KmdfWDFTaskSendOptions() { this.getName().matches("_WDF_TASK_SEND_OPTIONS") }
}

class KmdfWDFFileobjectConfig extends KmdfStruct {
  KmdfWDFFileobjectConfig() { this.getName().matches("_WDF_FILEOBJECT_CONFIG") }
}

class KmdfWDFDevicePnpNotificationData extends KmdfStruct {
  KmdfWDFDevicePnpNotificationData() { this.getName().matches("_WDF_DEVICE_PNP_NOTIFICATION_DATA") }
}

class KmdfWDFDevicePowerNotificationData extends KmdfStruct {
  KmdfWDFDevicePowerNotificationData() {
    this.getName().matches("_WDF_DEVICE_POWER_NOTIFICATION_DATA")
  }
}

class KmdfWDFDevicePowerPolicyNotificationData extends KmdfStruct {
  KmdfWDFDevicePowerPolicyNotificationData() {
    this.getName().matches("_WDF_DEVICE_POWER_POLICY_NOTIFICATION_DATA")
  }
}

class KmdfWDFPnppowerEventCallbacks extends KmdfStruct {
  KmdfWDFPnppowerEventCallbacks() { this.getName().matches("_WDF_PNPPOWER_EVENT_CALLBACKS") }
}

class KmdfWDFPowerPolicyEventCallbacks extends KmdfStruct {
  KmdfWDFPowerPolicyEventCallbacks() { this.getName().matches("_WDF_POWER_POLICY_EVENT_CALLBACKS") }
}

class KmdfWDFDevicePowerPolicyIdleSettings extends KmdfStruct {
  KmdfWDFDevicePowerPolicyIdleSettings() {
    this.getName().matches("_WDF_DEVICE_POWER_POLICY_IDLE_SETTINGS")
  }
}

class KmdfWDFDevicePowerPolicyWakeSettings extends KmdfStruct {
  KmdfWDFDevicePowerPolicyWakeSettings() {
    this.getName().matches("_WDF_DEVICE_POWER_POLICY_WAKE_SETTINGS")
  }
}

class KmdfWDFDeviceState extends KmdfStruct {
  KmdfWDFDeviceState() { this.getName().matches("_WDF_DEVICE_STATE") }
}

class KmdfWDFDevicePnpCapabilities extends KmdfStruct {
  KmdfWDFDevicePnpCapabilities() { this.getName().matches("_WDF_DEVICE_PNP_CAPABILITIES") }
}

class KmdfWDFDevicePowerCapabilities extends KmdfStruct {
  KmdfWDFDevicePowerCapabilities() { this.getName().matches("_WDF_DEVICE_POWER_CAPABILITIES") }
}

class KmdfWDFRemoveLockOptions extends KmdfStruct {
  KmdfWDFRemoveLockOptions() { this.getName().matches("_WDF_REMOVE_LOCK_OPTIONS") }
}

class KmdfWDFPowerFrameworkSettings extends KmdfStruct {
  KmdfWDFPowerFrameworkSettings() { this.getName().matches("_WDF_POWER_FRAMEWORK_SETTINGS") }
}

class KmdfWDFIoTypeConfig extends KmdfStruct {
  KmdfWDFIoTypeConfig() { this.getName().matches("_WDF_IO_TYPE_CONFIG") }
}

class KmdfWDFDevicePropertyData extends KmdfStruct {
  KmdfWDFDevicePropertyData() { this.getName().matches("_WDF_DEVICE_PROPERTY_DATA") }
}

class KmdfWDFDmaEnablerConfig extends KmdfStruct {
  KmdfWDFDmaEnablerConfig() { this.getName().matches("_WDF_DMA_ENABLER_CONFIG") }
}

class KmdfWDFDmaSystemProfileConfig extends KmdfStruct {
  KmdfWDFDmaSystemProfileConfig() { this.getName().matches("_WDF_DMA_SYSTEM_PROFILE_CONFIG") }
}

class KmdfWDFDpcConfig extends KmdfStruct {
  KmdfWDFDpcConfig() { this.getName().matches("_WDF_DPC_CONFIG") }
}

class KmdfWDFDriverConfig extends KmdfStruct {
  KmdfWDFDriverConfig() { this.getName().matches("_WDF_DRIVER_CONFIG") }
}

class KmdfWDFDriverVersionAvailableParams extends KmdfStruct {
  KmdfWDFDriverVersionAvailableParams() {
    this.getName().matches("_WDF_DRIVER_VERSION_AVAILABLE_PARAMS")
  }
}

class KmdfWDFFdoEventCallbacks extends KmdfStruct {
  KmdfWDFFdoEventCallbacks() { this.getName().matches("_WDF_FDO_EVENT_CALLBACKS") }
}

class KmdfWDFDriverGlobals extends KmdfStruct {
  KmdfWDFDriverGlobals() { this.getName().matches("_WDF_DRIVER_GLOBALS") }
}

class KmdfWDFCoinstallerInstallOptions extends KmdfStruct {
  KmdfWDFCoinstallerInstallOptions() { this.getName().matches("_WDF_COINSTALLER_INSTALL_OPTIONS") }
}

class KmdfWDFInterruptConfig extends KmdfStruct {
  KmdfWDFInterruptConfig() { this.getName().matches("_WDF_INTERRUPT_CONFIG") }
}

class KmdfWDFInterruptInfo extends KmdfStruct {
  KmdfWDFInterruptInfo() { this.getName().matches("_WDF_INTERRUPT_INFO") }
}

class KmdfWDFInterruptExtendedPolicy extends KmdfStruct {
  KmdfWDFInterruptExtendedPolicy() { this.getName().matches("_WDF_INTERRUPT_EXTENDED_POLICY") }
}

class KmdfWDFIoQueueConfig extends KmdfStruct {
  KmdfWDFIoQueueConfig() { this.getName().matches("_WDF_IO_QUEUE_CONFIG") }
}

class KmdfWDFIoQueueForwardProgressPolicy extends KmdfStruct {
  KmdfWDFIoQueueForwardProgressPolicy() {
    this.getName().matches("_WDF_IO_QUEUE_FORWARD_PROGRESS_POLICY")
  }
}

class KmdfWDFIoTargetOpenParams extends KmdfStruct {
  KmdfWDFIoTargetOpenParams() { this.getName().matches("_WDF_IO_TARGET_OPEN_PARAMS") }
}

class KmdfWDFMEMORYOffset extends KmdfStruct {
  KmdfWDFMEMORYOffset() { this.getName().matches("_WDFMEMORY_OFFSET") }
}

class KmdfWDFMemoryDescriptor extends KmdfStruct {
  KmdfWDFMemoryDescriptor() { this.getName().matches("_WDF_MEMORY_DESCRIPTOR") }
}

class KmdfWDFObjectAttributes extends KmdfStruct {
  KmdfWDFObjectAttributes() { this.getName().matches("_WDF_OBJECT_ATTRIBUTES") }
}

class KmdfWDFObjectContextTypeInfo extends KmdfStruct {
  KmdfWDFObjectContextTypeInfo() { this.getName().matches("_WDF_OBJECT_CONTEXT_TYPE_INFO") }
}

class KmdfWDFCustomTypeContext extends KmdfStruct {
  KmdfWDFCustomTypeContext() { this.getName().matches("_WDF_CUSTOM_TYPE_CONTEXT") }
}

class KmdfWDFPdoEventCallbacks extends KmdfStruct {
  KmdfWDFPdoEventCallbacks() { this.getName().matches("_WDF_PDO_EVENT_CALLBACKS") }
}

class KmdfWDFQueryInterfaceConfig extends KmdfStruct {
  KmdfWDFQueryInterfaceConfig() { this.getName().matches("_WDF_QUERY_INTERFACE_CONFIG") }
}

class KmdfWDFRequestParameters extends KmdfStruct {
  KmdfWDFRequestParameters() { this.getName().matches("_WDF_REQUEST_PARAMETERS") }
}

class KmdfWDFRequestCompletionParams extends KmdfStruct {
  KmdfWDFRequestCompletionParams() { this.getName().matches("_WDF_REQUEST_COMPLETION_PARAMS") }
}

class KmdfWDFRequestReuseParams extends KmdfStruct {
  KmdfWDFRequestReuseParams() { this.getName().matches("_WDF_REQUEST_REUSE_PARAMS") }
}

class KmdfWDFRequestSendOptions extends KmdfStruct {
  KmdfWDFRequestSendOptions() { this.getName().matches("_WDF_REQUEST_SEND_OPTIONS") }
}

class KmdfWDFRequestForwardOptions extends KmdfStruct {
  KmdfWDFRequestForwardOptions() { this.getName().matches("_WDF_REQUEST_FORWARD_OPTIONS") }
}

class KmdfWDFTimerConfig extends KmdfStruct {
  KmdfWDFTimerConfig() { this.getName().matches("_WDF_TIMER_CONFIG") }
}

class KmdfWDFUsbRequestCompletionParams extends KmdfStruct {
  KmdfWDFUsbRequestCompletionParams() {
    this.getName().matches("_WDF_USB_REQUEST_COMPLETION_PARAMS")
  }
}

class KmdfWDFUsbContinuousReaderConfig extends KmdfStruct {
  KmdfWDFUsbContinuousReaderConfig() { this.getName().matches("_WDF_USB_CONTINUOUS_READER_CONFIG") }
}

class KmdfWDFUsbDeviceInformation extends KmdfStruct {
  KmdfWDFUsbDeviceInformation() { this.getName().matches("_WDF_USB_DEVICE_INFORMATION") }
}

class KmdfWDFUsbInterfaceSettingPair extends KmdfStruct {
  KmdfWDFUsbInterfaceSettingPair() { this.getName().matches("_WDF_USB_INTERFACE_SETTING_PAIR") }
}

class KmdfWDFUsbDeviceSelectConfigParams extends KmdfStruct {
  KmdfWDFUsbDeviceSelectConfigParams() {
    this.getName().matches("_WDF_USB_DEVICE_SELECT_CONFIG_PARAMS")
  }
}

class KmdfWDFUsbInterfaceSelectSettingParams extends KmdfStruct {
  KmdfWDFUsbInterfaceSelectSettingParams() {
    this.getName().matches("_WDF_USB_INTERFACE_SELECT_SETTING_PARAMS")
  }
}

class KmdfWDFUsbPipeInformation extends KmdfStruct {
  KmdfWDFUsbPipeInformation() { this.getName().matches("_WDF_USB_PIPE_INFORMATION") }
}

class KmdfWDFUsbDeviceCreateConfig extends KmdfStruct {
  KmdfWDFUsbDeviceCreateConfig() { this.getName().matches("_WDF_USB_DEVICE_CREATE_CONFIG") }
}

class KmdfWDFWmiProviderConfig extends KmdfStruct {
  KmdfWDFWmiProviderConfig() { this.getName().matches("_WDF_WMI_PROVIDER_CONFIG") }
}

class KmdfWDFWmiInstanceConfig extends KmdfStruct {
  KmdfWDFWmiInstanceConfig() { this.getName().matches("_WDF_WMI_INSTANCE_CONFIG") }
}

class KmdfWDFWorkitemConfig extends KmdfStruct {
  KmdfWDFWorkitemConfig() { this.getName().matches("_WDF_WORKITEM_CONFIG") }
}
