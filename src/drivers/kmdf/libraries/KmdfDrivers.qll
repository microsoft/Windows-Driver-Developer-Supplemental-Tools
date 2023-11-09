// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
import cpp

/**
 * A KMDF Typedef type. This class is incomplete.  It is used to represent a TypedefType in the KMDF library.
 */
// class KmdfRoleTypeType extends TypedefType {
//   KmdfRoleTypeType() { this.getFile().getBaseName().matches("wdf%.h") }
// }
class KmdfRoleTypeType extends TypedefType {
  /* Callbacks */
  KmdfRoleTypeType() {
    //   this.getName().matches("DRIVER_INITIALIZE") or
    // ? wdm types?
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
    this.getName().matches("EVT_WDF_OBJECT_CONTEXT_CLEANUP") or
    this.getName().matches("EVT_WDF_OBJECT_CONTEXT_DESTROY") or
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
  KmdfCallbackRoutineTypedef() { this.getFile().getBaseName().matches("%wdf.h") }
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
  KmdfEVTWdfDeviceRelationsQuery() { callbackType.getName().matches("EVT_WDF_DEVICE_RELATIONS_QUERY") }
}

class KmdfEVTWdfDeviceArmWakeFromS0 extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceArmWakeFromS0() { callbackType.getName().matches("EVT_WDF_DEVICE_ARM_WAKE_FROM_S0") }
}

class KmdfEVTWdfDeviceArmWakeFromSx extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceArmWakeFromSx() { callbackType.getName().matches("EVT_WDF_DEVICE_ARM_WAKE_FROM_SX") }
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
  KmdfEVTWdfdeviceWdmIrpDispatch() { callbackType.getName().matches("EVT_WDFDEVICE_WDM_IRP_DISPATCH") }
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
  KmdfEVTWdfInterruptSynchronize() { callbackType.getName().matches("EVT_WDF_INTERRUPT_SYNCHRONIZE") }
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
  KmdfEVTWdfIoTargetQueryRemove() { callbackType.getName().matches("EVT_WDF_IO_TARGET_QUERY_REMOVE") }
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
  KmdfEVTWdfObjectContextCleanup() { callbackType.getName().matches("EVT_WDF_OBJECT_CONTEXT_CLEANUP") }
}

class KmdfEVTWdfObjectContextDestroy extends KmdfCallbackRoutine {
  KmdfEVTWdfObjectContextDestroy() { callbackType.getName().matches("EVT_WDF_OBJECT_CONTEXT_DESTROY") }
}

