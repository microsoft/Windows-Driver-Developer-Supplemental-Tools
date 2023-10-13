// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
import cpp

/** A typedef for standard KMDF callbacks.  This class is incomplete. */
class KmdfCallbackRoutineTypedef extends TypedefType {
  KmdfCallbackRoutineTypedef() {
    this.getName().matches("DRIVER_INITIALIZE") or
    this.getName().matches("EVT_WDF_DRIVER_DEVICE_ADD")
  }
}

/**
 * A KMDF callback routine, defined by having a typedef in its definition
 * that matches the standard KMDF callbacks.
 */
class KmdfCallbackRoutine extends Function {
  /** The typedef representing what callback this is. */
  KmdfCallbackRoutineTypedef callbackType;

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

// Functions


/**
 * The KMDF DriverEntry function.  KMDF enforces that the function is named DriverEntry.
 * Additionally, the driver may use the DRIVER_INIRIALIZE typedef.
 */
class KmdfDriverEntry extends Function {
  KmdfDriverEntry() { this.getName().matches("DriverEntry") }
}

class KmdfRtlAssert extends Function { 
  KmdfRtlAssert() { this.getName().matches("RtlAssert") }
}

class KmdfWdfChildListCreate extends Function { KmdfWdfChildListCreate() { this.getName().matches("WdfChildListCreate") }}
class KmdfWdfChildListGetDevice extends Function { KmdfWdfChildListGetDevice() { this.getName().matches("WdfChildListGetDevice") }}
class KmdfWdfChildListRetrievePdo extends Function { KmdfWdfChildListRetrievePdo() { this.getName().matches("WdfChildListRetrievePdo") }}
class KmdfWdfChildListRetrieveAddressDescription extends Function { KmdfWdfChildListRetrieveAddressDescription() { this.getName().matches("WdfChildListRetrieveAddressDescription") }}
class KmdfWdfChildListBeginScan extends Function { KmdfWdfChildListBeginScan() { this.getName().matches("WdfChildListBeginScan") }}
class KmdfWdfChildListEndScan extends Function { KmdfWdfChildListEndScan() { this.getName().matches("WdfChildListEndScan") }}
class KmdfWdfChildListBeginIteration extends Function { KmdfWdfChildListBeginIteration() { this.getName().matches("WdfChildListBeginIteration") }}
class KmdfWdfChildListRetrieveNextDevice extends Function { KmdfWdfChildListRetrieveNextDevice() { this.getName().matches("WdfChildListRetrieveNextDevice") }}
class KmdfWdfChildListEndIteration extends Function { KmdfWdfChildListEndIteration() { this.getName().matches("WdfChildListEndIteration") }}
class KmdfWdfChildListAddOrUpdateChildDescriptionAsPresent extends Function { KmdfWdfChildListAddOrUpdateChildDescriptionAsPresent() { this.getName().matches("WdfChildListAddOrUpdateChildDescriptionAsPresent") }}
class KmdfWdfChildListUpdateChildDescriptionAsMissing extends Function { KmdfWdfChildListUpdateChildDescriptionAsMissing() { this.getName().matches("WdfChildListUpdateChildDescriptionAsMissing") }}
class KmdfWdfChildListUpdateAllChildDescriptionsAsPresent extends Function { KmdfWdfChildListUpdateAllChildDescriptionsAsPresent() { this.getName().matches("WdfChildListUpdateAllChildDescriptionsAsPresent") }}
class KmdfWdfChildListRequestChildEject extends Function { KmdfWdfChildListRequestChildEject() { this.getName().matches("WdfChildListRequestChildEject") }}
class KmdfWdfCollectionCreate extends Function { KmdfWdfCollectionCreate() { this.getName().matches("WdfCollectionCreate") }}
class KmdfWdfCollectionGetCount extends Function { KmdfWdfCollectionGetCount() { this.getName().matches("WdfCollectionGetCount") }}
class KmdfWdfCollectionAdd extends Function { KmdfWdfCollectionAdd() { this.getName().matches("WdfCollectionAdd") }}
class KmdfWdfCollectionRemove extends Function { KmdfWdfCollectionRemove() { this.getName().matches("WdfCollectionRemove") }}
class KmdfWdfCollectionRemoveItem extends Function { KmdfWdfCollectionRemoveItem() { this.getName().matches("WdfCollectionRemoveItem") }}
class KmdfWdfCollectionGetItem extends Function { KmdfWdfCollectionGetItem() { this.getName().matches("WdfCollectionGetItem") }}
class KmdfWdfCollectionGetFirstItem extends Function { KmdfWdfCollectionGetFirstItem() { this.getName().matches("WdfCollectionGetFirstItem") }}
class KmdfWdfCollectionGetLastItem extends Function { KmdfWdfCollectionGetLastItem() { this.getName().matches("WdfCollectionGetLastItem") }}
class KmdfWdfCommonBufferCreate extends Function { KmdfWdfCommonBufferCreate() { this.getName().matches("WdfCommonBufferCreate") }}
class KmdfWdfCommonBufferCreateWithConfig extends Function { KmdfWdfCommonBufferCreateWithConfig() { this.getName().matches("WdfCommonBufferCreateWithConfig") }}
class KmdfWdfCommonBufferGetAlignedVirtualAddress extends Function { KmdfWdfCommonBufferGetAlignedVirtualAddress() { this.getName().matches("WdfCommonBufferGetAlignedVirtualAddress") }}
class KmdfWdfCommonBufferGetAlignedLogicalAddress extends Function { KmdfWdfCommonBufferGetAlignedLogicalAddress() { this.getName().matches("WdfCommonBufferGetAlignedLogicalAddress") }}
class KmdfWdfCommonBufferGetLength extends Function { KmdfWdfCommonBufferGetLength() { this.getName().matches("WdfCommonBufferGetLength") }}
class KmdfWdfCompanionTargetSendTaskSynchronously extends Function { KmdfWdfCompanionTargetSendTaskSynchronously() { this.getName().matches("WdfCompanionTargetSendTaskSynchronously") }}
class KmdfWdfCompanionTargetWdmGetCompanionProcess extends Function { KmdfWdfCompanionTargetWdmGetCompanionProcess() { this.getName().matches("WdfCompanionTargetWdmGetCompanionProcess") }}
class KmdfWdfControlDeviceInitAllocate extends Function { KmdfWdfControlDeviceInitAllocate() { this.getName().matches("WdfControlDeviceInitAllocate") }}
class KmdfWdfControlDeviceInitSetShutdownNotification extends Function { KmdfWdfControlDeviceInitSetShutdownNotification() { this.getName().matches("WdfControlDeviceInitSetShutdownNotification") }}
class KmdfWdfControlFinishInitializing extends Function { KmdfWdfControlFinishInitializing() { this.getName().matches("WdfControlFinishInitializing") }}
class KmdfWdfDevStateNormalize extends Function { KmdfWdfDevStateNormalize() { this.getName().matches("WdfDevStateNormalize") }}
class KmdfWdfDevStateIsNP extends Function { KmdfWdfDevStateIsNP() { this.getName().matches("WdfDevStateIsNP") }}
class KmdfRtlZeroMemoryPowerFrameworkSettings, extends Function { KmdfRtlZeroMemoryPowerFrameworkSettings,() { this.getName().matches("RtlZeroMemoryPowerFrameworkSettings,") }}
class KmdfWdfDeviceGetDeviceState extends Function { KmdfWdfDeviceGetDeviceState() { this.getName().matches("WdfDeviceGetDeviceState") }}
class KmdfWdfDeviceSetDeviceState extends Function { KmdfWdfDeviceSetDeviceState() { this.getName().matches("WdfDeviceSetDeviceState") }}
class KmdfWdfWdmDeviceGetWdfDeviceHandle extends Function { KmdfWdfWdmDeviceGetWdfDeviceHandle() { this.getName().matches("WdfWdmDeviceGetWdfDeviceHandle") }}
class KmdfWdfDeviceWdmGetDeviceObject extends Function { KmdfWdfDeviceWdmGetDeviceObject() { this.getName().matches("WdfDeviceWdmGetDeviceObject") }}
class KmdfWdfDeviceWdmGetAttachedDevice extends Function { KmdfWdfDeviceWdmGetAttachedDevice() { this.getName().matches("WdfDeviceWdmGetAttachedDevice") }}
class KmdfWdfDeviceWdmGetPhysicalDevice extends Function { KmdfWdfDeviceWdmGetPhysicalDevice() { this.getName().matches("WdfDeviceWdmGetPhysicalDevice") }}
class KmdfWdfDeviceWdmDispatchPreprocessedIrp extends Function { KmdfWdfDeviceWdmDispatchPreprocessedIrp() { this.getName().matches("WdfDeviceWdmDispatchPreprocessedIrp") }}
class KmdfWdfDeviceWdmDispatchIrp extends Function { KmdfWdfDeviceWdmDispatchIrp() { this.getName().matches("WdfDeviceWdmDispatchIrp") }}
class KmdfWdfDeviceWdmDispatchIrpToIoQueue extends Function { KmdfWdfDeviceWdmDispatchIrpToIoQueue() { this.getName().matches("WdfDeviceWdmDispatchIrpToIoQueue") }}
class KmdfWdfDeviceAddDependentUsageDeviceObject extends Function { KmdfWdfDeviceAddDependentUsageDeviceObject() { this.getName().matches("WdfDeviceAddDependentUsageDeviceObject") }}
class KmdfWdfDeviceRemoveDependentUsageDeviceObject extends Function { KmdfWdfDeviceRemoveDependentUsageDeviceObject() { this.getName().matches("WdfDeviceRemoveDependentUsageDeviceObject") }}
class KmdfWdfDeviceAddRemovalRelationsPhysicalDevice extends Function { KmdfWdfDeviceAddRemovalRelationsPhysicalDevice() { this.getName().matches("WdfDeviceAddRemovalRelationsPhysicalDevice") }}
class KmdfWdfDeviceRemoveRemovalRelationsPhysicalDevice extends Function { KmdfWdfDeviceRemoveRemovalRelationsPhysicalDevice() { this.getName().matches("WdfDeviceRemoveRemovalRelationsPhysicalDevice") }}
class KmdfWdfDeviceClearRemovalRelationsDevices extends Function { KmdfWdfDeviceClearRemovalRelationsDevices() { this.getName().matches("WdfDeviceClearRemovalRelationsDevices") }}
class KmdfWdfDeviceGetDriver extends Function { KmdfWdfDeviceGetDriver() { this.getName().matches("WdfDeviceGetDriver") }}
class KmdfWdfDeviceRetrieveDeviceName extends Function { KmdfWdfDeviceRetrieveDeviceName() { this.getName().matches("WdfDeviceRetrieveDeviceName") }}
class KmdfWdfDeviceAssignMofResourceName extends Function { KmdfWdfDeviceAssignMofResourceName() { this.getName().matches("WdfDeviceAssignMofResourceName") }}
class KmdfWdfDeviceGetIoTarget extends Function { KmdfWdfDeviceGetIoTarget() { this.getName().matches("WdfDeviceGetIoTarget") }}
class KmdfWdfDeviceGetDevicePnpState extends Function { KmdfWdfDeviceGetDevicePnpState() { this.getName().matches("WdfDeviceGetDevicePnpState") }}
class KmdfWdfDeviceGetDevicePowerState extends Function { KmdfWdfDeviceGetDevicePowerState() { this.getName().matches("WdfDeviceGetDevicePowerState") }}
class KmdfWdfDeviceGetDevicePowerPolicyState extends Function { KmdfWdfDeviceGetDevicePowerPolicyState() { this.getName().matches("WdfDeviceGetDevicePowerPolicyState") }}
class KmdfWdfDeviceAssignS0IdleSettings extends Function { KmdfWdfDeviceAssignS0IdleSettings() { this.getName().matches("WdfDeviceAssignS0IdleSettings") }}
class KmdfWdfDeviceAssignSxWakeSettings extends Function { KmdfWdfDeviceAssignSxWakeSettings() { this.getName().matches("WdfDeviceAssignSxWakeSettings") }}
class KmdfWdfDeviceOpenRegistryKey extends Function { KmdfWdfDeviceOpenRegistryKey() { this.getName().matches("WdfDeviceOpenRegistryKey") }}
class KmdfWdfDeviceOpenDevicemapKey extends Function { KmdfWdfDeviceOpenDevicemapKey() { this.getName().matches("WdfDeviceOpenDevicemapKey") }}
class KmdfWdfDeviceSetSpecialFileSupport extends Function { KmdfWdfDeviceSetSpecialFileSupport() { this.getName().matches("WdfDeviceSetSpecialFileSupport") }}
class KmdfWdfDeviceSetCharacteristics extends Function { KmdfWdfDeviceSetCharacteristics() { this.getName().matches("WdfDeviceSetCharacteristics") }}
class KmdfWdfDeviceGetCharacteristics extends Function { KmdfWdfDeviceGetCharacteristics() { this.getName().matches("WdfDeviceGetCharacteristics") }}
class KmdfWdfDeviceGetAlignmentRequirement extends Function { KmdfWdfDeviceGetAlignmentRequirement() { this.getName().matches("WdfDeviceGetAlignmentRequirement") }}
class KmdfWdfDeviceSetAlignmentRequirement extends Function { KmdfWdfDeviceSetAlignmentRequirement() { this.getName().matches("WdfDeviceSetAlignmentRequirement") }}
class KmdfWdfDeviceInitFree extends Function { KmdfWdfDeviceInitFree() { this.getName().matches("WdfDeviceInitFree") }}
class KmdfWdfDeviceInitSetPnpPowerEventCallbacks extends Function { KmdfWdfDeviceInitSetPnpPowerEventCallbacks() { this.getName().matches("WdfDeviceInitSetPnpPowerEventCallbacks") }}
class KmdfWdfDeviceInitSetPowerPolicyEventCallbacks extends Function { KmdfWdfDeviceInitSetPowerPolicyEventCallbacks() { this.getName().matches("WdfDeviceInitSetPowerPolicyEventCallbacks") }}
class KmdfWdfDeviceInitSetPowerPolicyOwnership extends Function { KmdfWdfDeviceInitSetPowerPolicyOwnership() { this.getName().matches("WdfDeviceInitSetPowerPolicyOwnership") }}
class KmdfWdfDeviceInitRegisterPnpStateChangeCallback extends Function { KmdfWdfDeviceInitRegisterPnpStateChangeCallback() { this.getName().matches("WdfDeviceInitRegisterPnpStateChangeCallback") }}
class KmdfWdfDeviceInitRegisterPowerStateChangeCallback extends Function { KmdfWdfDeviceInitRegisterPowerStateChangeCallback() { this.getName().matches("WdfDeviceInitRegisterPowerStateChangeCallback") }}
class KmdfWdfDeviceInitRegisterPowerPolicyStateChangeCallback extends Function { KmdfWdfDeviceInitRegisterPowerPolicyStateChangeCallback() { this.getName().matches("WdfDeviceInitRegisterPowerPolicyStateChangeCallback") }}
class KmdfWdfDeviceInitSetExclusive extends Function { KmdfWdfDeviceInitSetExclusive() { this.getName().matches("WdfDeviceInitSetExclusive") }}
class KmdfWdfDeviceInitSetIoType extends Function { KmdfWdfDeviceInitSetIoType() { this.getName().matches("WdfDeviceInitSetIoType") }}
class KmdfWdfDeviceInitSetPowerNotPageable extends Function { KmdfWdfDeviceInitSetPowerNotPageable() { this.getName().matches("WdfDeviceInitSetPowerNotPageable") }}
class KmdfWdfDeviceInitSetPowerPageable extends Function { KmdfWdfDeviceInitSetPowerPageable() { this.getName().matches("WdfDeviceInitSetPowerPageable") }}
class KmdfWdfDeviceInitSetPowerInrush extends Function { KmdfWdfDeviceInitSetPowerInrush() { this.getName().matches("WdfDeviceInitSetPowerInrush") }}
class KmdfWdfDeviceInitSetDeviceType extends Function { KmdfWdfDeviceInitSetDeviceType() { this.getName().matches("WdfDeviceInitSetDeviceType") }}
class KmdfWdfDeviceInitAssignName extends Function { KmdfWdfDeviceInitAssignName() { this.getName().matches("WdfDeviceInitAssignName") }}
class KmdfWdfDeviceInitAssignSDDLString extends Function { KmdfWdfDeviceInitAssignSDDLString() { this.getName().matches("WdfDeviceInitAssignSDDLString") }}
class KmdfWdfDeviceInitSetDeviceClass extends Function { KmdfWdfDeviceInitSetDeviceClass() { this.getName().matches("WdfDeviceInitSetDeviceClass") }}
class KmdfWdfDeviceInitSetCharacteristics extends Function { KmdfWdfDeviceInitSetCharacteristics() { this.getName().matches("WdfDeviceInitSetCharacteristics") }}
class KmdfWdfDeviceInitSetFileObjectConfig extends Function { KmdfWdfDeviceInitSetFileObjectConfig() { this.getName().matches("WdfDeviceInitSetFileObjectConfig") }}
class KmdfWdfDeviceInitSetRequestAttributes extends Function { KmdfWdfDeviceInitSetRequestAttributes() { this.getName().matches("WdfDeviceInitSetRequestAttributes") }}
class KmdfWdfDeviceInitAssignWdmIrpPreprocessCallback extends Function { KmdfWdfDeviceInitAssignWdmIrpPreprocessCallback() { this.getName().matches("WdfDeviceInitAssignWdmIrpPreprocessCallback") }}
class KmdfWdfDeviceInitSetIoInCallerContextCallback extends Function { KmdfWdfDeviceInitSetIoInCallerContextCallback() { this.getName().matches("WdfDeviceInitSetIoInCallerContextCallback") }}
class KmdfWdfDeviceInitSetRemoveLockOptions extends Function { KmdfWdfDeviceInitSetRemoveLockOptions() { this.getName().matches("WdfDeviceInitSetRemoveLockOptions") }}
class KmdfWdfDeviceCreate extends Function { KmdfWdfDeviceCreate() { this.getName().matches("WdfDeviceCreate") }}
class KmdfWdfDeviceSetStaticStopRemove extends Function { KmdfWdfDeviceSetStaticStopRemove() { this.getName().matches("WdfDeviceSetStaticStopRemove") }}
class KmdfWdfDeviceCreateDeviceInterface extends Function { KmdfWdfDeviceCreateDeviceInterface() { this.getName().matches("WdfDeviceCreateDeviceInterface") }}
class KmdfWdfDeviceSetDeviceInterfaceState extends Function { KmdfWdfDeviceSetDeviceInterfaceState() { this.getName().matches("WdfDeviceSetDeviceInterfaceState") }}
class KmdfWdfDeviceSetDeviceInterfaceStateEx extends Function { KmdfWdfDeviceSetDeviceInterfaceStateEx() { this.getName().matches("WdfDeviceSetDeviceInterfaceStateEx") }}
class KmdfWdfDeviceRetrieveDeviceInterfaceString extends Function { KmdfWdfDeviceRetrieveDeviceInterfaceString() { this.getName().matches("WdfDeviceRetrieveDeviceInterfaceString") }}
class KmdfWdfDeviceCreateSymbolicLink extends Function { KmdfWdfDeviceCreateSymbolicLink() { this.getName().matches("WdfDeviceCreateSymbolicLink") }}
class KmdfWdfDeviceQueryProperty extends Function { KmdfWdfDeviceQueryProperty() { this.getName().matches("WdfDeviceQueryProperty") }}
class KmdfWdfDeviceAllocAndQueryProperty extends Function { KmdfWdfDeviceAllocAndQueryProperty() { this.getName().matches("WdfDeviceAllocAndQueryProperty") }}
class KmdfWdfDeviceSetPnpCapabilities extends Function { KmdfWdfDeviceSetPnpCapabilities() { this.getName().matches("WdfDeviceSetPnpCapabilities") }}
class KmdfWdfDeviceSetPowerCapabilities extends Function { KmdfWdfDeviceSetPowerCapabilities() { this.getName().matches("WdfDeviceSetPowerCapabilities") }}
class KmdfWdfDeviceSetBusInformationForChildren extends Function { KmdfWdfDeviceSetBusInformationForChildren() { this.getName().matches("WdfDeviceSetBusInformationForChildren") }}
class KmdfWdfDeviceIndicateWakeStatus extends Function { KmdfWdfDeviceIndicateWakeStatus() { this.getName().matches("WdfDeviceIndicateWakeStatus") }}
class KmdfWdfDeviceSetFailed extends Function { KmdfWdfDeviceSetFailed() { this.getName().matches("WdfDeviceSetFailed") }}
class KmdfWdfDeviceStopIdleNoTrack extends Function { KmdfWdfDeviceStopIdleNoTrack() { this.getName().matches("WdfDeviceStopIdleNoTrack") }}
class KmdfWdfDeviceResumeIdleNoTrack extends Function { KmdfWdfDeviceResumeIdleNoTrack() { this.getName().matches("WdfDeviceResumeIdleNoTrack") }}
class KmdfWdfDeviceStopIdleActual extends Function { KmdfWdfDeviceStopIdleActual() { this.getName().matches("WdfDeviceStopIdleActual") }}
class KmdfWdfDeviceResumeIdleActual extends Function { KmdfWdfDeviceResumeIdleActual() { this.getName().matches("WdfDeviceResumeIdleActual") }}
class KmdfWdfDeviceGetFileObject extends Function { KmdfWdfDeviceGetFileObject() { this.getName().matches("WdfDeviceGetFileObject") }}
class KmdfWdfDeviceEnqueueRequest extends Function { KmdfWdfDeviceEnqueueRequest() { this.getName().matches("WdfDeviceEnqueueRequest") }}
class KmdfWdfDeviceGetDefaultQueue extends Function { KmdfWdfDeviceGetDefaultQueue() { this.getName().matches("WdfDeviceGetDefaultQueue") }}
class KmdfWdfDeviceConfigureRequestDispatching extends Function { KmdfWdfDeviceConfigureRequestDispatching() { this.getName().matches("WdfDeviceConfigureRequestDispatching") }}
class KmdfWdfDeviceConfigureWdmIrpDispatchCallback extends Function { KmdfWdfDeviceConfigureWdmIrpDispatchCallback() { this.getName().matches("WdfDeviceConfigureWdmIrpDispatchCallback") }}
class KmdfWdfDeviceGetSystemPowerAction extends Function { KmdfWdfDeviceGetSystemPowerAction() { this.getName().matches("WdfDeviceGetSystemPowerAction") }}
class KmdfWdfDeviceWdmAssignPowerFrameworkSettings extends Function { KmdfWdfDeviceWdmAssignPowerFrameworkSettings() { this.getName().matches("WdfDeviceWdmAssignPowerFrameworkSettings") }}
class KmdfWdfDeviceInitSetReleaseHardwareOrderOnFailure extends Function { KmdfWdfDeviceInitSetReleaseHardwareOrderOnFailure() { this.getName().matches("WdfDeviceInitSetReleaseHardwareOrderOnFailure") }}
class KmdfWdfDeviceInitSetIoTypeEx extends Function { KmdfWdfDeviceInitSetIoTypeEx() { this.getName().matches("WdfDeviceInitSetIoTypeEx") }}
class KmdfWdfDeviceQueryPropertyEx extends Function { KmdfWdfDeviceQueryPropertyEx() { this.getName().matches("WdfDeviceQueryPropertyEx") }}
class KmdfWdfDeviceAllocAndQueryPropertyEx extends Function { KmdfWdfDeviceAllocAndQueryPropertyEx() { this.getName().matches("WdfDeviceAllocAndQueryPropertyEx") }}
class KmdfWdfDeviceAssignProperty extends Function { KmdfWdfDeviceAssignProperty() { this.getName().matches("WdfDeviceAssignProperty") }}
class KmdfWdfDeviceRetrieveCompanionTarget extends Function { KmdfWdfDeviceRetrieveCompanionTarget() { this.getName().matches("WdfDeviceRetrieveCompanionTarget") }}
class KmdfWdfDmaEnablerCreate extends Function { KmdfWdfDmaEnablerCreate() { this.getName().matches("WdfDmaEnablerCreate") }}
class KmdfWdfDmaEnablerConfigureSystemProfile extends Function { KmdfWdfDmaEnablerConfigureSystemProfile() { this.getName().matches("WdfDmaEnablerConfigureSystemProfile") }}
class KmdfWdfDmaEnablerGetMaximumLength extends Function { KmdfWdfDmaEnablerGetMaximumLength() { this.getName().matches("WdfDmaEnablerGetMaximumLength") }}
class KmdfWdfDmaEnablerGetMaximumScatterGatherElements extends Function { KmdfWdfDmaEnablerGetMaximumScatterGatherElements() { this.getName().matches("WdfDmaEnablerGetMaximumScatterGatherElements") }}
class KmdfWdfDmaEnablerSetMaximumScatterGatherElements extends Function { KmdfWdfDmaEnablerSetMaximumScatterGatherElements() { this.getName().matches("WdfDmaEnablerSetMaximumScatterGatherElements") }}
class KmdfWdfDmaEnablerGetFragmentLength extends Function { KmdfWdfDmaEnablerGetFragmentLength() { this.getName().matches("WdfDmaEnablerGetFragmentLength") }}
class KmdfWdfDmaEnablerWdmGetDmaAdapter extends Function { KmdfWdfDmaEnablerWdmGetDmaAdapter() { this.getName().matches("WdfDmaEnablerWdmGetDmaAdapter") }}
class KmdfWdfDmaTransactionCreate extends Function { KmdfWdfDmaTransactionCreate() { this.getName().matches("WdfDmaTransactionCreate") }}
class KmdfWdfDmaTransactionInitialize extends Function { KmdfWdfDmaTransactionInitialize() { this.getName().matches("WdfDmaTransactionInitialize") }}
class KmdfWdfDmaTransactionInitializeUsingOffset extends Function { KmdfWdfDmaTransactionInitializeUsingOffset() { this.getName().matches("WdfDmaTransactionInitializeUsingOffset") }}
class KmdfWdfDmaTransactionInitializeUsingRequest extends Function { KmdfWdfDmaTransactionInitializeUsingRequest() { this.getName().matches("WdfDmaTransactionInitializeUsingRequest") }}
class KmdfWdfDmaTransactionExecute extends Function { KmdfWdfDmaTransactionExecute() { this.getName().matches("WdfDmaTransactionExecute") }}
class KmdfWdfDmaTransactionRelease extends Function { KmdfWdfDmaTransactionRelease() { this.getName().matches("WdfDmaTransactionRelease") }}
class KmdfWdfDmaTransactionDmaCompleted extends Function { KmdfWdfDmaTransactionDmaCompleted() { this.getName().matches("WdfDmaTransactionDmaCompleted") }}
class KmdfWdfDmaTransactionDmaCompletedWithLength extends Function { KmdfWdfDmaTransactionDmaCompletedWithLength() { this.getName().matches("WdfDmaTransactionDmaCompletedWithLength") }}
class KmdfWdfDmaTransactionDmaCompletedFinal extends Function { KmdfWdfDmaTransactionDmaCompletedFinal() { this.getName().matches("WdfDmaTransactionDmaCompletedFinal") }}
class KmdfWdfDmaTransactionGetBytesTransferred extends Function { KmdfWdfDmaTransactionGetBytesTransferred() { this.getName().matches("WdfDmaTransactionGetBytesTransferred") }}
class KmdfWdfDmaTransactionSetMaximumLength extends Function { KmdfWdfDmaTransactionSetMaximumLength() { this.getName().matches("WdfDmaTransactionSetMaximumLength") }}
class KmdfWdfDmaTransactionSetSingleTransferRequirement extends Function { KmdfWdfDmaTransactionSetSingleTransferRequirement() { this.getName().matches("WdfDmaTransactionSetSingleTransferRequirement") }}
class KmdfWdfDmaTransactionGetRequest extends Function { KmdfWdfDmaTransactionGetRequest() { this.getName().matches("WdfDmaTransactionGetRequest") }}
class KmdfWdfDmaTransactionGetCurrentDmaTransferLength extends Function { KmdfWdfDmaTransactionGetCurrentDmaTransferLength() { this.getName().matches("WdfDmaTransactionGetCurrentDmaTransferLength") }}
class KmdfWdfDmaTransactionGetDevice extends Function { KmdfWdfDmaTransactionGetDevice() { this.getName().matches("WdfDmaTransactionGetDevice") }}
class KmdfWdfDmaTransactionGetTransferInfo extends Function { KmdfWdfDmaTransactionGetTransferInfo() { this.getName().matches("WdfDmaTransactionGetTransferInfo") }}
class KmdfWdfDmaTransactionSetChannelConfigurationCallback extends Function { KmdfWdfDmaTransactionSetChannelConfigurationCallback() { this.getName().matches("WdfDmaTransactionSetChannelConfigurationCallback") }}
class KmdfWdfDmaTransactionSetTransferCompleteCallback extends Function { KmdfWdfDmaTransactionSetTransferCompleteCallback() { this.getName().matches("WdfDmaTransactionSetTransferCompleteCallback") }}
class KmdfWdfDmaTransactionSetImmediateExecution extends Function { KmdfWdfDmaTransactionSetImmediateExecution() { this.getName().matches("WdfDmaTransactionSetImmediateExecution") }}
class KmdfWdfDmaTransactionAllocateResources extends Function { KmdfWdfDmaTransactionAllocateResources() { this.getName().matches("WdfDmaTransactionAllocateResources") }}
class KmdfWdfDmaTransactionSetDeviceAddressOffset extends Function { KmdfWdfDmaTransactionSetDeviceAddressOffset() { this.getName().matches("WdfDmaTransactionSetDeviceAddressOffset") }}
class KmdfWdfDmaTransactionFreeResources extends Function { KmdfWdfDmaTransactionFreeResources() { this.getName().matches("WdfDmaTransactionFreeResources") }}
class KmdfWdfDmaTransactionCancel extends Function { KmdfWdfDmaTransactionCancel() { this.getName().matches("WdfDmaTransactionCancel") }}
class KmdfWdfDmaTransactionWdmGetTransferContext extends Function { KmdfWdfDmaTransactionWdmGetTransferContext() { this.getName().matches("WdfDmaTransactionWdmGetTransferContext") }}
class KmdfWdfDmaTransactionStopSystemTransfer extends Function { KmdfWdfDmaTransactionStopSystemTransfer() { this.getName().matches("WdfDmaTransactionStopSystemTransfer") }}
class KmdfWdfDpcCreate extends Function { KmdfWdfDpcCreate() { this.getName().matches("WdfDpcCreate") }}
class KmdfWdfDpcEnqueue extends Function { KmdfWdfDpcEnqueue() { this.getName().matches("WdfDpcEnqueue") }}
class KmdfWdfDpcCancel extends Function { KmdfWdfDpcCancel() { this.getName().matches("WdfDpcCancel") }}
class KmdfWdfDpcGetParentObject extends Function { KmdfWdfDpcGetParentObject() { this.getName().matches("WdfDpcGetParentObject") }}
class KmdfWdfDpcWdmGetDpc extends Function { KmdfWdfDpcWdmGetDpc() { this.getName().matches("WdfDpcWdmGetDpc") }}
class KmdfWdfGetDriver extends Function { KmdfWdfGetDriver() { this.getName().matches("WdfGetDriver") }}
class KmdfWdfDriverCreate extends Function { KmdfWdfDriverCreate() { this.getName().matches("WdfDriverCreate") }}
class KmdfWdfDriverGetRegistryPath extends Function { KmdfWdfDriverGetRegistryPath() { this.getName().matches("WdfDriverGetRegistryPath") }}
class KmdfWdfDriverWdmGetDriverObject extends Function { KmdfWdfDriverWdmGetDriverObject() { this.getName().matches("WdfDriverWdmGetDriverObject") }}
class KmdfWdfDriverOpenParametersRegistryKey extends Function { KmdfWdfDriverOpenParametersRegistryKey() { this.getName().matches("WdfDriverOpenParametersRegistryKey") }}
class KmdfWdfWdmDriverGetWdfDriverHandle extends Function { KmdfWdfWdmDriverGetWdfDriverHandle() { this.getName().matches("WdfWdmDriverGetWdfDriverHandle") }}
class KmdfWdfDriverRegisterTraceInfo extends Function { KmdfWdfDriverRegisterTraceInfo() { this.getName().matches("WdfDriverRegisterTraceInfo") }}
class KmdfWdfDriverRetrieveVersionString extends Function { KmdfWdfDriverRetrieveVersionString() { this.getName().matches("WdfDriverRetrieveVersionString") }}
class KmdfWdfDriverIsVersionAvailable extends Function { KmdfWdfDriverIsVersionAvailable() { this.getName().matches("WdfDriverIsVersionAvailable") }}
class KmdfWdfDriverErrorReportApiMissing extends Function { KmdfWdfDriverErrorReportApiMissing() { this.getName().matches("WdfDriverErrorReportApiMissing") }}
class KmdfWdfDriverOpenPersistentStateRegistryKey extends Function { KmdfWdfDriverOpenPersistentStateRegistryKey() { this.getName().matches("WdfDriverOpenPersistentStateRegistryKey") }}
class KmdfWdfFdoInitWdmGetPhysicalDevice extends Function { KmdfWdfFdoInitWdmGetPhysicalDevice() { this.getName().matches("WdfFdoInitWdmGetPhysicalDevice") }}
class KmdfWdfFdoInitOpenRegistryKey extends Function { KmdfWdfFdoInitOpenRegistryKey() { this.getName().matches("WdfFdoInitOpenRegistryKey") }}
class KmdfWdfFdoInitQueryProperty extends Function { KmdfWdfFdoInitQueryProperty() { this.getName().matches("WdfFdoInitQueryProperty") }}
class KmdfWdfFdoInitAllocAndQueryProperty extends Function { KmdfWdfFdoInitAllocAndQueryProperty() { this.getName().matches("WdfFdoInitAllocAndQueryProperty") }}
class KmdfWdfFdoInitQueryPropertyEx extends Function { KmdfWdfFdoInitQueryPropertyEx() { this.getName().matches("WdfFdoInitQueryPropertyEx") }}
class KmdfWdfFdoInitAllocAndQueryPropertyEx extends Function { KmdfWdfFdoInitAllocAndQueryPropertyEx() { this.getName().matches("WdfFdoInitAllocAndQueryPropertyEx") }}
class KmdfWdfFdoInitSetEventCallbacks extends Function { KmdfWdfFdoInitSetEventCallbacks() { this.getName().matches("WdfFdoInitSetEventCallbacks") }}
class KmdfWdfFdoInitSetFilter extends Function { KmdfWdfFdoInitSetFilter() { this.getName().matches("WdfFdoInitSetFilter") }}
class KmdfWdfFdoInitSetDefaultChildListConfig extends Function { KmdfWdfFdoInitSetDefaultChildListConfig() { this.getName().matches("WdfFdoInitSetDefaultChildListConfig") }}
class KmdfWdfFdoQueryForInterface extends Function { KmdfWdfFdoQueryForInterface() { this.getName().matches("WdfFdoQueryForInterface") }}
class KmdfWdfFdoGetDefaultChildList extends Function { KmdfWdfFdoGetDefaultChildList() { this.getName().matches("WdfFdoGetDefaultChildList") }}
class KmdfWdfFdoAddStaticChild extends Function { KmdfWdfFdoAddStaticChild() { this.getName().matches("WdfFdoAddStaticChild") }}
class KmdfWdfFdoLockStaticChildListForIteration extends Function { KmdfWdfFdoLockStaticChildListForIteration() { this.getName().matches("WdfFdoLockStaticChildListForIteration") }}
class KmdfWdfFdoRetrieveNextStaticChild extends Function { KmdfWdfFdoRetrieveNextStaticChild() { this.getName().matches("WdfFdoRetrieveNextStaticChild") }}
class KmdfWdfFdoUnlockStaticChildListFromIteration extends Function { KmdfWdfFdoUnlockStaticChildListFromIteration() { this.getName().matches("WdfFdoUnlockStaticChildListFromIteration") }}
class KmdfWdfFileObjectGetFileName extends Function { KmdfWdfFileObjectGetFileName() { this.getName().matches("WdfFileObjectGetFileName") }}
class KmdfWdfFileObjectGetFlags extends Function { KmdfWdfFileObjectGetFlags() { this.getName().matches("WdfFileObjectGetFlags") }}
class KmdfWdfFileObjectGetDevice extends Function { KmdfWdfFileObjectGetDevice() { this.getName().matches("WdfFileObjectGetDevice") }}
class KmdfWdfFileObjectGetInitiatorProcessId extends Function { KmdfWdfFileObjectGetInitiatorProcessId() { this.getName().matches("WdfFileObjectGetInitiatorProcessId") }}
class KmdfWdfFileObjectWdmGetFileObject extends Function { KmdfWdfFileObjectWdmGetFileObject() { this.getName().matches("WdfFileObjectWdmGetFileObject") }}
class KmdfWdfPreDeviceInstall extends Function { KmdfWdfPreDeviceInstall() { this.getName().matches("WdfPreDeviceInstall") }}
class KmdfWdfPreDeviceInstallEx extends Function { KmdfWdfPreDeviceInstallEx() { this.getName().matches("WdfPreDeviceInstallEx") }}
class KmdfWdfPostDeviceInstall extends Function { KmdfWdfPostDeviceInstall() { this.getName().matches("WdfPostDeviceInstall") }}
class KmdfWdfPreDeviceRemove extends Function { KmdfWdfPreDeviceRemove() { this.getName().matches("WdfPreDeviceRemove") }}
class KmdfWdfPostDeviceRemove extends Function { KmdfWdfPostDeviceRemove() { this.getName().matches("WdfPostDeviceRemove") }}
class KmdfWdfInterruptCreate extends Function { KmdfWdfInterruptCreate() { this.getName().matches("WdfInterruptCreate") }}
class KmdfWdfInterruptQueueDpcForIsr extends Function { KmdfWdfInterruptQueueDpcForIsr() { this.getName().matches("WdfInterruptQueueDpcForIsr") }}
class KmdfWdfInterruptQueueWorkItemForIsr extends Function { KmdfWdfInterruptQueueWorkItemForIsr() { this.getName().matches("WdfInterruptQueueWorkItemForIsr") }}
class KmdfWdfInterruptSynchronize extends Function { KmdfWdfInterruptSynchronize() { this.getName().matches("WdfInterruptSynchronize") }}
class KmdfWdfInterruptAcquireLock extends Function { KmdfWdfInterruptAcquireLock() { this.getName().matches("WdfInterruptAcquireLock") }}
class KmdfWdfInterruptReleaseLock extends Function { KmdfWdfInterruptReleaseLock() { this.getName().matches("WdfInterruptReleaseLock") }}
class KmdfWdfInterruptEnable extends Function { KmdfWdfInterruptEnable() { this.getName().matches("WdfInterruptEnable") }}
class KmdfWdfInterruptDisable extends Function { KmdfWdfInterruptDisable() { this.getName().matches("WdfInterruptDisable") }}
class KmdfWdfInterruptWdmGetInterrupt extends Function { KmdfWdfInterruptWdmGetInterrupt() { this.getName().matches("WdfInterruptWdmGetInterrupt") }}
class KmdfWdfInterruptGetInfo extends Function { KmdfWdfInterruptGetInfo() { this.getName().matches("WdfInterruptGetInfo") }}
class KmdfWdfInterruptSetPolicy extends Function { KmdfWdfInterruptSetPolicy() { this.getName().matches("WdfInterruptSetPolicy") }}
class KmdfWdfInterruptSetExtendedPolicy extends Function { KmdfWdfInterruptSetExtendedPolicy() { this.getName().matches("WdfInterruptSetExtendedPolicy") }}
class KmdfWdfInterruptGetDevice extends Function { KmdfWdfInterruptGetDevice() { this.getName().matches("WdfInterruptGetDevice") }}
class KmdfWdfInterruptTryToAcquireLock extends Function { KmdfWdfInterruptTryToAcquireLock() { this.getName().matches("WdfInterruptTryToAcquireLock") }}
class KmdfWdfInterruptReportActive extends Function { KmdfWdfInterruptReportActive() { this.getName().matches("WdfInterruptReportActive") }}
class KmdfWdfInterruptReportInactive extends Function { KmdfWdfInterruptReportInactive() { this.getName().matches("WdfInterruptReportInactive") }}
class KmdfWdfIoQueueCreate extends Function { KmdfWdfIoQueueCreate() { this.getName().matches("WdfIoQueueCreate") }}
class KmdfWdfIoQueueGetState extends Function { KmdfWdfIoQueueGetState() { this.getName().matches("WdfIoQueueGetState") }}
class KmdfWdfIoQueueStart extends Function { KmdfWdfIoQueueStart() { this.getName().matches("WdfIoQueueStart") }}
class KmdfWdfIoQueueStop extends Function { KmdfWdfIoQueueStop() { this.getName().matches("WdfIoQueueStop") }}
class KmdfWdfIoQueueStopSynchronously extends Function { KmdfWdfIoQueueStopSynchronously() { this.getName().matches("WdfIoQueueStopSynchronously") }}
class KmdfWdfIoQueueGetDevice extends Function { KmdfWdfIoQueueGetDevice() { this.getName().matches("WdfIoQueueGetDevice") }}
class KmdfWdfIoQueueRetrieveNextRequest extends Function { KmdfWdfIoQueueRetrieveNextRequest() { this.getName().matches("WdfIoQueueRetrieveNextRequest") }}
class KmdfWdfIoQueueRetrieveRequestByFileObject extends Function { KmdfWdfIoQueueRetrieveRequestByFileObject() { this.getName().matches("WdfIoQueueRetrieveRequestByFileObject") }}
class KmdfWdfIoQueueFindRequest extends Function { KmdfWdfIoQueueFindRequest() { this.getName().matches("WdfIoQueueFindRequest") }}
class KmdfWdfIoQueueRetrieveFoundRequest extends Function { KmdfWdfIoQueueRetrieveFoundRequest() { this.getName().matches("WdfIoQueueRetrieveFoundRequest") }}
class KmdfWdfIoQueueDrainSynchronously extends Function { KmdfWdfIoQueueDrainSynchronously() { this.getName().matches("WdfIoQueueDrainSynchronously") }}
class KmdfWdfIoQueueDrain extends Function { KmdfWdfIoQueueDrain() { this.getName().matches("WdfIoQueueDrain") }}
class KmdfWdfIoQueuePurgeSynchronously extends Function { KmdfWdfIoQueuePurgeSynchronously() { this.getName().matches("WdfIoQueuePurgeSynchronously") }}
class KmdfWdfIoQueuePurge extends Function { KmdfWdfIoQueuePurge() { this.getName().matches("WdfIoQueuePurge") }}
class KmdfWdfIoQueueReadyNotify extends Function { KmdfWdfIoQueueReadyNotify() { this.getName().matches("WdfIoQueueReadyNotify") }}
class KmdfWdfIoQueueAssignForwardProgressPolicy extends Function { KmdfWdfIoQueueAssignForwardProgressPolicy() { this.getName().matches("WdfIoQueueAssignForwardProgressPolicy") }}
class KmdfWdfIoQueueStopAndPurge extends Function { KmdfWdfIoQueueStopAndPurge() { this.getName().matches("WdfIoQueueStopAndPurge") }}
class KmdfWdfIoQueueStopAndPurgeSynchronously extends Function { KmdfWdfIoQueueStopAndPurgeSynchronously() { this.getName().matches("WdfIoQueueStopAndPurgeSynchronously") }}
class KmdfRtlCopyMemory&Params->TargetDeviceName, extends Function { KmdfRtlCopyMemory&Params->TargetDeviceName,() { this.getName().matches("RtlCopyMemory&Params->TargetDeviceName,") }}
class KmdfWDF_IO_TARGET_OPEN_PARAMS_INIT_CREATE_BY_NAMEParams, extends Function { KmdfWDF_IO_TARGET_OPEN_PARAMS_INIT_CREATE_BY_NAMEParams,() { this.getName().matches("WDF_IO_TARGET_OPEN_PARAMS_INIT_CREATE_BY_NAMEParams,") }}
class KmdfWdfIoTargetCreate extends Function { KmdfWdfIoTargetCreate() { this.getName().matches("WdfIoTargetCreate") }}
class KmdfWdfIoTargetOpen extends Function { KmdfWdfIoTargetOpen() { this.getName().matches("WdfIoTargetOpen") }}
class KmdfWdfIoTargetCloseForQueryRemove extends Function { KmdfWdfIoTargetCloseForQueryRemove() { this.getName().matches("WdfIoTargetCloseForQueryRemove") }}
class KmdfWdfIoTargetClose extends Function { KmdfWdfIoTargetClose() { this.getName().matches("WdfIoTargetClose") }}
class KmdfWdfIoTargetStart extends Function { KmdfWdfIoTargetStart() { this.getName().matches("WdfIoTargetStart") }}
class KmdfWdfIoTargetStop extends Function { KmdfWdfIoTargetStop() { this.getName().matches("WdfIoTargetStop") }}
class KmdfWdfIoTargetPurge extends Function { KmdfWdfIoTargetPurge() { this.getName().matches("WdfIoTargetPurge") }}
class KmdfWdfIoTargetGetState extends Function { KmdfWdfIoTargetGetState() { this.getName().matches("WdfIoTargetGetState") }}
class KmdfWdfIoTargetGetDevice extends Function { KmdfWdfIoTargetGetDevice() { this.getName().matches("WdfIoTargetGetDevice") }}
class KmdfWdfIoTargetQueryTargetProperty extends Function { KmdfWdfIoTargetQueryTargetProperty() { this.getName().matches("WdfIoTargetQueryTargetProperty") }}
class KmdfWdfIoTargetAllocAndQueryTargetProperty extends Function { KmdfWdfIoTargetAllocAndQueryTargetProperty() { this.getName().matches("WdfIoTargetAllocAndQueryTargetProperty") }}
class KmdfWdfIoTargetQueryForInterface extends Function { KmdfWdfIoTargetQueryForInterface() { this.getName().matches("WdfIoTargetQueryForInterface") }}
class KmdfWdfIoTargetWdmGetTargetDeviceObject extends Function { KmdfWdfIoTargetWdmGetTargetDeviceObject() { this.getName().matches("WdfIoTargetWdmGetTargetDeviceObject") }}
class KmdfWdfIoTargetWdmGetTargetPhysicalDevice extends Function { KmdfWdfIoTargetWdmGetTargetPhysicalDevice() { this.getName().matches("WdfIoTargetWdmGetTargetPhysicalDevice") }}
class KmdfWdfIoTargetWdmGetTargetFileObject extends Function { KmdfWdfIoTargetWdmGetTargetFileObject() { this.getName().matches("WdfIoTargetWdmGetTargetFileObject") }}
class KmdfWdfIoTargetWdmGetTargetFileHandle extends Function { KmdfWdfIoTargetWdmGetTargetFileHandle() { this.getName().matches("WdfIoTargetWdmGetTargetFileHandle") }}
class KmdfWdfIoTargetSendReadSynchronously extends Function { KmdfWdfIoTargetSendReadSynchronously() { this.getName().matches("WdfIoTargetSendReadSynchronously") }}
class KmdfWdfIoTargetFormatRequestForRead extends Function { KmdfWdfIoTargetFormatRequestForRead() { this.getName().matches("WdfIoTargetFormatRequestForRead") }}
class KmdfWdfIoTargetSendWriteSynchronously extends Function { KmdfWdfIoTargetSendWriteSynchronously() { this.getName().matches("WdfIoTargetSendWriteSynchronously") }}
class KmdfWdfIoTargetFormatRequestForWrite extends Function { KmdfWdfIoTargetFormatRequestForWrite() { this.getName().matches("WdfIoTargetFormatRequestForWrite") }}
class KmdfWdfIoTargetSendIoctlSynchronously extends Function { KmdfWdfIoTargetSendIoctlSynchronously() { this.getName().matches("WdfIoTargetSendIoctlSynchronously") }}
class KmdfWdfIoTargetFormatRequestForIoctl extends Function { KmdfWdfIoTargetFormatRequestForIoctl() { this.getName().matches("WdfIoTargetFormatRequestForIoctl") }}
class KmdfWdfIoTargetSendInternalIoctlSynchronously extends Function { KmdfWdfIoTargetSendInternalIoctlSynchronously() { this.getName().matches("WdfIoTargetSendInternalIoctlSynchronously") }}
class KmdfWdfIoTargetFormatRequestForInternalIoctl extends Function { KmdfWdfIoTargetFormatRequestForInternalIoctl() { this.getName().matches("WdfIoTargetFormatRequestForInternalIoctl") }}
class KmdfWdfIoTargetSendInternalIoctlOthersSynchronously extends Function { KmdfWdfIoTargetSendInternalIoctlOthersSynchronously() { this.getName().matches("WdfIoTargetSendInternalIoctlOthersSynchronously") }}
class KmdfWdfIoTargetFormatRequestForInternalIoctlOthers extends Function { KmdfWdfIoTargetFormatRequestForInternalIoctlOthers() { this.getName().matches("WdfIoTargetFormatRequestForInternalIoctlOthers") }}
class KmdfWdfMemoryCreate extends Function { KmdfWdfMemoryCreate() { this.getName().matches("WdfMemoryCreate") }}
class KmdfWdfMemoryCreatePreallocated extends Function { KmdfWdfMemoryCreatePreallocated() { this.getName().matches("WdfMemoryCreatePreallocated") }}
class KmdfWdfMemoryGetBuffer extends Function { KmdfWdfMemoryGetBuffer() { this.getName().matches("WdfMemoryGetBuffer") }}
class KmdfWdfMemoryAssignBuffer extends Function { KmdfWdfMemoryAssignBuffer() { this.getName().matches("WdfMemoryAssignBuffer") }}
class KmdfWdfMemoryCopyToBuffer extends Function { KmdfWdfMemoryCopyToBuffer() { this.getName().matches("WdfMemoryCopyToBuffer") }}
class KmdfWdfMemoryCopyFromBuffer extends Function { KmdfWdfMemoryCopyFromBuffer() { this.getName().matches("WdfMemoryCopyFromBuffer") }}
class KmdfWdfLookasideListCreate extends Function { KmdfWdfLookasideListCreate() { this.getName().matches("WdfLookasideListCreate") }}
class KmdfWdfMemoryCreateFromLookaside extends Function { KmdfWdfMemoryCreateFromLookaside() { this.getName().matches("WdfMemoryCreateFromLookaside") }}
class KmdfWdfDeviceMiniportCreate extends Function { KmdfWdfDeviceMiniportCreate() { this.getName().matches("WdfDeviceMiniportCreate") }}
class KmdfWdfDriverMiniportUnload extends Function { KmdfWdfDriverMiniportUnload() { this.getName().matches("WdfDriverMiniportUnload") }}
class Kmdf_castingfunction                                                       \ extends Function { Kmdf_castingfunction                                                       \() { this.getName().matches("_castingfunction                                                       \") }}
class KmdfWdfObjectGetTypedContextWorker                                 \ extends Function { KmdfWdfObjectGetTypedContextWorker                                 \() { this.getName().matches("WdfObjectGetTypedContextWorker                                 \") }}
class KmdfWdfObjectGetTypedContextWorker                 \ extends Function { KmdfWdfObjectGetTypedContextWorker                 \() { this.getName().matches("WdfObjectGetTypedContextWorker                 \") }}
class Kmdfstatus = WdfObjectAllocateContextHandle,                           \ extends Function { Kmdfstatus = WdfObjectAllocateContextHandle,                           \() { this.getName().matches("status = WdfObjectAllocateContextHandle,                           \") }}
class KmdfWdfObjectGetTypedContextWorker extends Function { KmdfWdfObjectGetTypedContextWorker() { this.getName().matches("WdfObjectGetTypedContextWorker") }}
class KmdfWdfObjectAllocateContext extends Function { KmdfWdfObjectAllocateContext() { this.getName().matches("WdfObjectAllocateContext") }}
class KmdfWdfObjectContextGetObject extends Function { KmdfWdfObjectContextGetObject() { this.getName().matches("WdfObjectContextGetObject") }}
class KmdfWdfObjectReferenceActual extends Function { KmdfWdfObjectReferenceActual() { this.getName().matches("WdfObjectReferenceActual") }}
class KmdfWdfObjectDereferenceActual extends Function { KmdfWdfObjectDereferenceActual() { this.getName().matches("WdfObjectDereferenceActual") }}
class KmdfWdfObjectCreate extends Function { KmdfWdfObjectCreate() { this.getName().matches("WdfObjectCreate") }}
class KmdfWdfObjectDelete extends Function { KmdfWdfObjectDelete() { this.getName().matches("WdfObjectDelete") }}
class KmdfWdfObjectQuery extends Function { KmdfWdfObjectQuery() { this.getName().matches("WdfObjectQuery") }}
class KmdfWdfPdoInitAllocate extends Function { KmdfWdfPdoInitAllocate() { this.getName().matches("WdfPdoInitAllocate") }}
class KmdfWdfPdoInitSetEventCallbacks extends Function { KmdfWdfPdoInitSetEventCallbacks() { this.getName().matches("WdfPdoInitSetEventCallbacks") }}
class KmdfWdfPdoInitAssignDeviceID extends Function { KmdfWdfPdoInitAssignDeviceID() { this.getName().matches("WdfPdoInitAssignDeviceID") }}
class KmdfWdfPdoInitAssignInstanceID extends Function { KmdfWdfPdoInitAssignInstanceID() { this.getName().matches("WdfPdoInitAssignInstanceID") }}
class KmdfWdfPdoInitAddHardwareID extends Function { KmdfWdfPdoInitAddHardwareID() { this.getName().matches("WdfPdoInitAddHardwareID") }}
class KmdfWdfPdoInitAddCompatibleID extends Function { KmdfWdfPdoInitAddCompatibleID() { this.getName().matches("WdfPdoInitAddCompatibleID") }}
class KmdfWdfPdoInitAssignContainerID extends Function { KmdfWdfPdoInitAssignContainerID() { this.getName().matches("WdfPdoInitAssignContainerID") }}
class KmdfWdfPdoInitAddDeviceText extends Function { KmdfWdfPdoInitAddDeviceText() { this.getName().matches("WdfPdoInitAddDeviceText") }}
class KmdfWdfPdoInitSetDefaultLocale extends Function { KmdfWdfPdoInitSetDefaultLocale() { this.getName().matches("WdfPdoInitSetDefaultLocale") }}
class KmdfWdfPdoInitAssignRawDevice extends Function { KmdfWdfPdoInitAssignRawDevice() { this.getName().matches("WdfPdoInitAssignRawDevice") }}
class KmdfWdfPdoInitAllowForwardingRequestToParent extends Function { KmdfWdfPdoInitAllowForwardingRequestToParent() { this.getName().matches("WdfPdoInitAllowForwardingRequestToParent") }}
class KmdfWdfPdoMarkMissing extends Function { KmdfWdfPdoMarkMissing() { this.getName().matches("WdfPdoMarkMissing") }}
class KmdfWdfPdoRequestEject extends Function { KmdfWdfPdoRequestEject() { this.getName().matches("WdfPdoRequestEject") }}
class KmdfWdfPdoGetParent extends Function { KmdfWdfPdoGetParent() { this.getName().matches("WdfPdoGetParent") }}
class KmdfWdfPdoRetrieveIdentificationDescription extends Function { KmdfWdfPdoRetrieveIdentificationDescription() { this.getName().matches("WdfPdoRetrieveIdentificationDescription") }}
class KmdfWdfPdoRetrieveAddressDescription extends Function { KmdfWdfPdoRetrieveAddressDescription() { this.getName().matches("WdfPdoRetrieveAddressDescription") }}
class KmdfWdfPdoUpdateAddressDescription extends Function { KmdfWdfPdoUpdateAddressDescription() { this.getName().matches("WdfPdoUpdateAddressDescription") }}
class KmdfWdfPdoAddEjectionRelationsPhysicalDevice extends Function { KmdfWdfPdoAddEjectionRelationsPhysicalDevice() { this.getName().matches("WdfPdoAddEjectionRelationsPhysicalDevice") }}
class KmdfWdfPdoRemoveEjectionRelationsPhysicalDevice extends Function { KmdfWdfPdoRemoveEjectionRelationsPhysicalDevice() { this.getName().matches("WdfPdoRemoveEjectionRelationsPhysicalDevice") }}
class KmdfWdfPdoClearEjectionRelationsDevices extends Function { KmdfWdfPdoClearEjectionRelationsDevices() { this.getName().matches("WdfPdoClearEjectionRelationsDevices") }}
class KmdfWdfPdoInitRemovePowerDependencyOnParent extends Function { KmdfWdfPdoInitRemovePowerDependencyOnParent() { this.getName().matches("WdfPdoInitRemovePowerDependencyOnParent") }}
class KmdfWdfDeviceAddQueryInterface extends Function { KmdfWdfDeviceAddQueryInterface() { this.getName().matches("WdfDeviceAddQueryInterface") }}
class KmdfWdfDeviceInterfaceReferenceNoOp extends Function { KmdfWdfDeviceInterfaceReferenceNoOp() { this.getName().matches("WdfDeviceInterfaceReferenceNoOp") }}
class KmdfWdfDeviceInterfaceDereferenceNoOp extends Function { KmdfWdfDeviceInterfaceDereferenceNoOp() { this.getName().matches("WdfDeviceInterfaceDereferenceNoOp") }}
class KmdfWdfRegistryOpenKey extends Function { KmdfWdfRegistryOpenKey() { this.getName().matches("WdfRegistryOpenKey") }}
class KmdfWdfRegistryCreateKey extends Function { KmdfWdfRegistryCreateKey() { this.getName().matches("WdfRegistryCreateKey") }}
class KmdfWdfRegistryClose extends Function { KmdfWdfRegistryClose() { this.getName().matches("WdfRegistryClose") }}
class KmdfWdfRegistryWdmGetHandle extends Function { KmdfWdfRegistryWdmGetHandle() { this.getName().matches("WdfRegistryWdmGetHandle") }}
class KmdfWdfRegistryRemoveKey extends Function { KmdfWdfRegistryRemoveKey() { this.getName().matches("WdfRegistryRemoveKey") }}
class KmdfWdfRegistryRemoveValue extends Function { KmdfWdfRegistryRemoveValue() { this.getName().matches("WdfRegistryRemoveValue") }}
class KmdfWdfRegistryQueryValue extends Function { KmdfWdfRegistryQueryValue() { this.getName().matches("WdfRegistryQueryValue") }}
class KmdfWdfRegistryQueryMemory extends Function { KmdfWdfRegistryQueryMemory() { this.getName().matches("WdfRegistryQueryMemory") }}
class KmdfWdfRegistryQueryMultiString extends Function { KmdfWdfRegistryQueryMultiString() { this.getName().matches("WdfRegistryQueryMultiString") }}
class KmdfWdfRegistryQueryUnicodeString extends Function { KmdfWdfRegistryQueryUnicodeString() { this.getName().matches("WdfRegistryQueryUnicodeString") }}
class KmdfWdfRegistryQueryString extends Function { KmdfWdfRegistryQueryString() { this.getName().matches("WdfRegistryQueryString") }}
class KmdfWdfRegistryQueryULong extends Function { KmdfWdfRegistryQueryULong() { this.getName().matches("WdfRegistryQueryULong") }}
class KmdfWdfRegistryAssignValue extends Function { KmdfWdfRegistryAssignValue() { this.getName().matches("WdfRegistryAssignValue") }}
class KmdfWdfRegistryAssignMemory extends Function { KmdfWdfRegistryAssignMemory() { this.getName().matches("WdfRegistryAssignMemory") }}
class KmdfWdfRegistryAssignMultiString extends Function { KmdfWdfRegistryAssignMultiString() { this.getName().matches("WdfRegistryAssignMultiString") }}
class KmdfWdfRegistryAssignUnicodeString extends Function { KmdfWdfRegistryAssignUnicodeString() { this.getName().matches("WdfRegistryAssignUnicodeString") }}
class KmdfWdfRegistryAssignString extends Function { KmdfWdfRegistryAssignString() { this.getName().matches("WdfRegistryAssignString") }}
class KmdfWdfRegistryAssignULong extends Function { KmdfWdfRegistryAssignULong() { this.getName().matches("WdfRegistryAssignULong") }}
class KmdfWdfRequestCreate extends Function { KmdfWdfRequestCreate() { this.getName().matches("WdfRequestCreate") }}
class KmdfWdfRequestGetRequestorProcessId extends Function { KmdfWdfRequestGetRequestorProcessId() { this.getName().matches("WdfRequestGetRequestorProcessId") }}
class KmdfWdfRequestCreateFromIrp extends Function { KmdfWdfRequestCreateFromIrp() { this.getName().matches("WdfRequestCreateFromIrp") }}
class KmdfWdfRequestReuse extends Function { KmdfWdfRequestReuse() { this.getName().matches("WdfRequestReuse") }}
class KmdfWdfRequestChangeTarget extends Function { KmdfWdfRequestChangeTarget() { this.getName().matches("WdfRequestChangeTarget") }}
class KmdfWdfRequestFormatRequestUsingCurrentType extends Function { KmdfWdfRequestFormatRequestUsingCurrentType() { this.getName().matches("WdfRequestFormatRequestUsingCurrentType") }}
class KmdfWdfRequestWdmFormatUsingStackLocation extends Function { KmdfWdfRequestWdmFormatUsingStackLocation() { this.getName().matches("WdfRequestWdmFormatUsingStackLocation") }}
class KmdfWdfRequestSend extends Function { KmdfWdfRequestSend() { this.getName().matches("WdfRequestSend") }}
class KmdfWdfRequestGetStatus extends Function { KmdfWdfRequestGetStatus() { this.getName().matches("WdfRequestGetStatus") }}
class KmdfWdfRequestMarkCancelable extends Function { KmdfWdfRequestMarkCancelable() { this.getName().matches("WdfRequestMarkCancelable") }}
class KmdfWdfRequestMarkCancelableEx extends Function { KmdfWdfRequestMarkCancelableEx() { this.getName().matches("WdfRequestMarkCancelableEx") }}
class KmdfWdfRequestUnmarkCancelable extends Function { KmdfWdfRequestUnmarkCancelable() { this.getName().matches("WdfRequestUnmarkCancelable") }}
class KmdfWdfRequestIsCanceled extends Function { KmdfWdfRequestIsCanceled() { this.getName().matches("WdfRequestIsCanceled") }}
class KmdfWdfRequestCancelSentRequest extends Function { KmdfWdfRequestCancelSentRequest() { this.getName().matches("WdfRequestCancelSentRequest") }}
class KmdfWdfRequestIsFrom32BitProcess extends Function { KmdfWdfRequestIsFrom32BitProcess() { this.getName().matches("WdfRequestIsFrom32BitProcess") }}
class KmdfWdfRequestSetCompletionRoutine extends Function { KmdfWdfRequestSetCompletionRoutine() { this.getName().matches("WdfRequestSetCompletionRoutine") }}
class KmdfWdfRequestGetCompletionParams extends Function { KmdfWdfRequestGetCompletionParams() { this.getName().matches("WdfRequestGetCompletionParams") }}
class KmdfWdfRequestAllocateTimer extends Function { KmdfWdfRequestAllocateTimer() { this.getName().matches("WdfRequestAllocateTimer") }}
class KmdfWdfRequestComplete extends Function { KmdfWdfRequestComplete() { this.getName().matches("WdfRequestComplete") }}
class KmdfWdfRequestCompleteWithPriorityBoost extends Function { KmdfWdfRequestCompleteWithPriorityBoost() { this.getName().matches("WdfRequestCompleteWithPriorityBoost") }}
class KmdfWdfRequestCompleteWithInformation extends Function { KmdfWdfRequestCompleteWithInformation() { this.getName().matches("WdfRequestCompleteWithInformation") }}
class KmdfWdfRequestGetParameters extends Function { KmdfWdfRequestGetParameters() { this.getName().matches("WdfRequestGetParameters") }}
class KmdfWdfRequestRetrieveInputMemory extends Function { KmdfWdfRequestRetrieveInputMemory() { this.getName().matches("WdfRequestRetrieveInputMemory") }}
class KmdfWdfRequestRetrieveOutputMemory extends Function { KmdfWdfRequestRetrieveOutputMemory() { this.getName().matches("WdfRequestRetrieveOutputMemory") }}
class KmdfWdfRequestRetrieveInputBuffer extends Function { KmdfWdfRequestRetrieveInputBuffer() { this.getName().matches("WdfRequestRetrieveInputBuffer") }}
class KmdfWdfRequestRetrieveOutputBuffer extends Function { KmdfWdfRequestRetrieveOutputBuffer() { this.getName().matches("WdfRequestRetrieveOutputBuffer") }}
class KmdfWdfRequestRetrieveInputWdmMdl extends Function { KmdfWdfRequestRetrieveInputWdmMdl() { this.getName().matches("WdfRequestRetrieveInputWdmMdl") }}
class KmdfWdfRequestRetrieveOutputWdmMdl extends Function { KmdfWdfRequestRetrieveOutputWdmMdl() { this.getName().matches("WdfRequestRetrieveOutputWdmMdl") }}
class KmdfWdfRequestRetrieveUnsafeUserInputBuffer extends Function { KmdfWdfRequestRetrieveUnsafeUserInputBuffer() { this.getName().matches("WdfRequestRetrieveUnsafeUserInputBuffer") }}
class KmdfWdfRequestRetrieveUnsafeUserOutputBuffer extends Function { KmdfWdfRequestRetrieveUnsafeUserOutputBuffer() { this.getName().matches("WdfRequestRetrieveUnsafeUserOutputBuffer") }}
class KmdfWdfRequestSetInformation extends Function { KmdfWdfRequestSetInformation() { this.getName().matches("WdfRequestSetInformation") }}
class KmdfWdfRequestGetInformation extends Function { KmdfWdfRequestGetInformation() { this.getName().matches("WdfRequestGetInformation") }}
class KmdfWdfRequestGetFileObject extends Function { KmdfWdfRequestGetFileObject() { this.getName().matches("WdfRequestGetFileObject") }}
class KmdfWdfRequestProbeAndLockUserBufferForRead extends Function { KmdfWdfRequestProbeAndLockUserBufferForRead() { this.getName().matches("WdfRequestProbeAndLockUserBufferForRead") }}
class KmdfWdfRequestProbeAndLockUserBufferForWrite extends Function { KmdfWdfRequestProbeAndLockUserBufferForWrite() { this.getName().matches("WdfRequestProbeAndLockUserBufferForWrite") }}
class KmdfWdfRequestGetRequestorMode extends Function { KmdfWdfRequestGetRequestorMode() { this.getName().matches("WdfRequestGetRequestorMode") }}
class KmdfWdfRequestForwardToIoQueue extends Function { KmdfWdfRequestForwardToIoQueue() { this.getName().matches("WdfRequestForwardToIoQueue") }}
class KmdfWdfRequestGetIoQueue extends Function { KmdfWdfRequestGetIoQueue() { this.getName().matches("WdfRequestGetIoQueue") }}
class KmdfWdfRequestRequeue extends Function { KmdfWdfRequestRequeue() { this.getName().matches("WdfRequestRequeue") }}
class KmdfWdfRequestStopAcknowledge extends Function { KmdfWdfRequestStopAcknowledge() { this.getName().matches("WdfRequestStopAcknowledge") }}
class KmdfWdfRequestWdmGetIrp extends Function { KmdfWdfRequestWdmGetIrp() { this.getName().matches("WdfRequestWdmGetIrp") }}
class KmdfWdfRequestIsReserved extends Function { KmdfWdfRequestIsReserved() { this.getName().matches("WdfRequestIsReserved") }}
class KmdfWdfRequestForwardToParentDeviceIoQueue extends Function { KmdfWdfRequestForwardToParentDeviceIoQueue() { this.getName().matches("WdfRequestForwardToParentDeviceIoQueue") }}
class KmdfWdfIoResourceRequirementsListSetSlotNumber extends Function { KmdfWdfIoResourceRequirementsListSetSlotNumber() { this.getName().matches("WdfIoResourceRequirementsListSetSlotNumber") }}
class KmdfWdfIoResourceRequirementsListSetInterfaceType extends Function { KmdfWdfIoResourceRequirementsListSetInterfaceType() { this.getName().matches("WdfIoResourceRequirementsListSetInterfaceType") }}
class KmdfWdfIoResourceRequirementsListAppendIoResList extends Function { KmdfWdfIoResourceRequirementsListAppendIoResList() { this.getName().matches("WdfIoResourceRequirementsListAppendIoResList") }}
class KmdfWdfIoResourceRequirementsListInsertIoResList extends Function { KmdfWdfIoResourceRequirementsListInsertIoResList() { this.getName().matches("WdfIoResourceRequirementsListInsertIoResList") }}
class KmdfWdfIoResourceRequirementsListGetCount extends Function { KmdfWdfIoResourceRequirementsListGetCount() { this.getName().matches("WdfIoResourceRequirementsListGetCount") }}
class KmdfWdfIoResourceRequirementsListGetIoResList extends Function { KmdfWdfIoResourceRequirementsListGetIoResList() { this.getName().matches("WdfIoResourceRequirementsListGetIoResList") }}
class KmdfWdfIoResourceRequirementsListRemove extends Function { KmdfWdfIoResourceRequirementsListRemove() { this.getName().matches("WdfIoResourceRequirementsListRemove") }}
class KmdfWdfIoResourceRequirementsListRemoveByIoResList extends Function { KmdfWdfIoResourceRequirementsListRemoveByIoResList() { this.getName().matches("WdfIoResourceRequirementsListRemoveByIoResList") }}
class KmdfWdfIoResourceListCreate extends Function { KmdfWdfIoResourceListCreate() { this.getName().matches("WdfIoResourceListCreate") }}
class KmdfWdfIoResourceListAppendDescriptor extends Function { KmdfWdfIoResourceListAppendDescriptor() { this.getName().matches("WdfIoResourceListAppendDescriptor") }}
class KmdfWdfIoResourceListInsertDescriptor extends Function { KmdfWdfIoResourceListInsertDescriptor() { this.getName().matches("WdfIoResourceListInsertDescriptor") }}
class KmdfWdfIoResourceListUpdateDescriptor extends Function { KmdfWdfIoResourceListUpdateDescriptor() { this.getName().matches("WdfIoResourceListUpdateDescriptor") }}
class KmdfWdfIoResourceListGetCount extends Function { KmdfWdfIoResourceListGetCount() { this.getName().matches("WdfIoResourceListGetCount") }}
class KmdfWdfIoResourceListGetDescriptor extends Function { KmdfWdfIoResourceListGetDescriptor() { this.getName().matches("WdfIoResourceListGetDescriptor") }}
class KmdfWdfIoResourceListRemove extends Function { KmdfWdfIoResourceListRemove() { this.getName().matches("WdfIoResourceListRemove") }}
class KmdfWdfIoResourceListRemoveByDescriptor extends Function { KmdfWdfIoResourceListRemoveByDescriptor() { this.getName().matches("WdfIoResourceListRemoveByDescriptor") }}
class KmdfWdfCmResourceListAppendDescriptor extends Function { KmdfWdfCmResourceListAppendDescriptor() { this.getName().matches("WdfCmResourceListAppendDescriptor") }}
class KmdfWdfCmResourceListInsertDescriptor extends Function { KmdfWdfCmResourceListInsertDescriptor() { this.getName().matches("WdfCmResourceListInsertDescriptor") }}
class KmdfWdfCmResourceListGetCount extends Function { KmdfWdfCmResourceListGetCount() { this.getName().matches("WdfCmResourceListGetCount") }}
class KmdfWdfCmResourceListGetDescriptor extends Function { KmdfWdfCmResourceListGetDescriptor() { this.getName().matches("WdfCmResourceListGetDescriptor") }}
class KmdfWdfCmResourceListRemove extends Function { KmdfWdfCmResourceListRemove() { this.getName().matches("WdfCmResourceListRemove") }}
class KmdfWdfCmResourceListRemoveByDescriptor extends Function { KmdfWdfCmResourceListRemoveByDescriptor() { this.getName().matches("WdfCmResourceListRemoveByDescriptor") }}
class KmdfWdfStringCreate extends Function { KmdfWdfStringCreate() { this.getName().matches("WdfStringCreate") }}
class KmdfWdfStringGetUnicodeString extends Function { KmdfWdfStringGetUnicodeString() { this.getName().matches("WdfStringGetUnicodeString") }}
class KmdfWdfObjectAcquireLock extends Function { KmdfWdfObjectAcquireLock() { this.getName().matches("WdfObjectAcquireLock") }}
class KmdfWdfObjectReleaseLock extends Function { KmdfWdfObjectReleaseLock() { this.getName().matches("WdfObjectReleaseLock") }}
class KmdfWdfWaitLockCreate extends Function { KmdfWdfWaitLockCreate() { this.getName().matches("WdfWaitLockCreate") }}
class KmdfWdfWaitLockAcquire extends Function { KmdfWdfWaitLockAcquire() { this.getName().matches("WdfWaitLockAcquire") }}
class KmdfWdfWaitLockRelease extends Function { KmdfWdfWaitLockRelease() { this.getName().matches("WdfWaitLockRelease") }}
class KmdfWdfSpinLockCreate extends Function { KmdfWdfSpinLockCreate() { this.getName().matches("WdfSpinLockCreate") }}
class KmdfWdfSpinLockAcquire extends Function { KmdfWdfSpinLockAcquire() { this.getName().matches("WdfSpinLockAcquire") }}
class KmdfWdfSpinLockRelease extends Function { KmdfWdfSpinLockRelease() { this.getName().matches("WdfSpinLockRelease") }}
class KmdfWdfTimerCreate extends Function { KmdfWdfTimerCreate() { this.getName().matches("WdfTimerCreate") }}
class KmdfWdfTimerStart extends Function { KmdfWdfTimerStart() { this.getName().matches("WdfTimerStart") }}
class KmdfWdfTimerStop extends Function { KmdfWdfTimerStop() { this.getName().matches("WdfTimerStop") }}
class KmdfWdfTimerGetParentObject extends Function { KmdfWdfTimerGetParentObject() { this.getName().matches("WdfTimerGetParentObject") }}
class KmdfWdfUsbTargetDeviceGetIoTarget extends Function { KmdfWdfUsbTargetDeviceGetIoTarget() { this.getName().matches("WdfUsbTargetDeviceGetIoTarget") }}
class KmdfWdfUsbTargetPipeGetIoTarget extends Function { KmdfWdfUsbTargetPipeGetIoTarget() { this.getName().matches("WdfUsbTargetPipeGetIoTarget") }}
class KmdfWdfUsbTargetDeviceCreate extends Function { KmdfWdfUsbTargetDeviceCreate() { this.getName().matches("WdfUsbTargetDeviceCreate") }}
class KmdfWdfUsbTargetDeviceCreateWithParameters extends Function { KmdfWdfUsbTargetDeviceCreateWithParameters() { this.getName().matches("WdfUsbTargetDeviceCreateWithParameters") }}
class KmdfWdfUsbTargetDeviceRetrieveInformation extends Function { KmdfWdfUsbTargetDeviceRetrieveInformation() { this.getName().matches("WdfUsbTargetDeviceRetrieveInformation") }}
class KmdfWdfUsbTargetDeviceGetDeviceDescriptor extends Function { KmdfWdfUsbTargetDeviceGetDeviceDescriptor() { this.getName().matches("WdfUsbTargetDeviceGetDeviceDescriptor") }}
class KmdfWdfUsbTargetDeviceRetrieveConfigDescriptor extends Function { KmdfWdfUsbTargetDeviceRetrieveConfigDescriptor() { this.getName().matches("WdfUsbTargetDeviceRetrieveConfigDescriptor") }}
class KmdfWdfUsbTargetDeviceQueryString extends Function { KmdfWdfUsbTargetDeviceQueryString() { this.getName().matches("WdfUsbTargetDeviceQueryString") }}
class KmdfWdfUsbTargetDeviceAllocAndQueryString extends Function { KmdfWdfUsbTargetDeviceAllocAndQueryString() { this.getName().matches("WdfUsbTargetDeviceAllocAndQueryString") }}
class KmdfWdfUsbTargetDeviceFormatRequestForString extends Function { KmdfWdfUsbTargetDeviceFormatRequestForString() { this.getName().matches("WdfUsbTargetDeviceFormatRequestForString") }}
class KmdfWdfUsbTargetDeviceGetNumInterfaces extends Function { KmdfWdfUsbTargetDeviceGetNumInterfaces() { this.getName().matches("WdfUsbTargetDeviceGetNumInterfaces") }}
class KmdfWdfUsbTargetDeviceSelectConfig extends Function { KmdfWdfUsbTargetDeviceSelectConfig() { this.getName().matches("WdfUsbTargetDeviceSelectConfig") }}
class KmdfWdfUsbTargetDeviceWdmGetConfigurationHandle extends Function { KmdfWdfUsbTargetDeviceWdmGetConfigurationHandle() { this.getName().matches("WdfUsbTargetDeviceWdmGetConfigurationHandle") }}
class KmdfWdfUsbTargetDeviceRetrieveCurrentFrameNumber extends Function { KmdfWdfUsbTargetDeviceRetrieveCurrentFrameNumber() { this.getName().matches("WdfUsbTargetDeviceRetrieveCurrentFrameNumber") }}
class KmdfWdfUsbTargetDeviceSendControlTransferSynchronously extends Function { KmdfWdfUsbTargetDeviceSendControlTransferSynchronously() { this.getName().matches("WdfUsbTargetDeviceSendControlTransferSynchronously") }}
class KmdfWdfUsbTargetDeviceFormatRequestForControlTransfer extends Function { KmdfWdfUsbTargetDeviceFormatRequestForControlTransfer() { this.getName().matches("WdfUsbTargetDeviceFormatRequestForControlTransfer") }}
class KmdfWdfUsbTargetDeviceIsConnectedSynchronous extends Function { KmdfWdfUsbTargetDeviceIsConnectedSynchronous() { this.getName().matches("WdfUsbTargetDeviceIsConnectedSynchronous") }}
class KmdfWdfUsbTargetDeviceResetPortSynchronously extends Function { KmdfWdfUsbTargetDeviceResetPortSynchronously() { this.getName().matches("WdfUsbTargetDeviceResetPortSynchronously") }}
class KmdfWdfUsbTargetDeviceCyclePortSynchronously extends Function { KmdfWdfUsbTargetDeviceCyclePortSynchronously() { this.getName().matches("WdfUsbTargetDeviceCyclePortSynchronously") }}
class KmdfWdfUsbTargetDeviceFormatRequestForCyclePort extends Function { KmdfWdfUsbTargetDeviceFormatRequestForCyclePort() { this.getName().matches("WdfUsbTargetDeviceFormatRequestForCyclePort") }}
class KmdfWdfUsbTargetDeviceSendUrbSynchronously extends Function { KmdfWdfUsbTargetDeviceSendUrbSynchronously() { this.getName().matches("WdfUsbTargetDeviceSendUrbSynchronously") }}
class KmdfWdfUsbTargetDeviceFormatRequestForUrb extends Function { KmdfWdfUsbTargetDeviceFormatRequestForUrb() { this.getName().matches("WdfUsbTargetDeviceFormatRequestForUrb") }}
class KmdfWdfUsbTargetDeviceQueryUsbCapability extends Function { KmdfWdfUsbTargetDeviceQueryUsbCapability() { this.getName().matches("WdfUsbTargetDeviceQueryUsbCapability") }}
class KmdfWdfUsbTargetDeviceCreateUrb extends Function { KmdfWdfUsbTargetDeviceCreateUrb() { this.getName().matches("WdfUsbTargetDeviceCreateUrb") }}
class KmdfWdfUsbTargetDeviceCreateIsochUrb extends Function { KmdfWdfUsbTargetDeviceCreateIsochUrb() { this.getName().matches("WdfUsbTargetDeviceCreateIsochUrb") }}
class KmdfWdfUsbTargetPipeGetInformation extends Function { KmdfWdfUsbTargetPipeGetInformation() { this.getName().matches("WdfUsbTargetPipeGetInformation") }}
class KmdfWdfUsbTargetPipeIsInEndpoint extends Function { KmdfWdfUsbTargetPipeIsInEndpoint() { this.getName().matches("WdfUsbTargetPipeIsInEndpoint") }}
class KmdfWdfUsbTargetPipeIsOutEndpoint extends Function { KmdfWdfUsbTargetPipeIsOutEndpoint() { this.getName().matches("WdfUsbTargetPipeIsOutEndpoint") }}
class KmdfWdfUsbTargetPipeGetType extends Function { KmdfWdfUsbTargetPipeGetType() { this.getName().matches("WdfUsbTargetPipeGetType") }}
class KmdfWdfUsbTargetPipeSetNoMaximumPacketSizeCheck extends Function { KmdfWdfUsbTargetPipeSetNoMaximumPacketSizeCheck() { this.getName().matches("WdfUsbTargetPipeSetNoMaximumPacketSizeCheck") }}
class KmdfWdfUsbTargetPipeWriteSynchronously extends Function { KmdfWdfUsbTargetPipeWriteSynchronously() { this.getName().matches("WdfUsbTargetPipeWriteSynchronously") }}
class KmdfWdfUsbTargetPipeFormatRequestForWrite extends Function { KmdfWdfUsbTargetPipeFormatRequestForWrite() { this.getName().matches("WdfUsbTargetPipeFormatRequestForWrite") }}
class KmdfWdfUsbTargetPipeReadSynchronously extends Function { KmdfWdfUsbTargetPipeReadSynchronously() { this.getName().matches("WdfUsbTargetPipeReadSynchronously") }}
class KmdfWdfUsbTargetPipeFormatRequestForRead extends Function { KmdfWdfUsbTargetPipeFormatRequestForRead() { this.getName().matches("WdfUsbTargetPipeFormatRequestForRead") }}
class KmdfWdfUsbTargetPipeConfigContinuousReader extends Function { KmdfWdfUsbTargetPipeConfigContinuousReader() { this.getName().matches("WdfUsbTargetPipeConfigContinuousReader") }}
class KmdfWdfUsbTargetPipeAbortSynchronously extends Function { KmdfWdfUsbTargetPipeAbortSynchronously() { this.getName().matches("WdfUsbTargetPipeAbortSynchronously") }}
class KmdfWdfUsbTargetPipeFormatRequestForAbort extends Function { KmdfWdfUsbTargetPipeFormatRequestForAbort() { this.getName().matches("WdfUsbTargetPipeFormatRequestForAbort") }}
class KmdfWdfUsbTargetPipeResetSynchronously extends Function { KmdfWdfUsbTargetPipeResetSynchronously() { this.getName().matches("WdfUsbTargetPipeResetSynchronously") }}
class KmdfWdfUsbTargetPipeFormatRequestForReset extends Function { KmdfWdfUsbTargetPipeFormatRequestForReset() { this.getName().matches("WdfUsbTargetPipeFormatRequestForReset") }}
class KmdfWdfUsbTargetPipeSendUrbSynchronously extends Function { KmdfWdfUsbTargetPipeSendUrbSynchronously() { this.getName().matches("WdfUsbTargetPipeSendUrbSynchronously") }}
class KmdfWdfUsbTargetPipeFormatRequestForUrb extends Function { KmdfWdfUsbTargetPipeFormatRequestForUrb() { this.getName().matches("WdfUsbTargetPipeFormatRequestForUrb") }}
class KmdfWdfUsbInterfaceGetInterfaceNumber extends Function { KmdfWdfUsbInterfaceGetInterfaceNumber() { this.getName().matches("WdfUsbInterfaceGetInterfaceNumber") }}
class KmdfWdfUsbInterfaceGetNumEndpoints extends Function { KmdfWdfUsbInterfaceGetNumEndpoints() { this.getName().matches("WdfUsbInterfaceGetNumEndpoints") }}
class KmdfWdfUsbInterfaceGetDescriptor extends Function { KmdfWdfUsbInterfaceGetDescriptor() { this.getName().matches("WdfUsbInterfaceGetDescriptor") }}
class KmdfWdfUsbInterfaceGetNumSettings extends Function { KmdfWdfUsbInterfaceGetNumSettings() { this.getName().matches("WdfUsbInterfaceGetNumSettings") }}
class KmdfWdfUsbInterfaceSelectSetting extends Function { KmdfWdfUsbInterfaceSelectSetting() { this.getName().matches("WdfUsbInterfaceSelectSetting") }}
class KmdfWdfUsbInterfaceGetEndpointInformation extends Function { KmdfWdfUsbInterfaceGetEndpointInformation() { this.getName().matches("WdfUsbInterfaceGetEndpointInformation") }}
class KmdfWdfUsbTargetDeviceGetInterface extends Function { KmdfWdfUsbTargetDeviceGetInterface() { this.getName().matches("WdfUsbTargetDeviceGetInterface") }}
class KmdfWdfUsbInterfaceGetConfiguredSettingIndex extends Function { KmdfWdfUsbInterfaceGetConfiguredSettingIndex() { this.getName().matches("WdfUsbInterfaceGetConfiguredSettingIndex") }}
class KmdfWdfUsbInterfaceGetNumConfiguredPipes extends Function { KmdfWdfUsbInterfaceGetNumConfiguredPipes() { this.getName().matches("WdfUsbInterfaceGetNumConfiguredPipes") }}
class KmdfWdfUsbInterfaceGetConfiguredPipe extends Function { KmdfWdfUsbInterfaceGetConfiguredPipe() { this.getName().matches("WdfUsbInterfaceGetConfiguredPipe") }}
class KmdfWdfUsbTargetPipeWdmGetPipeHandle extends Function { KmdfWdfUsbTargetPipeWdmGetPipeHandle() { this.getName().matches("WdfUsbTargetPipeWdmGetPipeHandle") }}
class KmdfWdfVerifierDbgBreakPoint extends Function { KmdfWdfVerifierDbgBreakPoint() { this.getName().matches("WdfVerifierDbgBreakPoint") }}
class KmdfWdfVerifierKeBugCheck extends Function { KmdfWdfVerifierKeBugCheck() { this.getName().matches("WdfVerifierKeBugCheck") }}
class KmdfWdfGetTriageInfo extends Function { KmdfWdfGetTriageInfo() { this.getName().matches("WdfGetTriageInfo") }}
class KmdfWdfWmiProviderCreate extends Function { KmdfWdfWmiProviderCreate() { this.getName().matches("WdfWmiProviderCreate") }}
class KmdfWdfWmiProviderGetDevice extends Function { KmdfWdfWmiProviderGetDevice() { this.getName().matches("WdfWmiProviderGetDevice") }}
class KmdfWdfWmiProviderIsEnabled extends Function { KmdfWdfWmiProviderIsEnabled() { this.getName().matches("WdfWmiProviderIsEnabled") }}
class KmdfWdfWmiProviderGetTracingHandle extends Function { KmdfWdfWmiProviderGetTracingHandle() { this.getName().matches("WdfWmiProviderGetTracingHandle") }}
class KmdfWdfWmiInstanceCreate extends Function { KmdfWdfWmiInstanceCreate() { this.getName().matches("WdfWmiInstanceCreate") }}
class KmdfWdfWmiInstanceRegister extends Function { KmdfWdfWmiInstanceRegister() { this.getName().matches("WdfWmiInstanceRegister") }}
class KmdfWdfWmiInstanceDeregister extends Function { KmdfWdfWmiInstanceDeregister() { this.getName().matches("WdfWmiInstanceDeregister") }}
class KmdfWdfWmiInstanceGetDevice extends Function { KmdfWdfWmiInstanceGetDevice() { this.getName().matches("WdfWmiInstanceGetDevice") }}
class KmdfWdfWmiInstanceGetProvider extends Function { KmdfWdfWmiInstanceGetProvider() { this.getName().matches("WdfWmiInstanceGetProvider") }}
class KmdfWdfWmiInstanceFireEvent extends Function { KmdfWdfWmiInstanceFireEvent() { this.getName().matches("WdfWmiInstanceFireEvent") }}
class KmdfWdfWorkItemCreate extends Function { KmdfWdfWorkItemCreate() { this.getName().matches("WdfWorkItemCreate") }}
class KmdfWdfWorkItemEnqueue extends Function { KmdfWdfWorkItemEnqueue() { this.getName().matches("WdfWorkItemEnqueue") }}
class KmdfWdfWorkItemGetParentObject extends Function { KmdfWdfWorkItemGetParentObject() { this.getName().matches("WdfWorkItemGetParentObject") }}
class KmdfWdfWorkItemFlush extends Function { KmdfWdfWorkItemFlush() { this.getName().matches("WdfWorkItemFlush") }}


class Kmdf_WDF_POWER_ROUTINE_TIMED_OUT_DATA extends Struct { 
  Kmdf_WDF_POWER_ROUTINE_TIMED_OUT_DATA() { this.getName().matches("_WDF_POWER_ROUTINE_TIMED_OUT_DATA") }
}
class Kmdf_WDF_REQUEST_FATAL_ERROR_INFORMATION_LENGTH_MISMATCH_DATA extends Struct { Kmdf_WDF_REQUEST_FATAL_ERROR_INFORMATION_LENGTH_MISMATCH_DATA() { this.getName().matches("_WDF_REQUEST_FATAL_ERROR_INFORMATION_LENGTH_MISMATCH_DATA") }}
class Kmdf_WDF_QUEUE_FATAL_ERROR_DATA extends Struct { Kmdf_WDF_QUEUE_FATAL_ERROR_DATA() { this.getName().matches("_WDF_QUEUE_FATAL_ERROR_DATA") }}
class Kmdf_WDF_CHILD_IDENTIFICATION_DESCRIPTION_HEADER extends Struct { Kmdf_WDF_CHILD_IDENTIFICATION_DESCRIPTION_HEADER() { this.getName().matches("_WDF_CHILD_IDENTIFICATION_DESCRIPTION_HEADER") }}
class Kmdf_WDF_CHILD_ADDRESS_DESCRIPTION_HEADER extends Struct { Kmdf_WDF_CHILD_ADDRESS_DESCRIPTION_HEADER() { this.getName().matches("_WDF_CHILD_ADDRESS_DESCRIPTION_HEADER") }}
class Kmdf_WDF_CHILD_RETRIEVE_INFO extends Struct { Kmdf_WDF_CHILD_RETRIEVE_INFO() { this.getName().matches("_WDF_CHILD_RETRIEVE_INFO") }}
class Kmdf_WDF_CHILD_LIST_CONFIG extends Struct { Kmdf_WDF_CHILD_LIST_CONFIG() { this.getName().matches("_WDF_CHILD_LIST_CONFIG") }}
class Kmdf_WDF_CHILD_LIST_ITERATOR extends Struct { Kmdf_WDF_CHILD_LIST_ITERATOR() { this.getName().matches("_WDF_CHILD_LIST_ITERATOR") }}
class Kmdf_WDF_COMMON_BUFFER_CONFIG extends Struct { Kmdf_WDF_COMMON_BUFFER_CONFIG() { this.getName().matches("_WDF_COMMON_BUFFER_CONFIG") }}
class Kmdf_WDF_TASK_SEND_OPTIONS extends Struct { Kmdf_WDF_TASK_SEND_OPTIONS() { this.getName().matches("_WDF_TASK_SEND_OPTIONS") }}
class Kmdf_WDF_FILEOBJECT_CONFIG extends Struct { Kmdf_WDF_FILEOBJECT_CONFIG() { this.getName().matches("_WDF_FILEOBJECT_CONFIG") }}
class Kmdf_WDF_DEVICE_PNP_NOTIFICATION_DATA extends Struct { Kmdf_WDF_DEVICE_PNP_NOTIFICATION_DATA() { this.getName().matches("_WDF_DEVICE_PNP_NOTIFICATION_DATA") }}
class Kmdf_WDF_DEVICE_POWER_NOTIFICATION_DATA extends Struct { Kmdf_WDF_DEVICE_POWER_NOTIFICATION_DATA() { this.getName().matches("_WDF_DEVICE_POWER_NOTIFICATION_DATA") }}
class Kmdf_WDF_DEVICE_POWER_POLICY_NOTIFICATION_DATA extends Struct { Kmdf_WDF_DEVICE_POWER_POLICY_NOTIFICATION_DATA() { this.getName().matches("_WDF_DEVICE_POWER_POLICY_NOTIFICATION_DATA") }}
class Kmdf_WDF_PNPPOWER_EVENT_CALLBACKS extends Struct { Kmdf_WDF_PNPPOWER_EVENT_CALLBACKS() { this.getName().matches("_WDF_PNPPOWER_EVENT_CALLBACKS") }}
class Kmdf_WDF_POWER_POLICY_EVENT_CALLBACKS extends Struct { Kmdf_WDF_POWER_POLICY_EVENT_CALLBACKS() { this.getName().matches("_WDF_POWER_POLICY_EVENT_CALLBACKS") }}
class Kmdf_WDF_DEVICE_POWER_POLICY_IDLE_SETTINGS extends Struct { Kmdf_WDF_DEVICE_POWER_POLICY_IDLE_SETTINGS() { this.getName().matches("_WDF_DEVICE_POWER_POLICY_IDLE_SETTINGS") }}
class Kmdf_WDF_DEVICE_POWER_POLICY_WAKE_SETTINGS extends Struct { Kmdf_WDF_DEVICE_POWER_POLICY_WAKE_SETTINGS() { this.getName().matches("_WDF_DEVICE_POWER_POLICY_WAKE_SETTINGS") }}
class Kmdf_WDF_DEVICE_STATE extends Struct { Kmdf_WDF_DEVICE_STATE() { this.getName().matches("_WDF_DEVICE_STATE") }}
class Kmdf_WDF_DEVICE_PNP_CAPABILITIES extends Struct { Kmdf_WDF_DEVICE_PNP_CAPABILITIES() { this.getName().matches("_WDF_DEVICE_PNP_CAPABILITIES") }}
class Kmdf_WDF_DEVICE_POWER_CAPABILITIES extends Struct { Kmdf_WDF_DEVICE_POWER_CAPABILITIES() { this.getName().matches("_WDF_DEVICE_POWER_CAPABILITIES") }}
class Kmdf_WDF_REMOVE_LOCK_OPTIONS extends Struct { Kmdf_WDF_REMOVE_LOCK_OPTIONS() { this.getName().matches("_WDF_REMOVE_LOCK_OPTIONS") }}
class Kmdf_WDF_POWER_FRAMEWORK_SETTINGS extends Struct { Kmdf_WDF_POWER_FRAMEWORK_SETTINGS() { this.getName().matches("_WDF_POWER_FRAMEWORK_SETTINGS") }}
class Kmdf_WDF_IO_TYPE_CONFIG extends Struct { Kmdf_WDF_IO_TYPE_CONFIG() { this.getName().matches("_WDF_IO_TYPE_CONFIG") }}
class Kmdf_WDF_DEVICE_PROPERTY_DATA extends Struct { Kmdf_WDF_DEVICE_PROPERTY_DATA() { this.getName().matches("_WDF_DEVICE_PROPERTY_DATA") }}
class Kmdf_WDF_DMA_ENABLER_CONFIG extends Struct { Kmdf_WDF_DMA_ENABLER_CONFIG() { this.getName().matches("_WDF_DMA_ENABLER_CONFIG") }}
class Kmdf_WDF_DMA_SYSTEM_PROFILE_CONFIG extends Struct { Kmdf_WDF_DMA_SYSTEM_PROFILE_CONFIG() { this.getName().matches("_WDF_DMA_SYSTEM_PROFILE_CONFIG") }}
class Kmdf_WDF_DPC_CONFIG extends Struct { Kmdf_WDF_DPC_CONFIG() { this.getName().matches("_WDF_DPC_CONFIG") }}
class Kmdf_WDF_DRIVER_CONFIG extends Struct { Kmdf_WDF_DRIVER_CONFIG() { this.getName().matches("_WDF_DRIVER_CONFIG") }}
class Kmdf_WDF_DRIVER_VERSION_AVAILABLE_PARAMS extends Struct { Kmdf_WDF_DRIVER_VERSION_AVAILABLE_PARAMS() { this.getName().matches("_WDF_DRIVER_VERSION_AVAILABLE_PARAMS") }}
class Kmdf_WDF_FDO_EVENT_CALLBACKS extends Struct { Kmdf_WDF_FDO_EVENT_CALLBACKS() { this.getName().matches("_WDF_FDO_EVENT_CALLBACKS") }}
class Kmdf_WDF_DRIVER_GLOBALS extends Struct { Kmdf_WDF_DRIVER_GLOBALS() { this.getName().matches("_WDF_DRIVER_GLOBALS") }}
class Kmdf_WDF_COINSTALLER_INSTALL_OPTIONS extends Struct { Kmdf_WDF_COINSTALLER_INSTALL_OPTIONS() { this.getName().matches("_WDF_COINSTALLER_INSTALL_OPTIONS") }}
class Kmdf_WDF_INTERRUPT_CONFIG extends Struct { Kmdf_WDF_INTERRUPT_CONFIG() { this.getName().matches("_WDF_INTERRUPT_CONFIG") }}
class Kmdf_WDF_INTERRUPT_INFO extends Struct { Kmdf_WDF_INTERRUPT_INFO() { this.getName().matches("_WDF_INTERRUPT_INFO") }}
class Kmdf_WDF_INTERRUPT_EXTENDED_POLICY extends Struct { Kmdf_WDF_INTERRUPT_EXTENDED_POLICY() { this.getName().matches("_WDF_INTERRUPT_EXTENDED_POLICY") }}
class Kmdf_WDF_IO_QUEUE_CONFIG extends Struct { Kmdf_WDF_IO_QUEUE_CONFIG() { this.getName().matches("_WDF_IO_QUEUE_CONFIG") }}
class Kmdf_WDF_IO_QUEUE_FORWARD_PROGRESS_POLICY extends Struct { Kmdf_WDF_IO_QUEUE_FORWARD_PROGRESS_POLICY() { this.getName().matches("_WDF_IO_QUEUE_FORWARD_PROGRESS_POLICY") }}
class Kmdf_WDF_IO_TARGET_OPEN_PARAMS extends Struct { Kmdf_WDF_IO_TARGET_OPEN_PARAMS() { this.getName().matches("_WDF_IO_TARGET_OPEN_PARAMS") }}
class Kmdf_WDFMEMORY_OFFSET extends Struct { Kmdf_WDFMEMORY_OFFSET() { this.getName().matches("_WDFMEMORY_OFFSET") }}
class Kmdf_WDF_MEMORY_DESCRIPTOR extends Struct { Kmdf_WDF_MEMORY_DESCRIPTOR() { this.getName().matches("_WDF_MEMORY_DESCRIPTOR") }}
class Kmdf_WDF_OBJECT_ATTRIBUTES extends Struct { Kmdf_WDF_OBJECT_ATTRIBUTES() { this.getName().matches("_WDF_OBJECT_ATTRIBUTES") }}
class Kmdf_WDF_OBJECT_CONTEXT_TYPE_INFO extends Struct { Kmdf_WDF_OBJECT_CONTEXT_TYPE_INFO() { this.getName().matches("_WDF_OBJECT_CONTEXT_TYPE_INFO") }}
class Kmdf_WDF_CUSTOM_TYPE_CONTEXT extends Struct { Kmdf_WDF_CUSTOM_TYPE_CONTEXT() { this.getName().matches("_WDF_CUSTOM_TYPE_CONTEXT") }}
class Kmdf_WDF_PDO_EVENT_CALLBACKS extends Struct { Kmdf_WDF_PDO_EVENT_CALLBACKS() { this.getName().matches("_WDF_PDO_EVENT_CALLBACKS") }}
class Kmdf_WDF_QUERY_INTERFACE_CONFIG extends Struct { Kmdf_WDF_QUERY_INTERFACE_CONFIG() { this.getName().matches("_WDF_QUERY_INTERFACE_CONFIG") }}
class Kmdf_WDF_REQUEST_PARAMETERS extends Struct { Kmdf_WDF_REQUEST_PARAMETERS() { this.getName().matches("_WDF_REQUEST_PARAMETERS") }}
class Kmdf_WDF_REQUEST_COMPLETION_PARAMS extends Struct { Kmdf_WDF_REQUEST_COMPLETION_PARAMS() { this.getName().matches("_WDF_REQUEST_COMPLETION_PARAMS") }}
class Kmdf_WDF_REQUEST_REUSE_PARAMS extends Struct { Kmdf_WDF_REQUEST_REUSE_PARAMS() { this.getName().matches("_WDF_REQUEST_REUSE_PARAMS") }}
class Kmdf_WDF_REQUEST_SEND_OPTIONS extends Struct { Kmdf_WDF_REQUEST_SEND_OPTIONS() { this.getName().matches("_WDF_REQUEST_SEND_OPTIONS") }}
class Kmdf_WDF_REQUEST_FORWARD_OPTIONS extends Struct { Kmdf_WDF_REQUEST_FORWARD_OPTIONS() { this.getName().matches("_WDF_REQUEST_FORWARD_OPTIONS") }}
class Kmdf_WDF_TIMER_CONFIG extends Struct { Kmdf_WDF_TIMER_CONFIG() { this.getName().matches("_WDF_TIMER_CONFIG") }}
class Kmdf_WDF_USB_REQUEST_COMPLETION_PARAMS extends Struct { Kmdf_WDF_USB_REQUEST_COMPLETION_PARAMS() { this.getName().matches("_WDF_USB_REQUEST_COMPLETION_PARAMS") }}
class Kmdf_WDF_USB_CONTINUOUS_READER_CONFIG extends Struct { Kmdf_WDF_USB_CONTINUOUS_READER_CONFIG() { this.getName().matches("_WDF_USB_CONTINUOUS_READER_CONFIG") }}
class Kmdf_WDF_USB_DEVICE_INFORMATION extends Struct { Kmdf_WDF_USB_DEVICE_INFORMATION() { this.getName().matches("_WDF_USB_DEVICE_INFORMATION") }}
class Kmdf_WDF_USB_INTERFACE_SETTING_PAIR extends Struct { Kmdf_WDF_USB_INTERFACE_SETTING_PAIR() { this.getName().matches("_WDF_USB_INTERFACE_SETTING_PAIR") }}
class Kmdf_WDF_USB_DEVICE_SELECT_CONFIG_PARAMS extends Struct { Kmdf_WDF_USB_DEVICE_SELECT_CONFIG_PARAMS() { this.getName().matches("_WDF_USB_DEVICE_SELECT_CONFIG_PARAMS") }}
class Kmdf_WDF_USB_INTERFACE_SELECT_SETTING_PARAMS extends Struct { Kmdf_WDF_USB_INTERFACE_SELECT_SETTING_PARAMS() { this.getName().matches("_WDF_USB_INTERFACE_SELECT_SETTING_PARAMS") }}
class Kmdf_WDF_USB_PIPE_INFORMATION extends Struct { Kmdf_WDF_USB_PIPE_INFORMATION() { this.getName().matches("_WDF_USB_PIPE_INFORMATION") }}
class Kmdf_WDF_USB_DEVICE_CREATE_CONFIG extends Struct { Kmdf_WDF_USB_DEVICE_CREATE_CONFIG() { this.getName().matches("_WDF_USB_DEVICE_CREATE_CONFIG") }}
class Kmdf_WDF_WMI_PROVIDER_CONFIG extends Struct { Kmdf_WDF_WMI_PROVIDER_CONFIG() { this.getName().matches("_WDF_WMI_PROVIDER_CONFIG") }}
class Kmdf_WDF_WMI_INSTANCE_CONFIG extends Struct { Kmdf_WDF_WMI_INSTANCE_CONFIG() { this.getName().matches("_WDF_WMI_INSTANCE_CONFIG") }}
class Kmdf_WDF_WORKITEM_CONFIG extends Struct { Kmdf_WDF_WORKITEM_CONFIG() { this.getName().matches("_WDF_WORKITEM_CONFIG") }}