class KmdfEVTWdfDeviceResourcesQuery extends KmdfCallbackRoutine {
  KmdfEVTWdfDeviceResourcesQuery() { callbackType.getName().matches("EVT_WDF_DEVICE_RESOURCES_QUERY") }
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

/* KMDF Functions */
/**
 * The KMDF DriverEntry function.  KMDF enforces that the function is named DriverEntry.
 * Additionally, the driver may use the DRIVER_INIRIALIZE typedef.
 */
class KmdfDriverEntry extends KmdfFunc {
  KmdfDriverEntry() { this.getName().matches("DriverEntry") }
}

class KmdfRtlAssert extends KmdfFunc {
  KmdfRtlAssert() { this.getName().matches("RtlAssert") }
}

class KmdfWdfChildListCreate extends KmdfFunc {
  KmdfWdfChildListCreate() { this.getName().matches("WdfChildListCreate") }
}

class KmdfWdfChildListGetDevice extends KmdfFunc {
  KmdfWdfChildListGetDevice() { this.getName().matches("WdfChildListGetDevice") }
}

class KmdfWdfChildListRetrievePdo extends KmdfFunc {
  KmdfWdfChildListRetrievePdo() { this.getName().matches("WdfChildListRetrievePdo") }
}

class KmdfWdfChildListRetrieveAddressDescription extends KmdfFunc {
  KmdfWdfChildListRetrieveAddressDescription() {
    this.getName().matches("WdfChildListRetrieveAddressDescription")
  }
}

class KmdfWdfChildListBeginScan extends KmdfFunc {
  KmdfWdfChildListBeginScan() { this.getName().matches("WdfChildListBeginScan") }
}

class KmdfWdfChildListEndScan extends KmdfFunc {
  KmdfWdfChildListEndScan() { this.getName().matches("WdfChildListEndScan") }
}

class KmdfWdfChildListBeginIteration extends KmdfFunc {
  KmdfWdfChildListBeginIteration() { this.getName().matches("WdfChildListBeginIteration") }
}

class KmdfWdfChildListRetrieveNextDevice extends KmdfFunc {
  KmdfWdfChildListRetrieveNextDevice() { this.getName().matches("WdfChildListRetrieveNextDevice") }
}

class KmdfWdfChildListEndIteration extends KmdfFunc {
  KmdfWdfChildListEndIteration() { this.getName().matches("WdfChildListEndIteration") }
}

class KmdfWdfChildListAddOrUpdateChildDescriptionAsPresent extends KmdfFunc {
  KmdfWdfChildListAddOrUpdateChildDescriptionAsPresent() {
    this.getName().matches("WdfChildListAddOrUpdateChildDescriptionAsPresent")
  }
}

class KmdfWdfChildListUpdateChildDescriptionAsMissing extends KmdfFunc {
  KmdfWdfChildListUpdateChildDescriptionAsMissing() {
    this.getName().matches("WdfChildListUpdateChildDescriptionAsMissing")
  }
}

class KmdfWdfChildListUpdateAllChildDescriptionsAsPresent extends KmdfFunc {
  KmdfWdfChildListUpdateAllChildDescriptionsAsPresent() {
    this.getName().matches("WdfChildListUpdateAllChildDescriptionsAsPresent")
  }
}

class KmdfWdfChildListRequestChildEject extends KmdfFunc {
  KmdfWdfChildListRequestChildEject() { this.getName().matches("WdfChildListRequestChildEject") }
}

class KmdfWdfCollectionCreate extends KmdfFunc {
  KmdfWdfCollectionCreate() { this.getName().matches("WdfCollectionCreate") }
}

class KmdfWdfCollectionGetCount extends KmdfFunc {
  KmdfWdfCollectionGetCount() { this.getName().matches("WdfCollectionGetCount") }
}

class KmdfWdfCollectionAdd extends KmdfFunc {
  KmdfWdfCollectionAdd() { this.getName().matches("WdfCollectionAdd") }
}

class KmdfWdfCollectionRemove extends KmdfFunc {
  KmdfWdfCollectionRemove() { this.getName().matches("WdfCollectionRemove") }
}

class KmdfWdfCollectionRemoveItem extends KmdfFunc {
  KmdfWdfCollectionRemoveItem() { this.getName().matches("WdfCollectionRemoveItem") }
}

class KmdfWdfCollectionGetItem extends KmdfFunc {
  KmdfWdfCollectionGetItem() { this.getName().matches("WdfCollectionGetItem") }
}

class KmdfWdfCollectionGetFirstItem extends KmdfFunc {
  KmdfWdfCollectionGetFirstItem() { this.getName().matches("WdfCollectionGetFirstItem") }
}

class KmdfWdfCollectionGetLastItem extends KmdfFunc {
  KmdfWdfCollectionGetLastItem() { this.getName().matches("WdfCollectionGetLastItem") }
}

class KmdfWdfCommonBufferCreate extends KmdfFunc {
  KmdfWdfCommonBufferCreate() { this.getName().matches("WdfCommonBufferCreate") }
}

class KmdfWdfCommonBufferCreateWithConfig extends KmdfFunc {
  KmdfWdfCommonBufferCreateWithConfig() {
    this.getName().matches("WdfCommonBufferCreateWithConfig")
  }
}

class KmdfWdfCommonBufferGetAlignedVirtualAddress extends KmdfFunc {
  KmdfWdfCommonBufferGetAlignedVirtualAddress() {
    this.getName().matches("WdfCommonBufferGetAlignedVirtualAddress")
  }
}

class KmdfWdfCommonBufferGetAlignedLogicalAddress extends KmdfFunc {
  KmdfWdfCommonBufferGetAlignedLogicalAddress() {
    this.getName().matches("WdfCommonBufferGetAlignedLogicalAddress")
  }
}

class KmdfWdfCommonBufferGetLength extends KmdfFunc {
  KmdfWdfCommonBufferGetLength() { this.getName().matches("WdfCommonBufferGetLength") }
}

class KmdfWdfCompanionTargetSendTaskSynchronously extends KmdfFunc {
  KmdfWdfCompanionTargetSendTaskSynchronously() {
    this.getName().matches("WdfCompanionTargetSendTaskSynchronously")
  }
}

class KmdfWdfCompanionTargetWdmGetCompanionProcess extends KmdfFunc {
  KmdfWdfCompanionTargetWdmGetCompanionProcess() {
    this.getName().matches("WdfCompanionTargetWdmGetCompanionProcess")
  }
}

class KmdfWdfControlDeviceInitAllocate extends KmdfFunc {
  KmdfWdfControlDeviceInitAllocate() { this.getName().matches("WdfControlDeviceInitAllocate") }
}

class KmdfWdfControlDeviceInitSetShutdownNotification extends KmdfFunc {
  KmdfWdfControlDeviceInitSetShutdownNotification() {
    this.getName().matches("WdfControlDeviceInitSetShutdownNotification")
  }
}

class KmdfWdfControlFinishInitializing extends KmdfFunc {
  KmdfWdfControlFinishInitializing() { this.getName().matches("WdfControlFinishInitializing") }
}

class KmdfWdfDevStateNormalize extends KmdfFunc {
  KmdfWdfDevStateNormalize() { this.getName().matches("WdfDevStateNormalize") }
}

class KmdfWdfDevStateIsNP extends KmdfFunc {
  KmdfWdfDevStateIsNP() { this.getName().matches("WdfDevStateIsNP") }
}

class KmdfWdfDeviceGetDeviceState extends KmdfFunc {
  KmdfWdfDeviceGetDeviceState() { this.getName().matches("WdfDeviceGetDeviceState") }
}

class KmdfWdfDeviceSetDeviceState extends KmdfFunc {
  KmdfWdfDeviceSetDeviceState() { this.getName().matches("WdfDeviceSetDeviceState") }
}

class KmdfWdfWdmDeviceGetWdfDeviceHandle extends KmdfFunc {
  KmdfWdfWdmDeviceGetWdfDeviceHandle() { this.getName().matches("WdfWdmDeviceGetWdfDeviceHandle") }
}

class KmdfWdfDeviceWdmGetDeviceObject extends KmdfFunc {
  KmdfWdfDeviceWdmGetDeviceObject() { this.getName().matches("WdfDeviceWdmGetDeviceObject") }
}

class KmdfWdfDeviceWdmGetAttachedDevice extends KmdfFunc {
  KmdfWdfDeviceWdmGetAttachedDevice() { this.getName().matches("WdfDeviceWdmGetAttachedDevice") }
}

class KmdfWdfDeviceWdmGetPhysicalDevice extends KmdfFunc {
  KmdfWdfDeviceWdmGetPhysicalDevice() { this.getName().matches("WdfDeviceWdmGetPhysicalDevice") }
}

class KmdfWdfDeviceWdmDispatchPreprocessedIrp extends KmdfFunc {
  KmdfWdfDeviceWdmDispatchPreprocessedIrp() {
    this.getName().matches("WdfDeviceWdmDispatchPreprocessedIrp")
  }
}

class KmdfWdfDeviceWdmDispatchIrp extends KmdfFunc {
  KmdfWdfDeviceWdmDispatchIrp() { this.getName().matches("WdfDeviceWdmDispatchIrp") }
}

class KmdfWdfDeviceWdmDispatchIrpToIoQueue extends KmdfFunc {
  KmdfWdfDeviceWdmDispatchIrpToIoQueue() {
    this.getName().matches("WdfDeviceWdmDispatchIrpToIoQueue")
  }
}

class KmdfWdfDeviceAddDependentUsageDeviceObject extends KmdfFunc {
  KmdfWdfDeviceAddDependentUsageDeviceObject() {
    this.getName().matches("WdfDeviceAddDependentUsageDeviceObject")
  }
}

class KmdfWdfDeviceRemoveDependentUsageDeviceObject extends KmdfFunc {
  KmdfWdfDeviceRemoveDependentUsageDeviceObject() {
    this.getName().matches("WdfDeviceRemoveDependentUsageDeviceObject")
  }
}

class KmdfWdfDeviceAddRemovalRelationsPhysicalDevice extends KmdfFunc {
  KmdfWdfDeviceAddRemovalRelationsPhysicalDevice() {
    this.getName().matches("WdfDeviceAddRemovalRelationsPhysicalDevice")
  }
}

class KmdfWdfDeviceRemoveRemovalRelationsPhysicalDevice extends KmdfFunc {
  KmdfWdfDeviceRemoveRemovalRelationsPhysicalDevice() {
    this.getName().matches("WdfDeviceRemoveRemovalRelationsPhysicalDevice")
  }
}

class KmdfWdfDeviceClearRemovalRelationsDevices extends KmdfFunc {
  KmdfWdfDeviceClearRemovalRelationsDevices() {
    this.getName().matches("WdfDeviceClearRemovalRelationsDevices")
  }
}

class KmdfWdfDeviceGetDriver extends KmdfFunc {
  KmdfWdfDeviceGetDriver() { this.getName().matches("WdfDeviceGetDriver") }
}

class KmdfWdfDeviceRetrieveDeviceName extends KmdfFunc {
  KmdfWdfDeviceRetrieveDeviceName() { this.getName().matches("WdfDeviceRetrieveDeviceName") }
}

class KmdfWdfDeviceAssignMofResourceName extends KmdfFunc {
  KmdfWdfDeviceAssignMofResourceName() { this.getName().matches("WdfDeviceAssignMofResourceName") }
}

class KmdfWdfDeviceGetIoTarget extends KmdfFunc {
  KmdfWdfDeviceGetIoTarget() { this.getName().matches("WdfDeviceGetIoTarget") }
}

class KmdfWdfDeviceGetDevicePnpState extends KmdfFunc {
  KmdfWdfDeviceGetDevicePnpState() { this.getName().matches("WdfDeviceGetDevicePnpState") }
}

class KmdfWdfDeviceGetDevicePowerState extends KmdfFunc {
  KmdfWdfDeviceGetDevicePowerState() { this.getName().matches("WdfDeviceGetDevicePowerState") }
}

class KmdfWdfDeviceGetDevicePowerPolicyState extends KmdfFunc {
  KmdfWdfDeviceGetDevicePowerPolicyState() {
    this.getName().matches("WdfDeviceGetDevicePowerPolicyState")
  }
}

class KmdfWdfDeviceAssignS0IdleSettings extends KmdfFunc {
  KmdfWdfDeviceAssignS0IdleSettings() { this.getName().matches("WdfDeviceAssignS0IdleSettings") }
}

class KmdfWdfDeviceAssignSxWakeSettings extends KmdfFunc {
  KmdfWdfDeviceAssignSxWakeSettings() { this.getName().matches("WdfDeviceAssignSxWakeSettings") }
}

class KmdfWdfDeviceOpenRegistryKey extends KmdfFunc {
  KmdfWdfDeviceOpenRegistryKey() { this.getName().matches("WdfDeviceOpenRegistryKey") }
}

class KmdfWdfDeviceOpenDevicemapKey extends KmdfFunc {
  KmdfWdfDeviceOpenDevicemapKey() { this.getName().matches("WdfDeviceOpenDevicemapKey") }
}

class KmdfWdfDeviceSetSpecialFileSupport extends KmdfFunc {
  KmdfWdfDeviceSetSpecialFileSupport() { this.getName().matches("WdfDeviceSetSpecialFileSupport") }
}

class KmdfWdfDeviceSetCharacteristics extends KmdfFunc {
  KmdfWdfDeviceSetCharacteristics() { this.getName().matches("WdfDeviceSetCharacteristics") }
}

class KmdfWdfDeviceGetCharacteristics extends KmdfFunc {
  KmdfWdfDeviceGetCharacteristics() { this.getName().matches("WdfDeviceGetCharacteristics") }
}

class KmdfWdfDeviceGetAlignmentRequirement extends KmdfFunc {
  KmdfWdfDeviceGetAlignmentRequirement() {
    this.getName().matches("WdfDeviceGetAlignmentRequirement")
  }
}

class KmdfWdfDeviceSetAlignmentRequirement extends KmdfFunc {
  KmdfWdfDeviceSetAlignmentRequirement() {
    this.getName().matches("WdfDeviceSetAlignmentRequirement")
  }
}

class KmdfWdfDeviceInitFree extends KmdfFunc {
  KmdfWdfDeviceInitFree() { this.getName().matches("WdfDeviceInitFree") }
}

class KmdfWdfDeviceInitSetPnpPowerEventCallbacks extends KmdfFunc {
  KmdfWdfDeviceInitSetPnpPowerEventCallbacks() {
    this.getName().matches("WdfDeviceInitSetPnpPowerEventCallbacks")
  }
}

class KmdfWdfDeviceInitSetPowerPolicyEventCallbacks extends KmdfFunc {
  KmdfWdfDeviceInitSetPowerPolicyEventCallbacks() {
    this.getName().matches("WdfDeviceInitSetPowerPolicyEventCallbacks")
  }
}

class KmdfWdfDeviceInitSetPowerPolicyOwnership extends KmdfFunc {
  KmdfWdfDeviceInitSetPowerPolicyOwnership() {
    this.getName().matches("WdfDeviceInitSetPowerPolicyOwnership")
  }
}

class KmdfWdfDeviceInitRegisterPnpStateChangeCallback extends KmdfFunc {
  KmdfWdfDeviceInitRegisterPnpStateChangeCallback() {
    this.getName().matches("WdfDeviceInitRegisterPnpStateChangeCallback")
  }
}

class KmdfWdfDeviceInitRegisterPowerStateChangeCallback extends KmdfFunc {
  KmdfWdfDeviceInitRegisterPowerStateChangeCallback() {
    this.getName().matches("WdfDeviceInitRegisterPowerStateChangeCallback")
  }
}

class KmdfWdfDeviceInitRegisterPowerPolicyStateChangeCallback extends KmdfFunc {
  KmdfWdfDeviceInitRegisterPowerPolicyStateChangeCallback() {
    this.getName().matches("WdfDeviceInitRegisterPowerPolicyStateChangeCallback")
  }
}

class KmdfWdfDeviceInitSetExclusive extends KmdfFunc {
  KmdfWdfDeviceInitSetExclusive() { this.getName().matches("WdfDeviceInitSetExclusive") }
}

class KmdfWdfDeviceInitSetIoType extends KmdfFunc {
  KmdfWdfDeviceInitSetIoType() { this.getName().matches("WdfDeviceInitSetIoType") }
}

class KmdfWdfDeviceInitSetPowerNotPageable extends KmdfFunc {
  KmdfWdfDeviceInitSetPowerNotPageable() {
    this.getName().matches("WdfDeviceInitSetPowerNotPageable")
  }
}

class KmdfWdfDeviceInitSetPowerPageable extends KmdfFunc {
  KmdfWdfDeviceInitSetPowerPageable() { this.getName().matches("WdfDeviceInitSetPowerPageable") }
}

class KmdfWdfDeviceInitSetPowerInrush extends KmdfFunc {
  KmdfWdfDeviceInitSetPowerInrush() { this.getName().matches("WdfDeviceInitSetPowerInrush") }
}

class KmdfWdfDeviceInitSetDeviceType extends KmdfFunc {
  KmdfWdfDeviceInitSetDeviceType() { this.getName().matches("WdfDeviceInitSetDeviceType") }
}

class KmdfWdfDeviceInitAssignName extends KmdfFunc {
  KmdfWdfDeviceInitAssignName() { this.getName().matches("WdfDeviceInitAssignName") }
}

class KmdfWdfDeviceInitAssignSDDLString extends KmdfFunc {
  KmdfWdfDeviceInitAssignSDDLString() { this.getName().matches("WdfDeviceInitAssignSDDLString") }
}

class KmdfWdfDeviceInitSetDeviceClass extends KmdfFunc {
  KmdfWdfDeviceInitSetDeviceClass() { this.getName().matches("WdfDeviceInitSetDeviceClass") }
}

class KmdfWdfDeviceInitSetCharacteristics extends KmdfFunc {
  KmdfWdfDeviceInitSetCharacteristics() {
    this.getName().matches("WdfDeviceInitSetCharacteristics")
  }
}

class KmdfWdfDeviceInitSetFileObjectConfig extends KmdfFunc {
  KmdfWdfDeviceInitSetFileObjectConfig() {
    this.getName().matches("WdfDeviceInitSetFileObjectConfig")
  }
}

class KmdfWdfDeviceInitSetRequestAttributes extends KmdfFunc {
  KmdfWdfDeviceInitSetRequestAttributes() {
    this.getName().matches("WdfDeviceInitSetRequestAttributes")
  }
}

class KmdfWdfDeviceInitAssignWdmIrpPreprocessCallback extends KmdfFunc {
  KmdfWdfDeviceInitAssignWdmIrpPreprocessCallback() {
    this.getName().matches("WdfDeviceInitAssignWdmIrpPreprocessCallback")
  }
}

class KmdfWdfDeviceInitSetIoInCallerContextCallback extends KmdfFunc {
  KmdfWdfDeviceInitSetIoInCallerContextCallback() {
    this.getName().matches("WdfDeviceInitSetIoInCallerContextCallback")
  }
}

class KmdfWdfDeviceInitSetRemoveLockOptions extends KmdfFunc {
  KmdfWdfDeviceInitSetRemoveLockOptions() {
    this.getName().matches("WdfDeviceInitSetRemoveLockOptions")
  }
}

class KmdfWdfDeviceCreate extends KmdfFunc {
  KmdfWdfDeviceCreate() { this.getName().matches("WdfDeviceCreate") }
}

class KmdfWdfDeviceSetStaticStopRemove extends KmdfFunc {
  KmdfWdfDeviceSetStaticStopRemove() { this.getName().matches("WdfDeviceSetStaticStopRemove") }
}

class KmdfWdfDeviceCreateDeviceInterface extends KmdfFunc {
  KmdfWdfDeviceCreateDeviceInterface() { this.getName().matches("WdfDeviceCreateDeviceInterface") }
}

class KmdfWdfDeviceSetDeviceInterfaceState extends KmdfFunc {
  KmdfWdfDeviceSetDeviceInterfaceState() {
    this.getName().matches("WdfDeviceSetDeviceInterfaceState")
  }
}

class KmdfWdfDeviceSetDeviceInterfaceStateEx extends KmdfFunc {
  KmdfWdfDeviceSetDeviceInterfaceStateEx() {
    this.getName().matches("WdfDeviceSetDeviceInterfaceStateEx")
  }
}

class KmdfWdfDeviceRetrieveDeviceInterfaceString extends KmdfFunc {
  KmdfWdfDeviceRetrieveDeviceInterfaceString() {
    this.getName().matches("WdfDeviceRetrieveDeviceInterfaceString")
  }
}

class KmdfWdfDeviceCreateSymbolicLink extends KmdfFunc {
  KmdfWdfDeviceCreateSymbolicLink() { this.getName().matches("WdfDeviceCreateSymbolicLink") }
}

class KmdfWdfDeviceQueryProperty extends KmdfFunc {
  KmdfWdfDeviceQueryProperty() { this.getName().matches("WdfDeviceQueryProperty") }
}

class KmdfWdfDeviceAllocAndQueryProperty extends KmdfFunc {
  KmdfWdfDeviceAllocAndQueryProperty() { this.getName().matches("WdfDeviceAllocAndQueryProperty") }
}

class KmdfWdfDeviceSetPnpCapabilities extends KmdfFunc {
  KmdfWdfDeviceSetPnpCapabilities() { this.getName().matches("WdfDeviceSetPnpCapabilities") }
}

class KmdfWdfDeviceSetPowerCapabilities extends KmdfFunc {
  KmdfWdfDeviceSetPowerCapabilities() { this.getName().matches("WdfDeviceSetPowerCapabilities") }
}

class KmdfWdfDeviceSetBusInformationForChildren extends KmdfFunc {
  KmdfWdfDeviceSetBusInformationForChildren() {
    this.getName().matches("WdfDeviceSetBusInformationForChildren")
  }
}

class KmdfWdfDeviceIndicateWakeStatus extends KmdfFunc {
  KmdfWdfDeviceIndicateWakeStatus() { this.getName().matches("WdfDeviceIndicateWakeStatus") }
}

class KmdfWdfDeviceSetFailed extends KmdfFunc {
  KmdfWdfDeviceSetFailed() { this.getName().matches("WdfDeviceSetFailed") }
}

class KmdfWdfDeviceStopIdleNoTrack extends KmdfFunc {
  KmdfWdfDeviceStopIdleNoTrack() { this.getName().matches("WdfDeviceStopIdleNoTrack") }
}

class KmdfWdfDeviceResumeIdleNoTrack extends KmdfFunc {
  KmdfWdfDeviceResumeIdleNoTrack() { this.getName().matches("WdfDeviceResumeIdleNoTrack") }
}

class KmdfWdfDeviceStopIdleActual extends KmdfFunc {
  KmdfWdfDeviceStopIdleActual() { this.getName().matches("WdfDeviceStopIdleActual") }
}

class KmdfWdfDeviceResumeIdleActual extends KmdfFunc {
  KmdfWdfDeviceResumeIdleActual() { this.getName().matches("WdfDeviceResumeIdleActual") }
}

class KmdfWdfDeviceGetFileObject extends KmdfFunc {
  KmdfWdfDeviceGetFileObject() { this.getName().matches("WdfDeviceGetFileObject") }
}

class KmdfWdfDeviceEnqueueRequest extends KmdfFunc {
  KmdfWdfDeviceEnqueueRequest() { this.getName().matches("WdfDeviceEnqueueRequest") }
}

class KmdfWdfDeviceGetDefaultQueue extends KmdfFunc {
  KmdfWdfDeviceGetDefaultQueue() { this.getName().matches("WdfDeviceGetDefaultQueue") }
}

class KmdfWdfDeviceConfigureRequestDispatching extends KmdfFunc {
  KmdfWdfDeviceConfigureRequestDispatching() {
    this.getName().matches("WdfDeviceConfigureRequestDispatching")
  }
}

class KmdfWdfDeviceConfigureWdmIrpDispatchCallback extends KmdfFunc {
  KmdfWdfDeviceConfigureWdmIrpDispatchCallback() {
    this.getName().matches("WdfDeviceConfigureWdmIrpDispatchCallback")
  }
}

class KmdfWdfDeviceGetSystemPowerAction extends KmdfFunc {
  KmdfWdfDeviceGetSystemPowerAction() { this.getName().matches("WdfDeviceGetSystemPowerAction") }
}

class KmdfWdfDeviceWdmAssignPowerFrameworkSettings extends KmdfFunc {
  KmdfWdfDeviceWdmAssignPowerFrameworkSettings() {
    this.getName().matches("WdfDeviceWdmAssignPowerFrameworkSettings")
  }
}

class KmdfWdfDeviceInitSetReleaseHardwareOrderOnFailure extends KmdfFunc {
  KmdfWdfDeviceInitSetReleaseHardwareOrderOnFailure() {
    this.getName().matches("WdfDeviceInitSetReleaseHardwareOrderOnFailure")
  }
}

class KmdfWdfDeviceInitSetIoTypeEx extends KmdfFunc {
  KmdfWdfDeviceInitSetIoTypeEx() { this.getName().matches("WdfDeviceInitSetIoTypeEx") }
}

class KmdfWdfDeviceQueryPropertyEx extends KmdfFunc {
  KmdfWdfDeviceQueryPropertyEx() { this.getName().matches("WdfDeviceQueryPropertyEx") }
}

class KmdfWdfDeviceAllocAndQueryPropertyEx extends KmdfFunc {
  KmdfWdfDeviceAllocAndQueryPropertyEx() {
    this.getName().matches("WdfDeviceAllocAndQueryPropertyEx")
  }
}

class KmdfWdfDeviceAssignProperty extends KmdfFunc {
  KmdfWdfDeviceAssignProperty() { this.getName().matches("WdfDeviceAssignProperty") }
}

class KmdfWdfDeviceRetrieveCompanionTarget extends KmdfFunc {
  KmdfWdfDeviceRetrieveCompanionTarget() {
    this.getName().matches("WdfDeviceRetrieveCompanionTarget")
  }
}

class KmdfWdfDmaEnablerCreate extends KmdfFunc {
  KmdfWdfDmaEnablerCreate() { this.getName().matches("WdfDmaEnablerCreate") }
}

class KmdfWdfDmaEnablerConfigureSystemProfile extends KmdfFunc {
  KmdfWdfDmaEnablerConfigureSystemProfile() {
    this.getName().matches("WdfDmaEnablerConfigureSystemProfile")
  }
}

class KmdfWdfDmaEnablerGetMaximumLength extends KmdfFunc {
  KmdfWdfDmaEnablerGetMaximumLength() { this.getName().matches("WdfDmaEnablerGetMaximumLength") }
}

class KmdfWdfDmaEnablerGetMaximumScatterGatherElements extends KmdfFunc {
  KmdfWdfDmaEnablerGetMaximumScatterGatherElements() {
    this.getName().matches("WdfDmaEnablerGetMaximumScatterGatherElements")
  }
}

class KmdfWdfDmaEnablerSetMaximumScatterGatherElements extends KmdfFunc {
  KmdfWdfDmaEnablerSetMaximumScatterGatherElements() {
    this.getName().matches("WdfDmaEnablerSetMaximumScatterGatherElements")
  }
}

class KmdfWdfDmaEnablerGetFragmentLength extends KmdfFunc {
  KmdfWdfDmaEnablerGetFragmentLength() { this.getName().matches("WdfDmaEnablerGetFragmentLength") }
}

class KmdfWdfDmaEnablerWdmGetDmaAdapter extends KmdfFunc {
  KmdfWdfDmaEnablerWdmGetDmaAdapter() { this.getName().matches("WdfDmaEnablerWdmGetDmaAdapter") }
}

class KmdfWdfDmaTransactionCreate extends KmdfFunc {
  KmdfWdfDmaTransactionCreate() { this.getName().matches("WdfDmaTransactionCreate") }
}

class KmdfWdfDmaTransactionInitialize extends KmdfFunc {
  KmdfWdfDmaTransactionInitialize() { this.getName().matches("WdfDmaTransactionInitialize") }
}

class KmdfWdfDmaTransactionInitializeUsingOffset extends KmdfFunc {
  KmdfWdfDmaTransactionInitializeUsingOffset() {
    this.getName().matches("WdfDmaTransactionInitializeUsingOffset")
  }
}

class KmdfWdfDmaTransactionInitializeUsingRequest extends KmdfFunc {
  KmdfWdfDmaTransactionInitializeUsingRequest() {
    this.getName().matches("WdfDmaTransactionInitializeUsingRequest")
  }
}

class KmdfWdfDmaTransactionExecute extends KmdfFunc {
  KmdfWdfDmaTransactionExecute() { this.getName().matches("WdfDmaTransactionExecute") }
}

class KmdfWdfDmaTransactionRelease extends KmdfFunc {
  KmdfWdfDmaTransactionRelease() { this.getName().matches("WdfDmaTransactionRelease") }
}

class KmdfWdfDmaTransactionDmaCompleted extends KmdfFunc {
  KmdfWdfDmaTransactionDmaCompleted() { this.getName().matches("WdfDmaTransactionDmaCompleted") }
}

class KmdfWdfDmaTransactionDmaCompletedWithLength extends KmdfFunc {
  KmdfWdfDmaTransactionDmaCompletedWithLength() {
    this.getName().matches("WdfDmaTransactionDmaCompletedWithLength")
  }
}

class KmdfWdfDmaTransactionDmaCompletedFinal extends KmdfFunc {
  KmdfWdfDmaTransactionDmaCompletedFinal() {
    this.getName().matches("WdfDmaTransactionDmaCompletedFinal")
  }
}

class KmdfWdfDmaTransactionGetBytesTransferred extends KmdfFunc {
  KmdfWdfDmaTransactionGetBytesTransferred() {
    this.getName().matches("WdfDmaTransactionGetBytesTransferred")
  }
}

class KmdfWdfDmaTransactionSetMaximumLength extends KmdfFunc {
  KmdfWdfDmaTransactionSetMaximumLength() {
    this.getName().matches("WdfDmaTransactionSetMaximumLength")
  }
}

class KmdfWdfDmaTransactionSetSingleTransferRequirement extends KmdfFunc {
  KmdfWdfDmaTransactionSetSingleTransferRequirement() {
    this.getName().matches("WdfDmaTransactionSetSingleTransferRequirement")
  }
}

class KmdfWdfDmaTransactionGetRequest extends KmdfFunc {
  KmdfWdfDmaTransactionGetRequest() { this.getName().matches("WdfDmaTransactionGetRequest") }
}

class KmdfWdfDmaTransactionGetCurrentDmaTransferLength extends KmdfFunc {
  KmdfWdfDmaTransactionGetCurrentDmaTransferLength() {
    this.getName().matches("WdfDmaTransactionGetCurrentDmaTransferLength")
  }
}

class KmdfWdfDmaTransactionGetDevice extends KmdfFunc {
  KmdfWdfDmaTransactionGetDevice() { this.getName().matches("WdfDmaTransactionGetDevice") }
}

class KmdfWdfDmaTransactionGetTransferInfo extends KmdfFunc {
  KmdfWdfDmaTransactionGetTransferInfo() {
    this.getName().matches("WdfDmaTransactionGetTransferInfo")
  }
}

class KmdfWdfDmaTransactionSetChannelConfigurationCallback extends KmdfFunc {
  KmdfWdfDmaTransactionSetChannelConfigurationCallback() {
    this.getName().matches("WdfDmaTransactionSetChannelConfigurationCallback")
  }
}

class KmdfWdfDmaTransactionSetTransferCompleteCallback extends KmdfFunc {
  KmdfWdfDmaTransactionSetTransferCompleteCallback() {
    this.getName().matches("WdfDmaTransactionSetTransferCompleteCallback")
  }
}

class KmdfWdfDmaTransactionSetImmediateExecution extends KmdfFunc {
  KmdfWdfDmaTransactionSetImmediateExecution() {
    this.getName().matches("WdfDmaTransactionSetImmediateExecution")
  }
}

class KmdfWdfDmaTransactionAllocateResources extends KmdfFunc {
  KmdfWdfDmaTransactionAllocateResources() {
    this.getName().matches("WdfDmaTransactionAllocateResources")
  }
}

class KmdfWdfDmaTransactionSetDeviceAddressOffset extends KmdfFunc {
  KmdfWdfDmaTransactionSetDeviceAddressOffset() {
    this.getName().matches("WdfDmaTransactionSetDeviceAddressOffset")
  }
}

class KmdfWdfDmaTransactionFreeResources extends KmdfFunc {
  KmdfWdfDmaTransactionFreeResources() { this.getName().matches("WdfDmaTransactionFreeResources") }
}

class KmdfWdfDmaTransactionCancel extends KmdfFunc {
  KmdfWdfDmaTransactionCancel() { this.getName().matches("WdfDmaTransactionCancel") }
}

class KmdfWdfDmaTransactionWdmGetTransferContext extends KmdfFunc {
  KmdfWdfDmaTransactionWdmGetTransferContext() {
    this.getName().matches("WdfDmaTransactionWdmGetTransferContext")
  }
}

class KmdfWdfDmaTransactionStopSystemTransfer extends KmdfFunc {
  KmdfWdfDmaTransactionStopSystemTransfer() {
    this.getName().matches("WdfDmaTransactionStopSystemTransfer")
  }
}

class KmdfWdfDpcCreate extends KmdfFunc {
  KmdfWdfDpcCreate() { this.getName().matches("WdfDpcCreate") }
}

class KmdfWdfDpcEnqueue extends KmdfFunc {
  KmdfWdfDpcEnqueue() { this.getName().matches("WdfDpcEnqueue") }
}

class KmdfWdfDpcCancel extends KmdfFunc {
  KmdfWdfDpcCancel() { this.getName().matches("WdfDpcCancel") }
}

class KmdfWdfDpcGetParentObject extends KmdfFunc {
  KmdfWdfDpcGetParentObject() { this.getName().matches("WdfDpcGetParentObject") }
}

class KmdfWdfDpcWdmGetDpc extends KmdfFunc {
  KmdfWdfDpcWdmGetDpc() { this.getName().matches("WdfDpcWdmGetDpc") }
}

class KmdfWdfGetDriver extends KmdfFunc {
  KmdfWdfGetDriver() { this.getName().matches("WdfGetDriver") }
}

class KmdfWdfDriverCreate extends KmdfFunc {
  KmdfWdfDriverCreate() { this.getName().matches("WdfDriverCreate") }
}

class KmdfWdfDriverGetRegistryPath extends KmdfFunc {
  KmdfWdfDriverGetRegistryPath() { this.getName().matches("WdfDriverGetRegistryPath") }
}

class KmdfWdfDriverWdmGetDriverObject extends KmdfFunc {
  KmdfWdfDriverWdmGetDriverObject() { this.getName().matches("WdfDriverWdmGetDriverObject") }
}

class KmdfWdfDriverOpenParametersRegistryKey extends KmdfFunc {
  KmdfWdfDriverOpenParametersRegistryKey() {
    this.getName().matches("WdfDriverOpenParametersRegistryKey")
  }
}

class KmdfWdfWdmDriverGetWdfDriverHandle extends KmdfFunc {
  KmdfWdfWdmDriverGetWdfDriverHandle() { this.getName().matches("WdfWdmDriverGetWdfDriverHandle") }
}

class KmdfWdfDriverRegisterTraceInfo extends KmdfFunc {
  KmdfWdfDriverRegisterTraceInfo() { this.getName().matches("WdfDriverRegisterTraceInfo") }
}

class KmdfWdfDriverRetrieveVersionString extends KmdfFunc {
  KmdfWdfDriverRetrieveVersionString() { this.getName().matches("WdfDriverRetrieveVersionString") }
}

class KmdfWdfDriverIsVersionAvailable extends KmdfFunc {
  KmdfWdfDriverIsVersionAvailable() { this.getName().matches("WdfDriverIsVersionAvailable") }
}

class KmdfWdfDriverErrorReportApiMissing extends KmdfFunc {
  KmdfWdfDriverErrorReportApiMissing() { this.getName().matches("WdfDriverErrorReportApiMissing") }
}

class KmdfWdfDriverOpenPersistentStateRegistryKey extends KmdfFunc {
  KmdfWdfDriverOpenPersistentStateRegistryKey() {
    this.getName().matches("WdfDriverOpenPersistentStateRegistryKey")
  }
}

class KmdfWdfFdoInitWdmGetPhysicalDevice extends KmdfFunc {
  KmdfWdfFdoInitWdmGetPhysicalDevice() { this.getName().matches("WdfFdoInitWdmGetPhysicalDevice") }
}

class KmdfWdfFdoInitOpenRegistryKey extends KmdfFunc {
  KmdfWdfFdoInitOpenRegistryKey() { this.getName().matches("WdfFdoInitOpenRegistryKey") }
}

class KmdfWdfFdoInitQueryProperty extends KmdfFunc {
  KmdfWdfFdoInitQueryProperty() { this.getName().matches("WdfFdoInitQueryProperty") }
}

class KmdfWdfFdoInitAllocAndQueryProperty extends KmdfFunc {
  KmdfWdfFdoInitAllocAndQueryProperty() {
    this.getName().matches("WdfFdoInitAllocAndQueryProperty")
  }
}

class KmdfWdfFdoInitQueryPropertyEx extends KmdfFunc {
  KmdfWdfFdoInitQueryPropertyEx() { this.getName().matches("WdfFdoInitQueryPropertyEx") }
}

class KmdfWdfFdoInitAllocAndQueryPropertyEx extends KmdfFunc {
  KmdfWdfFdoInitAllocAndQueryPropertyEx() {
    this.getName().matches("WdfFdoInitAllocAndQueryPropertyEx")
  }
}

class KmdfWdfFdoInitSetEventCallbacks extends KmdfFunc {
  KmdfWdfFdoInitSetEventCallbacks() { this.getName().matches("WdfFdoInitSetEventCallbacks") }
}

class KmdfWdfFdoInitSetFilter extends KmdfFunc {
  KmdfWdfFdoInitSetFilter() { this.getName().matches("WdfFdoInitSetFilter") }
}

class KmdfWdfFdoInitSetDefaultChildListConfig extends KmdfFunc {
  KmdfWdfFdoInitSetDefaultChildListConfig() {
    this.getName().matches("WdfFdoInitSetDefaultChildListConfig")
  }
}

class KmdfWdfFdoQueryForInterface extends KmdfFunc {
  KmdfWdfFdoQueryForInterface() { this.getName().matches("WdfFdoQueryForInterface") }
}

class KmdfWdfFdoGetDefaultChildList extends KmdfFunc {
  KmdfWdfFdoGetDefaultChildList() { this.getName().matches("WdfFdoGetDefaultChildList") }
}

class KmdfWdfFdoAddStaticChild extends KmdfFunc {
  KmdfWdfFdoAddStaticChild() { this.getName().matches("WdfFdoAddStaticChild") }
}

class KmdfWdfFdoLockStaticChildListForIteration extends KmdfFunc {
  KmdfWdfFdoLockStaticChildListForIteration() {
    this.getName().matches("WdfFdoLockStaticChildListForIteration")
  }
}

class KmdfWdfFdoRetrieveNextStaticChild extends KmdfFunc {
  KmdfWdfFdoRetrieveNextStaticChild() { this.getName().matches("WdfFdoRetrieveNextStaticChild") }
}

class KmdfWdfFdoUnlockStaticChildListFromIteration extends KmdfFunc {
  KmdfWdfFdoUnlockStaticChildListFromIteration() {
    this.getName().matches("WdfFdoUnlockStaticChildListFromIteration")
  }
}

class KmdfWdfFileObjectGetFileName extends KmdfFunc {
  KmdfWdfFileObjectGetFileName() { this.getName().matches("WdfFileObjectGetFileName") }
}

class KmdfWdfFileObjectGetFlags extends KmdfFunc {
  KmdfWdfFileObjectGetFlags() { this.getName().matches("WdfFileObjectGetFlags") }
}

class KmdfWdfFileObjectGetDevice extends KmdfFunc {
  KmdfWdfFileObjectGetDevice() { this.getName().matches("WdfFileObjectGetDevice") }
}

class KmdfWdfFileObjectGetInitiatorProcessId extends KmdfFunc {
  KmdfWdfFileObjectGetInitiatorProcessId() {
    this.getName().matches("WdfFileObjectGetInitiatorProcessId")
  }
}

class KmdfWdfFileObjectWdmGetFileObject extends KmdfFunc {
  KmdfWdfFileObjectWdmGetFileObject() { this.getName().matches("WdfFileObjectWdmGetFileObject") }
}

class KmdfWdfPreDeviceInstall extends KmdfFunc {
  KmdfWdfPreDeviceInstall() { this.getName().matches("WdfPreDeviceInstall") }
}

class KmdfWdfPreDeviceInstallEx extends KmdfFunc {
  KmdfWdfPreDeviceInstallEx() { this.getName().matches("WdfPreDeviceInstallEx") }
}

class KmdfWdfPostDeviceInstall extends KmdfFunc {
  KmdfWdfPostDeviceInstall() { this.getName().matches("WdfPostDeviceInstall") }
}

class KmdfWdfPreDeviceRemove extends KmdfFunc {
  KmdfWdfPreDeviceRemove() { this.getName().matches("WdfPreDeviceRemove") }
}

class KmdfWdfPostDeviceRemove extends KmdfFunc {
  KmdfWdfPostDeviceRemove() { this.getName().matches("WdfPostDeviceRemove") }
}

class KmdfWdfInterruptCreate extends KmdfFunc {
  KmdfWdfInterruptCreate() { this.getName().matches("WdfInterruptCreate") }
}

class KmdfWdfInterruptQueueDpcForIsr extends KmdfFunc {
  KmdfWdfInterruptQueueDpcForIsr() { this.getName().matches("WdfInterruptQueueDpcForIsr") }
}

class KmdfWdfInterruptQueueWorkItemForIsr extends KmdfFunc {
  KmdfWdfInterruptQueueWorkItemForIsr() {
    this.getName().matches("WdfInterruptQueueWorkItemForIsr")
  }
}

class KmdfWdfInterruptSynchronize extends KmdfFunc {
  KmdfWdfInterruptSynchronize() { this.getName().matches("WdfInterruptSynchronize") }
}

class KmdfWdfInterruptAcquireLock extends KmdfFunc {
  KmdfWdfInterruptAcquireLock() { this.getName().matches("WdfInterruptAcquireLock") }
}

class KmdfWdfInterruptReleaseLock extends KmdfFunc {
  KmdfWdfInterruptReleaseLock() { this.getName().matches("WdfInterruptReleaseLock") }
}

class KmdfWdfInterruptEnable extends KmdfFunc {
  KmdfWdfInterruptEnable() { this.getName().matches("WdfInterruptEnable") }
}

class KmdfWdfInterruptDisable extends KmdfFunc {
  KmdfWdfInterruptDisable() { this.getName().matches("WdfInterruptDisable") }
}

class KmdfWdfInterruptWdmGetInterrupt extends KmdfFunc {
  KmdfWdfInterruptWdmGetInterrupt() { this.getName().matches("WdfInterruptWdmGetInterrupt") }
}

class KmdfWdfInterruptGetInfo extends KmdfFunc {
  KmdfWdfInterruptGetInfo() { this.getName().matches("WdfInterruptGetInfo") }
}

class KmdfWdfInterruptSetPolicy extends KmdfFunc {
  KmdfWdfInterruptSetPolicy() { this.getName().matches("WdfInterruptSetPolicy") }
}

class KmdfWdfInterruptSetExtendedPolicy extends KmdfFunc {
  KmdfWdfInterruptSetExtendedPolicy() { this.getName().matches("WdfInterruptSetExtendedPolicy") }
}

class KmdfWdfInterruptGetDevice extends KmdfFunc {
  KmdfWdfInterruptGetDevice() { this.getName().matches("WdfInterruptGetDevice") }
}

class KmdfWdfInterruptTryToAcquireLock extends KmdfFunc {
  KmdfWdfInterruptTryToAcquireLock() { this.getName().matches("WdfInterruptTryToAcquireLock") }
}

class KmdfWdfInterruptReportActive extends KmdfFunc {
  KmdfWdfInterruptReportActive() { this.getName().matches("WdfInterruptReportActive") }
}

class KmdfWdfInterruptReportInactive extends KmdfFunc {
  KmdfWdfInterruptReportInactive() { this.getName().matches("WdfInterruptReportInactive") }
}

class KmdfWdfIoQueueCreate extends KmdfFunc {
  KmdfWdfIoQueueCreate() { this.getName().matches("WdfIoQueueCreate") }
}

class KmdfWdfIoQueueGetState extends KmdfFunc {
  KmdfWdfIoQueueGetState() { this.getName().matches("WdfIoQueueGetState") }
}

class KmdfWdfIoQueueStart extends KmdfFunc {
  KmdfWdfIoQueueStart() { this.getName().matches("WdfIoQueueStart") }
}

class KmdfWdfIoQueueStop extends KmdfFunc {
  KmdfWdfIoQueueStop() { this.getName().matches("WdfIoQueueStop") }
}

class KmdfWdfIoQueueStopSynchronously extends KmdfFunc {
  KmdfWdfIoQueueStopSynchronously() { this.getName().matches("WdfIoQueueStopSynchronously") }
}

class KmdfWdfIoQueueGetDevice extends KmdfFunc {
  KmdfWdfIoQueueGetDevice() { this.getName().matches("WdfIoQueueGetDevice") }
}

class KmdfWdfIoQueueRetrieveNextRequest extends KmdfFunc {
  KmdfWdfIoQueueRetrieveNextRequest() { this.getName().matches("WdfIoQueueRetrieveNextRequest") }
}

class KmdfWdfIoQueueRetrieveRequestByFileObject extends KmdfFunc {
  KmdfWdfIoQueueRetrieveRequestByFileObject() {
    this.getName().matches("WdfIoQueueRetrieveRequestByFileObject")
  }
}

class KmdfWdfIoQueueFindRequest extends KmdfFunc {
  KmdfWdfIoQueueFindRequest() { this.getName().matches("WdfIoQueueFindRequest") }
}

class KmdfWdfIoQueueRetrieveFoundRequest extends KmdfFunc {
  KmdfWdfIoQueueRetrieveFoundRequest() { this.getName().matches("WdfIoQueueRetrieveFoundRequest") }
}

class KmdfWdfIoQueueDrainSynchronously extends KmdfFunc {
  KmdfWdfIoQueueDrainSynchronously() { this.getName().matches("WdfIoQueueDrainSynchronously") }
}

class KmdfWdfIoQueueDrain extends KmdfFunc {
  KmdfWdfIoQueueDrain() { this.getName().matches("WdfIoQueueDrain") }
}

class KmdfWdfIoQueuePurgeSynchronously extends KmdfFunc {
  KmdfWdfIoQueuePurgeSynchronously() { this.getName().matches("WdfIoQueuePurgeSynchronously") }
}

class KmdfWdfIoQueuePurge extends KmdfFunc {
  KmdfWdfIoQueuePurge() { this.getName().matches("WdfIoQueuePurge") }
}

class KmdfWdfIoQueueReadyNotify extends KmdfFunc {
  KmdfWdfIoQueueReadyNotify() { this.getName().matches("WdfIoQueueReadyNotify") }
}

class KmdfWdfIoQueueAssignForwardProgressPolicy extends KmdfFunc {
  KmdfWdfIoQueueAssignForwardProgressPolicy() {
    this.getName().matches("WdfIoQueueAssignForwardProgressPolicy")
  }
}

class KmdfWdfIoQueueStopAndPurge extends KmdfFunc {
  KmdfWdfIoQueueStopAndPurge() { this.getName().matches("WdfIoQueueStopAndPurge") }
}

class KmdfWdfIoQueueStopAndPurgeSynchronously extends KmdfFunc {
  KmdfWdfIoQueueStopAndPurgeSynchronously() {
    this.getName().matches("WdfIoQueueStopAndPurgeSynchronously")
  }
}

class KmdfWdfIoTargetCreate extends KmdfFunc {
  KmdfWdfIoTargetCreate() { this.getName().matches("WdfIoTargetCreate") }
}

class KmdfWdfIoTargetOpen extends KmdfFunc {
  KmdfWdfIoTargetOpen() { this.getName().matches("WdfIoTargetOpen") }
}

class KmdfWdfIoTargetCloseForQueryRemove extends KmdfFunc {
  KmdfWdfIoTargetCloseForQueryRemove() { this.getName().matches("WdfIoTargetCloseForQueryRemove") }
}

class KmdfWdfIoTargetClose extends KmdfFunc {
  KmdfWdfIoTargetClose() { this.getName().matches("WdfIoTargetClose") }
}

class KmdfWdfIoTargetStart extends KmdfFunc {
  KmdfWdfIoTargetStart() { this.getName().matches("WdfIoTargetStart") }
}

class KmdfWdfIoTargetStop extends KmdfFunc {
  KmdfWdfIoTargetStop() { this.getName().matches("WdfIoTargetStop") }
}

class KmdfWdfIoTargetPurge extends KmdfFunc {
  KmdfWdfIoTargetPurge() { this.getName().matches("WdfIoTargetPurge") }
}

class KmdfWdfIoTargetGetState extends KmdfFunc {
  KmdfWdfIoTargetGetState() { this.getName().matches("WdfIoTargetGetState") }
}

class KmdfWdfIoTargetGetDevice extends KmdfFunc {
  KmdfWdfIoTargetGetDevice() { this.getName().matches("WdfIoTargetGetDevice") }
}

class KmdfWdfIoTargetQueryTargetProperty extends KmdfFunc {
  KmdfWdfIoTargetQueryTargetProperty() { this.getName().matches("WdfIoTargetQueryTargetProperty") }
}

class KmdfWdfIoTargetAllocAndQueryTargetProperty extends KmdfFunc {
  KmdfWdfIoTargetAllocAndQueryTargetProperty() {
    this.getName().matches("WdfIoTargetAllocAndQueryTargetProperty")
  }
}

class KmdfWdfIoTargetQueryForInterface extends KmdfFunc {
  KmdfWdfIoTargetQueryForInterface() { this.getName().matches("WdfIoTargetQueryForInterface") }
}

class KmdfWdfIoTargetWdmGetTargetDeviceObject extends KmdfFunc {
  KmdfWdfIoTargetWdmGetTargetDeviceObject() {
    this.getName().matches("WdfIoTargetWdmGetTargetDeviceObject")
  }
}

class KmdfWdfIoTargetWdmGetTargetPhysicalDevice extends KmdfFunc {
  KmdfWdfIoTargetWdmGetTargetPhysicalDevice() {
    this.getName().matches("WdfIoTargetWdmGetTargetPhysicalDevice")
  }
}

class KmdfWdfIoTargetWdmGetTargetFileObject extends KmdfFunc {
  KmdfWdfIoTargetWdmGetTargetFileObject() {
    this.getName().matches("WdfIoTargetWdmGetTargetFileObject")
  }
}

class KmdfWdfIoTargetWdmGetTargetFileHandle extends KmdfFunc {
  KmdfWdfIoTargetWdmGetTargetFileHandle() {
    this.getName().matches("WdfIoTargetWdmGetTargetFileHandle")
  }
}

class KmdfWdfIoTargetSendReadSynchronously extends KmdfFunc {
  KmdfWdfIoTargetSendReadSynchronously() {
    this.getName().matches("WdfIoTargetSendReadSynchronously")
  }
}

class KmdfWdfIoTargetFormatRequestForRead extends KmdfFunc {
  KmdfWdfIoTargetFormatRequestForRead() {
    this.getName().matches("WdfIoTargetFormatRequestForRead")
  }
}

class KmdfWdfIoTargetSendWriteSynchronously extends KmdfFunc {
  KmdfWdfIoTargetSendWriteSynchronously() {
    this.getName().matches("WdfIoTargetSendWriteSynchronously")
  }
}

class KmdfWdfIoTargetFormatRequestForWrite extends KmdfFunc {
  KmdfWdfIoTargetFormatRequestForWrite() {
    this.getName().matches("WdfIoTargetFormatRequestForWrite")
  }
}

class KmdfWdfIoTargetSendIoctlSynchronously extends KmdfFunc {
  KmdfWdfIoTargetSendIoctlSynchronously() {
    this.getName().matches("WdfIoTargetSendIoctlSynchronously")
  }
}

class KmdfWdfIoTargetFormatRequestForIoctl extends KmdfFunc {
  KmdfWdfIoTargetFormatRequestForIoctl() {
    this.getName().matches("WdfIoTargetFormatRequestForIoctl")
  }
}

class KmdfWdfIoTargetSendInternalIoctlSynchronously extends KmdfFunc {
  KmdfWdfIoTargetSendInternalIoctlSynchronously() {
    this.getName().matches("WdfIoTargetSendInternalIoctlSynchronously")
  }
}

class KmdfWdfIoTargetFormatRequestForInternalIoctl extends KmdfFunc {
  KmdfWdfIoTargetFormatRequestForInternalIoctl() {
    this.getName().matches("WdfIoTargetFormatRequestForInternalIoctl")
  }
}

class KmdfWdfIoTargetSendInternalIoctlOthersSynchronously extends KmdfFunc {
  KmdfWdfIoTargetSendInternalIoctlOthersSynchronously() {
    this.getName().matches("WdfIoTargetSendInternalIoctlOthersSynchronously")
  }
}

class KmdfWdfIoTargetFormatRequestForInternalIoctlOthers extends KmdfFunc {
  KmdfWdfIoTargetFormatRequestForInternalIoctlOthers() {
    this.getName().matches("WdfIoTargetFormatRequestForInternalIoctlOthers")
  }
}

class KmdfWdfMemoryCreate extends KmdfFunc {
  KmdfWdfMemoryCreate() { this.getName().matches("WdfMemoryCreate") }
}

class KmdfWdfMemoryCreatePreallocated extends KmdfFunc {
  KmdfWdfMemoryCreatePreallocated() { this.getName().matches("WdfMemoryCreatePreallocated") }
}

class KmdfWdfMemoryGetBuffer extends KmdfFunc {
  KmdfWdfMemoryGetBuffer() { this.getName().matches("WdfMemoryGetBuffer") }
}

class KmdfWdfMemoryAssignBuffer extends KmdfFunc {
  KmdfWdfMemoryAssignBuffer() { this.getName().matches("WdfMemoryAssignBuffer") }
}

class KmdfWdfMemoryCopyToBuffer extends KmdfFunc {
  KmdfWdfMemoryCopyToBuffer() { this.getName().matches("WdfMemoryCopyToBuffer") }
}

class KmdfWdfMemoryCopyFromBuffer extends KmdfFunc {
  KmdfWdfMemoryCopyFromBuffer() { this.getName().matches("WdfMemoryCopyFromBuffer") }
}

class KmdfWdfLookasideListCreate extends KmdfFunc {
  KmdfWdfLookasideListCreate() { this.getName().matches("WdfLookasideListCreate") }
}

class KmdfWdfMemoryCreateFromLookaside extends KmdfFunc {
  KmdfWdfMemoryCreateFromLookaside() { this.getName().matches("WdfMemoryCreateFromLookaside") }
}

class KmdfWdfDeviceMiniportCreate extends KmdfFunc {
  KmdfWdfDeviceMiniportCreate() { this.getName().matches("WdfDeviceMiniportCreate") }
}

class KmdfWdfDriverMiniportUnload extends KmdfFunc {
  KmdfWdfDriverMiniportUnload() { this.getName().matches("WdfDriverMiniportUnload") }
}

class KmdfWdfObjectGetTypedContextWorker extends KmdfFunc {
  KmdfWdfObjectGetTypedContextWorker() { this.getName().matches("WdfObjectGetTypedContextWorker") }
}

class KmdfWdfObjectAllocateContext extends KmdfFunc {
  KmdfWdfObjectAllocateContext() { this.getName().matches("WdfObjectAllocateContext") }
}

class KmdfWdfObjectContextGetObject extends KmdfFunc {
  KmdfWdfObjectContextGetObject() { this.getName().matches("WdfObjectContextGetObject") }
}

class KmdfWdfObjectReferenceActual extends KmdfFunc {
  KmdfWdfObjectReferenceActual() { this.getName().matches("WdfObjectReferenceActual") }
}

class KmdfWdfObjectDereferenceActual extends KmdfFunc {
  KmdfWdfObjectDereferenceActual() { this.getName().matches("WdfObjectDereferenceActual") }
}

class KmdfWdfObjectCreate extends KmdfFunc {
  KmdfWdfObjectCreate() { this.getName().matches("WdfObjectCreate") }
}

class KmdfWdfObjectDelete extends KmdfFunc {
  KmdfWdfObjectDelete() { this.getName().matches("WdfObjectDelete") }
}

class KmdfWdfObjectQuery extends KmdfFunc {
  KmdfWdfObjectQuery() { this.getName().matches("WdfObjectQuery") }
}

class KmdfWdfPdoInitAllocate extends KmdfFunc {
  KmdfWdfPdoInitAllocate() { this.getName().matches("WdfPdoInitAllocate") }
}

class KmdfWdfPdoInitSetEventCallbacks extends KmdfFunc {
  KmdfWdfPdoInitSetEventCallbacks() { this.getName().matches("WdfPdoInitSetEventCallbacks") }
}

class KmdfWdfPdoInitAssignDeviceID extends KmdfFunc {
  KmdfWdfPdoInitAssignDeviceID() { this.getName().matches("WdfPdoInitAssignDeviceID") }
}

class KmdfWdfPdoInitAssignInstanceID extends KmdfFunc {
  KmdfWdfPdoInitAssignInstanceID() { this.getName().matches("WdfPdoInitAssignInstanceID") }
}

class KmdfWdfPdoInitAddHardwareID extends KmdfFunc {
  KmdfWdfPdoInitAddHardwareID() { this.getName().matches("WdfPdoInitAddHardwareID") }
}

class KmdfWdfPdoInitAddCompatibleID extends KmdfFunc {
  KmdfWdfPdoInitAddCompatibleID() { this.getName().matches("WdfPdoInitAddCompatibleID") }
}

class KmdfWdfPdoInitAssignContainerID extends KmdfFunc {
  KmdfWdfPdoInitAssignContainerID() { this.getName().matches("WdfPdoInitAssignContainerID") }
}

class KmdfWdfPdoInitAddDeviceText extends KmdfFunc {
  KmdfWdfPdoInitAddDeviceText() { this.getName().matches("WdfPdoInitAddDeviceText") }
}

class KmdfWdfPdoInitSetDefaultLocale extends KmdfFunc {
  KmdfWdfPdoInitSetDefaultLocale() { this.getName().matches("WdfPdoInitSetDefaultLocale") }
}

class KmdfWdfPdoInitAssignRawDevice extends KmdfFunc {
  KmdfWdfPdoInitAssignRawDevice() { this.getName().matches("WdfPdoInitAssignRawDevice") }
}

class KmdfWdfPdoInitAllowForwardingRequestToParent extends KmdfFunc {
  KmdfWdfPdoInitAllowForwardingRequestToParent() {
    this.getName().matches("WdfPdoInitAllowForwardingRequestToParent")
  }
}

class KmdfWdfPdoMarkMissing extends KmdfFunc {
  KmdfWdfPdoMarkMissing() { this.getName().matches("WdfPdoMarkMissing") }
}

class KmdfWdfPdoRequestEject extends KmdfFunc {
  KmdfWdfPdoRequestEject() { this.getName().matches("WdfPdoRequestEject") }
}

class KmdfWdfPdoGetParent extends KmdfFunc {
  KmdfWdfPdoGetParent() { this.getName().matches("WdfPdoGetParent") }
}

class KmdfWdfPdoRetrieveIdentificationDescription extends KmdfFunc {
  KmdfWdfPdoRetrieveIdentificationDescription() {
    this.getName().matches("WdfPdoRetrieveIdentificationDescription")
  }
}

class KmdfWdfPdoRetrieveAddressDescription extends KmdfFunc {
  KmdfWdfPdoRetrieveAddressDescription() {
    this.getName().matches("WdfPdoRetrieveAddressDescription")
  }
}

class KmdfWdfPdoUpdateAddressDescription extends KmdfFunc {
  KmdfWdfPdoUpdateAddressDescription() { this.getName().matches("WdfPdoUpdateAddressDescription") }
}

class KmdfWdfPdoAddEjectionRelationsPhysicalDevice extends KmdfFunc {
  KmdfWdfPdoAddEjectionRelationsPhysicalDevice() {
    this.getName().matches("WdfPdoAddEjectionRelationsPhysicalDevice")
  }
}

class KmdfWdfPdoRemoveEjectionRelationsPhysicalDevice extends KmdfFunc {
  KmdfWdfPdoRemoveEjectionRelationsPhysicalDevice() {
    this.getName().matches("WdfPdoRemoveEjectionRelationsPhysicalDevice")
  }
}

class KmdfWdfPdoClearEjectionRelationsDevices extends KmdfFunc {
  KmdfWdfPdoClearEjectionRelationsDevices() {
    this.getName().matches("WdfPdoClearEjectionRelationsDevices")
  }
}

class KmdfWdfPdoInitRemovePowerDependencyOnParent extends KmdfFunc {
  KmdfWdfPdoInitRemovePowerDependencyOnParent() {
    this.getName().matches("WdfPdoInitRemovePowerDependencyOnParent")
  }
}

class KmdfWdfDeviceAddQueryInterface extends KmdfFunc {
  KmdfWdfDeviceAddQueryInterface() { this.getName().matches("WdfDeviceAddQueryInterface") }
}

class KmdfWdfDeviceInterfaceReferenceNoOp extends KmdfFunc {
  KmdfWdfDeviceInterfaceReferenceNoOp() {
    this.getName().matches("WdfDeviceInterfaceReferenceNoOp")
  }
}

class KmdfWdfDeviceInterfaceDereferenceNoOp extends KmdfFunc {
  KmdfWdfDeviceInterfaceDereferenceNoOp() {
    this.getName().matches("WdfDeviceInterfaceDereferenceNoOp")
  }
}

class KmdfWdfRegistryOpenKey extends KmdfFunc {
  KmdfWdfRegistryOpenKey() { this.getName().matches("WdfRegistryOpenKey") }
}

class KmdfWdfRegistryCreateKey extends KmdfFunc {
  KmdfWdfRegistryCreateKey() { this.getName().matches("WdfRegistryCreateKey") }
}

class KmdfWdfRegistryClose extends KmdfFunc {
  KmdfWdfRegistryClose() { this.getName().matches("WdfRegistryClose") }
}

class KmdfWdfRegistryWdmGetHandle extends KmdfFunc {
  KmdfWdfRegistryWdmGetHandle() { this.getName().matches("WdfRegistryWdmGetHandle") }
}

class KmdfWdfRegistryRemoveKey extends KmdfFunc {
  KmdfWdfRegistryRemoveKey() { this.getName().matches("WdfRegistryRemoveKey") }
}

class KmdfWdfRegistryRemoveValue extends KmdfFunc {
  KmdfWdfRegistryRemoveValue() { this.getName().matches("WdfRegistryRemoveValue") }
}

class KmdfWdfRegistryQueryValue extends KmdfFunc {
  KmdfWdfRegistryQueryValue() { this.getName().matches("WdfRegistryQueryValue") }
}

class KmdfWdfRegistryQueryMemory extends KmdfFunc {
  KmdfWdfRegistryQueryMemory() { this.getName().matches("WdfRegistryQueryMemory") }
}

class KmdfWdfRegistryQueryMultiString extends KmdfFunc {
  KmdfWdfRegistryQueryMultiString() { this.getName().matches("WdfRegistryQueryMultiString") }
}

class KmdfWdfRegistryQueryUnicodeString extends KmdfFunc {
  KmdfWdfRegistryQueryUnicodeString() { this.getName().matches("WdfRegistryQueryUnicodeString") }
}

class KmdfWdfRegistryQueryString extends KmdfFunc {
  KmdfWdfRegistryQueryString() { this.getName().matches("WdfRegistryQueryString") }
}

class KmdfWdfRegistryQueryULong extends KmdfFunc {
  KmdfWdfRegistryQueryULong() { this.getName().matches("WdfRegistryQueryULong") }
}

class KmdfWdfRegistryAssignValue extends KmdfFunc {
  KmdfWdfRegistryAssignValue() { this.getName().matches("WdfRegistryAssignValue") }
}

class KmdfWdfRegistryAssignMemory extends KmdfFunc {
  KmdfWdfRegistryAssignMemory() { this.getName().matches("WdfRegistryAssignMemory") }
}

class KmdfWdfRegistryAssignMultiString extends KmdfFunc {
  KmdfWdfRegistryAssignMultiString() { this.getName().matches("WdfRegistryAssignMultiString") }
}

class KmdfWdfRegistryAssignUnicodeString extends KmdfFunc {
  KmdfWdfRegistryAssignUnicodeString() { this.getName().matches("WdfRegistryAssignUnicodeString") }
}

class KmdfWdfRegistryAssignString extends KmdfFunc {
  KmdfWdfRegistryAssignString() { this.getName().matches("WdfRegistryAssignString") }
}

class KmdfWdfRegistryAssignULong extends KmdfFunc {
  KmdfWdfRegistryAssignULong() { this.getName().matches("WdfRegistryAssignULong") }
}

class KmdfWdfRequestCreate extends KmdfFunc {
  KmdfWdfRequestCreate() { this.getName().matches("WdfRequestCreate") }
}

class KmdfWdfRequestGetRequestorProcessId extends KmdfFunc {
  KmdfWdfRequestGetRequestorProcessId() {
    this.getName().matches("WdfRequestGetRequestorProcessId")
  }
}

class KmdfWdfRequestCreateFromIrp extends KmdfFunc {
  KmdfWdfRequestCreateFromIrp() { this.getName().matches("WdfRequestCreateFromIrp") }
}

class KmdfWdfRequestReuse extends KmdfFunc {
  KmdfWdfRequestReuse() { this.getName().matches("WdfRequestReuse") }
}

class KmdfWdfRequestChangeTarget extends KmdfFunc {
  KmdfWdfRequestChangeTarget() { this.getName().matches("WdfRequestChangeTarget") }
}

class KmdfWdfRequestFormatRequestUsingCurrentType extends KmdfFunc {
  KmdfWdfRequestFormatRequestUsingCurrentType() {
    this.getName().matches("WdfRequestFormatRequestUsingCurrentType")
  }
}

class KmdfWdfRequestWdmFormatUsingStackLocation extends KmdfFunc {
  KmdfWdfRequestWdmFormatUsingStackLocation() {
    this.getName().matches("WdfRequestWdmFormatUsingStackLocation")
  }
}

class KmdfWdfRequestSend extends KmdfFunc {
  KmdfWdfRequestSend() { this.getName().matches("WdfRequestSend") }
}

class KmdfWdfRequestGetStatus extends KmdfFunc {
  KmdfWdfRequestGetStatus() { this.getName().matches("WdfRequestGetStatus") }
}

class KmdfWdfRequestMarkCancelable extends KmdfFunc {
  KmdfWdfRequestMarkCancelable() { this.getName().matches("WdfRequestMarkCancelable") }
}

class KmdfWdfRequestMarkCancelableEx extends KmdfFunc {
  KmdfWdfRequestMarkCancelableEx() { this.getName().matches("WdfRequestMarkCancelableEx") }
}

class KmdfWdfRequestUnmarkCancelable extends KmdfFunc {
  KmdfWdfRequestUnmarkCancelable() { this.getName().matches("WdfRequestUnmarkCancelable") }
}

class KmdfWdfRequestIsCanceled extends KmdfFunc {
  KmdfWdfRequestIsCanceled() { this.getName().matches("WdfRequestIsCanceled") }
}

class KmdfWdfRequestCancelSentRequest extends KmdfFunc {
  KmdfWdfRequestCancelSentRequest() { this.getName().matches("WdfRequestCancelSentRequest") }
}

class KmdfWdfRequestIsFrom32BitProcess extends KmdfFunc {
  KmdfWdfRequestIsFrom32BitProcess() { this.getName().matches("WdfRequestIsFrom32BitProcess") }
}

class KmdfWdfRequestSetCompletionRoutine extends KmdfFunc {
  KmdfWdfRequestSetCompletionRoutine() { this.getName().matches("WdfRequestSetCompletionRoutine") }
}

class KmdfWdfRequestGetCompletionParams extends KmdfFunc {
  KmdfWdfRequestGetCompletionParams() { this.getName().matches("WdfRequestGetCompletionParams") }
}

class KmdfWdfRequestAllocateTimer extends KmdfFunc {
  KmdfWdfRequestAllocateTimer() { this.getName().matches("WdfRequestAllocateTimer") }
}

class KmdfWdfRequestComplete extends KmdfFunc {
  KmdfWdfRequestComplete() { this.getName().matches("WdfRequestComplete") }
}

class KmdfWdfRequestCompleteWithPriorityBoost extends KmdfFunc {
  KmdfWdfRequestCompleteWithPriorityBoost() {
    this.getName().matches("WdfRequestCompleteWithPriorityBoost")
  }
}

class KmdfWdfRequestCompleteWithInformation extends KmdfFunc {
  KmdfWdfRequestCompleteWithInformation() {
    this.getName().matches("WdfRequestCompleteWithInformation")
  }
}

class KmdfWdfRequestGetParameters extends KmdfFunc {
  KmdfWdfRequestGetParameters() { this.getName().matches("WdfRequestGetParameters") }
}

class KmdfWdfRequestRetrieveInputMemory extends KmdfFunc {
  KmdfWdfRequestRetrieveInputMemory() { this.getName().matches("WdfRequestRetrieveInputMemory") }
}

class KmdfWdfRequestRetrieveOutputMemory extends KmdfFunc {
  KmdfWdfRequestRetrieveOutputMemory() { this.getName().matches("WdfRequestRetrieveOutputMemory") }
}

class KmdfWdfRequestRetrieveInputBuffer extends KmdfFunc {
  KmdfWdfRequestRetrieveInputBuffer() { this.getName().matches("WdfRequestRetrieveInputBuffer") }
}

class KmdfWdfRequestRetrieveOutputBuffer extends KmdfFunc {
  KmdfWdfRequestRetrieveOutputBuffer() { this.getName().matches("WdfRequestRetrieveOutputBuffer") }
}

class KmdfWdfRequestRetrieveInputWdmMdl extends KmdfFunc {
  KmdfWdfRequestRetrieveInputWdmMdl() { this.getName().matches("WdfRequestRetrieveInputWdmMdl") }
}

class KmdfWdfRequestRetrieveOutputWdmMdl extends KmdfFunc {
  KmdfWdfRequestRetrieveOutputWdmMdl() { this.getName().matches("WdfRequestRetrieveOutputWdmMdl") }
}

class KmdfWdfRequestRetrieveUnsafeUserInputBuffer extends KmdfFunc {
  KmdfWdfRequestRetrieveUnsafeUserInputBuffer() {
    this.getName().matches("WdfRequestRetrieveUnsafeUserInputBuffer")
  }
}

class KmdfWdfRequestRetrieveUnsafeUserOutputBuffer extends KmdfFunc {
  KmdfWdfRequestRetrieveUnsafeUserOutputBuffer() {
    this.getName().matches("WdfRequestRetrieveUnsafeUserOutputBuffer")
  }
}

class KmdfWdfRequestSetInformation extends KmdfFunc {
  KmdfWdfRequestSetInformation() { this.getName().matches("WdfRequestSetInformation") }
}

class KmdfWdfRequestGetInformation extends KmdfFunc {
  KmdfWdfRequestGetInformation() { this.getName().matches("WdfRequestGetInformation") }
}

class KmdfWdfRequestGetFileObject extends KmdfFunc {
  KmdfWdfRequestGetFileObject() { this.getName().matches("WdfRequestGetFileObject") }
}

class KmdfWdfRequestProbeAndLockUserBufferForRead extends KmdfFunc {
  KmdfWdfRequestProbeAndLockUserBufferForRead() {
    this.getName().matches("WdfRequestProbeAndLockUserBufferForRead")
  }
}

class KmdfWdfRequestProbeAndLockUserBufferForWrite extends KmdfFunc {
  KmdfWdfRequestProbeAndLockUserBufferForWrite() {
    this.getName().matches("WdfRequestProbeAndLockUserBufferForWrite")
  }
}

class KmdfWdfRequestGetRequestorMode extends KmdfFunc {
  KmdfWdfRequestGetRequestorMode() { this.getName().matches("WdfRequestGetRequestorMode") }
}

class KmdfWdfRequestForwardToIoQueue extends KmdfFunc {
  KmdfWdfRequestForwardToIoQueue() { this.getName().matches("WdfRequestForwardToIoQueue") }
}

class KmdfWdfRequestGetIoQueue extends KmdfFunc {
  KmdfWdfRequestGetIoQueue() { this.getName().matches("WdfRequestGetIoQueue") }
}

class KmdfWdfRequestRequeue extends KmdfFunc {
  KmdfWdfRequestRequeue() { this.getName().matches("WdfRequestRequeue") }
}

class KmdfWdfRequestStopAcknowledge extends KmdfFunc {
  KmdfWdfRequestStopAcknowledge() { this.getName().matches("WdfRequestStopAcknowledge") }
}

class KmdfWdfRequestWdmGetIrp extends KmdfFunc {
  KmdfWdfRequestWdmGetIrp() { this.getName().matches("WdfRequestWdmGetIrp") }
}

class KmdfWdfRequestIsReserved extends KmdfFunc {
  KmdfWdfRequestIsReserved() { this.getName().matches("WdfRequestIsReserved") }
}

class KmdfWdfRequestForwardToParentDeviceIoQueue extends KmdfFunc {
  KmdfWdfRequestForwardToParentDeviceIoQueue() {
    this.getName().matches("WdfRequestForwardToParentDeviceIoQueue")
  }
}

class KmdfWdfIoResourceRequirementsListSetSlotNumber extends KmdfFunc {
  KmdfWdfIoResourceRequirementsListSetSlotNumber() {
    this.getName().matches("WdfIoResourceRequirementsListSetSlotNumber")
  }
}

class KmdfWdfIoResourceRequirementsListSetInterfaceType extends KmdfFunc {
  KmdfWdfIoResourceRequirementsListSetInterfaceType() {
    this.getName().matches("WdfIoResourceRequirementsListSetInterfaceType")
  }
}

class KmdfWdfIoResourceRequirementsListAppendIoResList extends KmdfFunc {
  KmdfWdfIoResourceRequirementsListAppendIoResList() {
    this.getName().matches("WdfIoResourceRequirementsListAppendIoResList")
  }
}

class KmdfWdfIoResourceRequirementsListInsertIoResList extends KmdfFunc {
  KmdfWdfIoResourceRequirementsListInsertIoResList() {
    this.getName().matches("WdfIoResourceRequirementsListInsertIoResList")
  }
}

class KmdfWdfIoResourceRequirementsListGetCount extends KmdfFunc {
  KmdfWdfIoResourceRequirementsListGetCount() {
    this.getName().matches("WdfIoResourceRequirementsListGetCount")
  }
}

class KmdfWdfIoResourceRequirementsListGetIoResList extends KmdfFunc {
  KmdfWdfIoResourceRequirementsListGetIoResList() {
    this.getName().matches("WdfIoResourceRequirementsListGetIoResList")
  }
}

class KmdfWdfIoResourceRequirementsListRemove extends KmdfFunc {
  KmdfWdfIoResourceRequirementsListRemove() {
    this.getName().matches("WdfIoResourceRequirementsListRemove")
  }
}

class KmdfWdfIoResourceRequirementsListRemoveByIoResList extends KmdfFunc {
  KmdfWdfIoResourceRequirementsListRemoveByIoResList() {
    this.getName().matches("WdfIoResourceRequirementsListRemoveByIoResList")
  }
}

class KmdfWdfIoResourceListCreate extends KmdfFunc {
  KmdfWdfIoResourceListCreate() { this.getName().matches("WdfIoResourceListCreate") }
}

class KmdfWdfIoResourceListAppendDescriptor extends KmdfFunc {
  KmdfWdfIoResourceListAppendDescriptor() {
    this.getName().matches("WdfIoResourceListAppendDescriptor")
  }
}

class KmdfWdfIoResourceListInsertDescriptor extends KmdfFunc {
  KmdfWdfIoResourceListInsertDescriptor() {
    this.getName().matches("WdfIoResourceListInsertDescriptor")
  }
}

class KmdfWdfIoResourceListUpdateDescriptor extends KmdfFunc {
  KmdfWdfIoResourceListUpdateDescriptor() {
    this.getName().matches("WdfIoResourceListUpdateDescriptor")
  }
}

class KmdfWdfIoResourceListGetCount extends KmdfFunc {
  KmdfWdfIoResourceListGetCount() { this.getName().matches("WdfIoResourceListGetCount") }
}

class KmdfWdfIoResourceListGetDescriptor extends KmdfFunc {
  KmdfWdfIoResourceListGetDescriptor() { this.getName().matches("WdfIoResourceListGetDescriptor") }
}

class KmdfWdfIoResourceListRemove extends KmdfFunc {
  KmdfWdfIoResourceListRemove() { this.getName().matches("WdfIoResourceListRemove") }
}

class KmdfWdfIoResourceListRemoveByDescriptor extends KmdfFunc {
  KmdfWdfIoResourceListRemoveByDescriptor() {
    this.getName().matches("WdfIoResourceListRemoveByDescriptor")
  }
}

class KmdfWdfCmResourceListAppendDescriptor extends KmdfFunc {
  KmdfWdfCmResourceListAppendDescriptor() {
    this.getName().matches("WdfCmResourceListAppendDescriptor")
  }
}

class KmdfWdfCmResourceListInsertDescriptor extends KmdfFunc {
  KmdfWdfCmResourceListInsertDescriptor() {
    this.getName().matches("WdfCmResourceListInsertDescriptor")
  }
}

class KmdfWdfCmResourceListGetCount extends KmdfFunc {
  KmdfWdfCmResourceListGetCount() { this.getName().matches("WdfCmResourceListGetCount") }
}

class KmdfWdfCmResourceListGetDescriptor extends KmdfFunc {
  KmdfWdfCmResourceListGetDescriptor() { this.getName().matches("WdfCmResourceListGetDescriptor") }
}

class KmdfWdfCmResourceListRemove extends KmdfFunc {
  KmdfWdfCmResourceListRemove() { this.getName().matches("WdfCmResourceListRemove") }
}

class KmdfWdfCmResourceListRemoveByDescriptor extends KmdfFunc {
  KmdfWdfCmResourceListRemoveByDescriptor() {
    this.getName().matches("WdfCmResourceListRemoveByDescriptor")
  }
}

class KmdfWdfStringCreate extends KmdfFunc {
  KmdfWdfStringCreate() { this.getName().matches("WdfStringCreate") }
}

class KmdfWdfStringGetUnicodeString extends KmdfFunc {
  KmdfWdfStringGetUnicodeString() { this.getName().matches("WdfStringGetUnicodeString") }
}

class KmdfWdfObjectAcquireLock extends KmdfFunc {
  KmdfWdfObjectAcquireLock() { this.getName().matches("WdfObjectAcquireLock") }
}

class KmdfWdfObjectReleaseLock extends KmdfFunc {
  KmdfWdfObjectReleaseLock() { this.getName().matches("WdfObjectReleaseLock") }
}

class KmdfWdfWaitLockCreate extends KmdfFunc {
  KmdfWdfWaitLockCreate() { this.getName().matches("WdfWaitLockCreate") }
}

class KmdfWdfWaitLockAcquire extends KmdfFunc {
  KmdfWdfWaitLockAcquire() { this.getName().matches("WdfWaitLockAcquire") }
}

class KmdfWdfWaitLockRelease extends KmdfFunc {
  KmdfWdfWaitLockRelease() { this.getName().matches("WdfWaitLockRelease") }
}

class KmdfWdfSpinLockCreate extends KmdfFunc {
  KmdfWdfSpinLockCreate() { this.getName().matches("WdfSpinLockCreate") }
}

class KmdfWdfSpinLockAcquire extends KmdfFunc {
  KmdfWdfSpinLockAcquire() { this.getName().matches("WdfSpinLockAcquire") }
}

class KmdfWdfSpinLockRelease extends KmdfFunc {
  KmdfWdfSpinLockRelease() { this.getName().matches("WdfSpinLockRelease") }
}

class KmdfWdfTimerCreate extends KmdfFunc {
  KmdfWdfTimerCreate() { this.getName().matches("WdfTimerCreate") }
}

class KmdfWdfTimerStart extends KmdfFunc {
  KmdfWdfTimerStart() { this.getName().matches("WdfTimerStart") }
}

class KmdfWdfTimerStop extends KmdfFunc {
  KmdfWdfTimerStop() { this.getName().matches("WdfTimerStop") }
}

class KmdfWdfTimerGetParentObject extends KmdfFunc {
  KmdfWdfTimerGetParentObject() { this.getName().matches("WdfTimerGetParentObject") }
}

class KmdfWdfUsbTargetDeviceGetIoTarget extends KmdfFunc {
  KmdfWdfUsbTargetDeviceGetIoTarget() { this.getName().matches("WdfUsbTargetDeviceGetIoTarget") }
}

class KmdfWdfUsbTargetPipeGetIoTarget extends KmdfFunc {
  KmdfWdfUsbTargetPipeGetIoTarget() { this.getName().matches("WdfUsbTargetPipeGetIoTarget") }
}

class KmdfWdfUsbTargetDeviceCreate extends KmdfFunc {
  KmdfWdfUsbTargetDeviceCreate() { this.getName().matches("WdfUsbTargetDeviceCreate") }
}

class KmdfWdfUsbTargetDeviceCreateWithParameters extends KmdfFunc {
  KmdfWdfUsbTargetDeviceCreateWithParameters() {
    this.getName().matches("WdfUsbTargetDeviceCreateWithParameters")
  }
}

class KmdfWdfUsbTargetDeviceRetrieveInformation extends KmdfFunc {
  KmdfWdfUsbTargetDeviceRetrieveInformation() {
    this.getName().matches("WdfUsbTargetDeviceRetrieveInformation")
  }
}

class KmdfWdfUsbTargetDeviceGetDeviceDescriptor extends KmdfFunc {
  KmdfWdfUsbTargetDeviceGetDeviceDescriptor() {
    this.getName().matches("WdfUsbTargetDeviceGetDeviceDescriptor")
  }
}

class KmdfWdfUsbTargetDeviceRetrieveConfigDescriptor extends KmdfFunc {
  KmdfWdfUsbTargetDeviceRetrieveConfigDescriptor() {
    this.getName().matches("WdfUsbTargetDeviceRetrieveConfigDescriptor")
  }
}

class KmdfWdfUsbTargetDeviceQueryString extends KmdfFunc {
  KmdfWdfUsbTargetDeviceQueryString() { this.getName().matches("WdfUsbTargetDeviceQueryString") }
}

class KmdfWdfUsbTargetDeviceAllocAndQueryString extends KmdfFunc {
  KmdfWdfUsbTargetDeviceAllocAndQueryString() {
    this.getName().matches("WdfUsbTargetDeviceAllocAndQueryString")
  }
}

class KmdfWdfUsbTargetDeviceFormatRequestForString extends KmdfFunc {
  KmdfWdfUsbTargetDeviceFormatRequestForString() {
    this.getName().matches("WdfUsbTargetDeviceFormatRequestForString")
  }
}

class KmdfWdfUsbTargetDeviceGetNumInterfaces extends KmdfFunc {
  KmdfWdfUsbTargetDeviceGetNumInterfaces() {
    this.getName().matches("WdfUsbTargetDeviceGetNumInterfaces")
  }
}

class KmdfWdfUsbTargetDeviceSelectConfig extends KmdfFunc {
  KmdfWdfUsbTargetDeviceSelectConfig() { this.getName().matches("WdfUsbTargetDeviceSelectConfig") }
}

class KmdfWdfUsbTargetDeviceWdmGetConfigurationHandle extends KmdfFunc {
  KmdfWdfUsbTargetDeviceWdmGetConfigurationHandle() {
    this.getName().matches("WdfUsbTargetDeviceWdmGetConfigurationHandle")
  }
}

class KmdfWdfUsbTargetDeviceRetrieveCurrentFrameNumber extends KmdfFunc {
  KmdfWdfUsbTargetDeviceRetrieveCurrentFrameNumber() {
    this.getName().matches("WdfUsbTargetDeviceRetrieveCurrentFrameNumber")
  }
}

class KmdfWdfUsbTargetDeviceSendControlTransferSynchronously extends KmdfFunc {
  KmdfWdfUsbTargetDeviceSendControlTransferSynchronously() {
    this.getName().matches("WdfUsbTargetDeviceSendControlTransferSynchronously")
  }
}

class KmdfWdfUsbTargetDeviceFormatRequestForControlTransfer extends KmdfFunc {
  KmdfWdfUsbTargetDeviceFormatRequestForControlTransfer() {
    this.getName().matches("WdfUsbTargetDeviceFormatRequestForControlTransfer")
  }
}

class KmdfWdfUsbTargetDeviceIsConnectedSynchronous extends KmdfFunc {
  KmdfWdfUsbTargetDeviceIsConnectedSynchronous() {
    this.getName().matches("WdfUsbTargetDeviceIsConnectedSynchronous")
  }
}

class KmdfWdfUsbTargetDeviceResetPortSynchronously extends KmdfFunc {
  KmdfWdfUsbTargetDeviceResetPortSynchronously() {
    this.getName().matches("WdfUsbTargetDeviceResetPortSynchronously")
  }
}

class KmdfWdfUsbTargetDeviceCyclePortSynchronously extends KmdfFunc {
  KmdfWdfUsbTargetDeviceCyclePortSynchronously() {
    this.getName().matches("WdfUsbTargetDeviceCyclePortSynchronously")
  }
}

class KmdfWdfUsbTargetDeviceFormatRequestForCyclePort extends KmdfFunc {
  KmdfWdfUsbTargetDeviceFormatRequestForCyclePort() {
    this.getName().matches("WdfUsbTargetDeviceFormatRequestForCyclePort")
  }
}

class KmdfWdfUsbTargetDeviceSendUrbSynchronously extends KmdfFunc {
  KmdfWdfUsbTargetDeviceSendUrbSynchronously() {
    this.getName().matches("WdfUsbTargetDeviceSendUrbSynchronously")
  }
}

class KmdfWdfUsbTargetDeviceFormatRequestForUrb extends KmdfFunc {
  KmdfWdfUsbTargetDeviceFormatRequestForUrb() {
    this.getName().matches("WdfUsbTargetDeviceFormatRequestForUrb")
  }
}

class KmdfWdfUsbTargetDeviceQueryUsbCapability extends KmdfFunc {
  KmdfWdfUsbTargetDeviceQueryUsbCapability() {
    this.getName().matches("WdfUsbTargetDeviceQueryUsbCapability")
  }
}

class KmdfWdfUsbTargetDeviceCreateUrb extends KmdfFunc {
  KmdfWdfUsbTargetDeviceCreateUrb() { this.getName().matches("WdfUsbTargetDeviceCreateUrb") }
}

class KmdfWdfUsbTargetDeviceCreateIsochUrb extends KmdfFunc {
  KmdfWdfUsbTargetDeviceCreateIsochUrb() {
    this.getName().matches("WdfUsbTargetDeviceCreateIsochUrb")
  }
}

class KmdfWdfUsbTargetPipeGetInformation extends KmdfFunc {
  KmdfWdfUsbTargetPipeGetInformation() { this.getName().matches("WdfUsbTargetPipeGetInformation") }
}

class KmdfWdfUsbTargetPipeIsInEndpoint extends KmdfFunc {
  KmdfWdfUsbTargetPipeIsInEndpoint() { this.getName().matches("WdfUsbTargetPipeIsInEndpoint") }
}

class KmdfWdfUsbTargetPipeIsOutEndpoint extends KmdfFunc {
  KmdfWdfUsbTargetPipeIsOutEndpoint() { this.getName().matches("WdfUsbTargetPipeIsOutEndpoint") }
}

class KmdfWdfUsbTargetPipeGetType extends KmdfFunc {
  KmdfWdfUsbTargetPipeGetType() { this.getName().matches("WdfUsbTargetPipeGetType") }
}

class KmdfWdfUsbTargetPipeSetNoMaximumPacketSizeCheck extends KmdfFunc {
  KmdfWdfUsbTargetPipeSetNoMaximumPacketSizeCheck() {
    this.getName().matches("WdfUsbTargetPipeSetNoMaximumPacketSizeCheck")
  }
}

class KmdfWdfUsbTargetPipeWriteSynchronously extends KmdfFunc {
  KmdfWdfUsbTargetPipeWriteSynchronously() {
    this.getName().matches("WdfUsbTargetPipeWriteSynchronously")
  }
}

class KmdfWdfUsbTargetPipeFormatRequestForWrite extends KmdfFunc {
  KmdfWdfUsbTargetPipeFormatRequestForWrite() {
    this.getName().matches("WdfUsbTargetPipeFormatRequestForWrite")
  }
}

class KmdfWdfUsbTargetPipeReadSynchronously extends KmdfFunc {
  KmdfWdfUsbTargetPipeReadSynchronously() {
    this.getName().matches("WdfUsbTargetPipeReadSynchronously")
  }
}

class KmdfWdfUsbTargetPipeFormatRequestForRead extends KmdfFunc {
  KmdfWdfUsbTargetPipeFormatRequestForRead() {
    this.getName().matches("WdfUsbTargetPipeFormatRequestForRead")
  }
}

class KmdfWdfUsbTargetPipeConfigContinuousReader extends KmdfFunc {
  KmdfWdfUsbTargetPipeConfigContinuousReader() {
    this.getName().matches("WdfUsbTargetPipeConfigContinuousReader")
  }
}

class KmdfWdfUsbTargetPipeAbortSynchronously extends KmdfFunc {
  KmdfWdfUsbTargetPipeAbortSynchronously() {
    this.getName().matches("WdfUsbTargetPipeAbortSynchronously")
  }
}

class KmdfWdfUsbTargetPipeFormatRequestForAbort extends KmdfFunc {
  KmdfWdfUsbTargetPipeFormatRequestForAbort() {
    this.getName().matches("WdfUsbTargetPipeFormatRequestForAbort")
  }
}

class KmdfWdfUsbTargetPipeResetSynchronously extends KmdfFunc {
  KmdfWdfUsbTargetPipeResetSynchronously() {
    this.getName().matches("WdfUsbTargetPipeResetSynchronously")
  }
}

class KmdfWdfUsbTargetPipeFormatRequestForReset extends KmdfFunc {
  KmdfWdfUsbTargetPipeFormatRequestForReset() {
    this.getName().matches("WdfUsbTargetPipeFormatRequestForReset")
  }
}

class KmdfWdfUsbTargetPipeSendUrbSynchronously extends KmdfFunc {
  KmdfWdfUsbTargetPipeSendUrbSynchronously() {
    this.getName().matches("WdfUsbTargetPipeSendUrbSynchronously")
  }
}

class KmdfWdfUsbTargetPipeFormatRequestForUrb extends KmdfFunc {
  KmdfWdfUsbTargetPipeFormatRequestForUrb() {
    this.getName().matches("WdfUsbTargetPipeFormatRequestForUrb")
  }
}

class KmdfWdfUsbInterfaceGetInterfaceNumber extends KmdfFunc {
  KmdfWdfUsbInterfaceGetInterfaceNumber() {
    this.getName().matches("WdfUsbInterfaceGetInterfaceNumber")
  }
}

class KmdfWdfUsbInterfaceGetNumEndpoints extends KmdfFunc {
  KmdfWdfUsbInterfaceGetNumEndpoints() { this.getName().matches("WdfUsbInterfaceGetNumEndpoints") }
}

class KmdfWdfUsbInterfaceGetDescriptor extends KmdfFunc {
  KmdfWdfUsbInterfaceGetDescriptor() { this.getName().matches("WdfUsbInterfaceGetDescriptor") }
}

class KmdfWdfUsbInterfaceGetNumSettings extends KmdfFunc {
  KmdfWdfUsbInterfaceGetNumSettings() { this.getName().matches("WdfUsbInterfaceGetNumSettings") }
}

class KmdfWdfUsbInterfaceSelectSetting extends KmdfFunc {
  KmdfWdfUsbInterfaceSelectSetting() { this.getName().matches("WdfUsbInterfaceSelectSetting") }
}

class KmdfWdfUsbInterfaceGetEndpointInformation extends KmdfFunc {
  KmdfWdfUsbInterfaceGetEndpointInformation() {
    this.getName().matches("WdfUsbInterfaceGetEndpointInformation")
  }
}

class KmdfWdfUsbTargetDeviceGetInterface extends KmdfFunc {
  KmdfWdfUsbTargetDeviceGetInterface() { this.getName().matches("WdfUsbTargetDeviceGetInterface") }
}

class KmdfWdfUsbInterfaceGetConfiguredSettingIndex extends KmdfFunc {
  KmdfWdfUsbInterfaceGetConfiguredSettingIndex() {
    this.getName().matches("WdfUsbInterfaceGetConfiguredSettingIndex")
  }
}

class KmdfWdfUsbInterfaceGetNumConfiguredPipes extends KmdfFunc {
  KmdfWdfUsbInterfaceGetNumConfiguredPipes() {
    this.getName().matches("WdfUsbInterfaceGetNumConfiguredPipes")
  }
}

class KmdfWdfUsbInterfaceGetConfiguredPipe extends KmdfFunc {
  KmdfWdfUsbInterfaceGetConfiguredPipe() {
    this.getName().matches("WdfUsbInterfaceGetConfiguredPipe")
  }
}

class KmdfWdfUsbTargetPipeWdmGetPipeHandle extends KmdfFunc {
  KmdfWdfUsbTargetPipeWdmGetPipeHandle() {
    this.getName().matches("WdfUsbTargetPipeWdmGetPipeHandle")
  }
}

class KmdfWdfVerifierDbgBreakPoint extends KmdfFunc {
  KmdfWdfVerifierDbgBreakPoint() { this.getName().matches("WdfVerifierDbgBreakPoint") }
}

class KmdfWdfVerifierKeBugCheck extends KmdfFunc {
  KmdfWdfVerifierKeBugCheck() { this.getName().matches("WdfVerifierKeBugCheck") }
}

class KmdfWdfGetTriageInfo extends KmdfFunc {
  KmdfWdfGetTriageInfo() { this.getName().matches("WdfGetTriageInfo") }
}

class KmdfWdfWmiProviderCreate extends KmdfFunc {
  KmdfWdfWmiProviderCreate() { this.getName().matches("WdfWmiProviderCreate") }
}

class KmdfWdfWmiProviderGetDevice extends KmdfFunc {
  KmdfWdfWmiProviderGetDevice() { this.getName().matches("WdfWmiProviderGetDevice") }
}

class KmdfWdfWmiProviderIsEnabled extends KmdfFunc {
  KmdfWdfWmiProviderIsEnabled() { this.getName().matches("WdfWmiProviderIsEnabled") }
}

class KmdfWdfWmiProviderGetTracingHandle extends KmdfFunc {
  KmdfWdfWmiProviderGetTracingHandle() { this.getName().matches("WdfWmiProviderGetTracingHandle") }
}

class KmdfWdfWmiInstanceCreate extends KmdfFunc {
  KmdfWdfWmiInstanceCreate() { this.getName().matches("WdfWmiInstanceCreate") }
}

class KmdfWdfWmiInstanceRegister extends KmdfFunc {
  KmdfWdfWmiInstanceRegister() { this.getName().matches("WdfWmiInstanceRegister") }
}

class KmdfWdfWmiInstanceDeregister extends KmdfFunc {
  KmdfWdfWmiInstanceDeregister() { this.getName().matches("WdfWmiInstanceDeregister") }
}

class KmdfWdfWmiInstanceGetDevice extends KmdfFunc {
  KmdfWdfWmiInstanceGetDevice() { this.getName().matches("WdfWmiInstanceGetDevice") }
}

class KmdfWdfWmiInstanceGetProvider extends KmdfFunc {
  KmdfWdfWmiInstanceGetProvider() { this.getName().matches("WdfWmiInstanceGetProvider") }
}

class KmdfWdfWmiInstanceFireEvent extends KmdfFunc {
  KmdfWdfWmiInstanceFireEvent() { this.getName().matches("WdfWmiInstanceFireEvent") }
}

class KmdfWdfWorkItemCreate extends KmdfFunc {
  KmdfWdfWorkItemCreate() { this.getName().matches("WdfWorkItemCreate") }
}

class KmdfWdfWorkItemEnqueue extends KmdfFunc {
  KmdfWdfWorkItemEnqueue() { this.getName().matches("WdfWorkItemEnqueue") }
}

class KmdfWdfWorkItemGetParentObject extends KmdfFunc {
  KmdfWdfWorkItemGetParentObject() { this.getName().matches("WdfWorkItemGetParentObject") }
}

class KmdfWdfWorkItemFlush extends KmdfFunc {
  KmdfWdfWorkItemFlush() { this.getName().matches("WdfWorkItemFlush") }
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
