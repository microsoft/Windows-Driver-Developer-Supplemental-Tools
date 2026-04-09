/*
  Test snippet for EvtSurpriseRemoveNoSuspendQueue rule.

  Scenario 1 (DEFECT): EvtDeviceSurpriseRemoval directly calls
  WdfIoQueueStopAndPurgeSynchronously. This is incorrect because the
  surprise removal callback is not synchronized with the power-down path.

  Scenario 2 (DEFECT): EvtDeviceSurpriseRemoval indirectly calls
  WdfIoQueuePurgeSynchronously via a helper function.

  Scenario 3 (PASS): Queue purge is performed in EvtDeviceSelfManagedIoCleanup,
  which is properly synchronized.
*/

// -- Scenario 1: Direct call from surprise removal (DEFECT) --

EVT_WDF_DEVICE_SURPRISE_REMOVAL ToasterEvtDeviceSurpriseRemoval_Defect1;
VOID
ToasterEvtDeviceSurpriseRemoval_Defect1(
    _In_ WDFDEVICE Device)
{
    PFDO_DATA fdoData = ToasterFdoGetData(Device);
    WdfIoQueueStopAndPurgeSynchronously(fdoData->Queue); // DEFECT
}

// -- Scenario 2: Indirect call via helper (DEFECT) --

VOID
SurpriseRemovalHelper(
    _In_ WDFQUEUE Queue)
{
    WdfIoQueuePurgeSynchronously(Queue); // DEFECT (called transitively)
}

EVT_WDF_DEVICE_SURPRISE_REMOVAL ToasterEvtDeviceSurpriseRemoval_Defect2;
VOID
ToasterEvtDeviceSurpriseRemoval_Defect2(
    _In_ WDFDEVICE Device)
{
    PFDO_DATA fdoData = ToasterFdoGetData(Device);
    SurpriseRemovalHelper(fdoData->Queue); // calls prohibited API
}

// -- Scenario 3: Correct pattern using self-managed I/O (PASS) --

EVT_WDF_DEVICE_SURPRISE_REMOVAL ToasterEvtDeviceSurpriseRemoval_Pass;
VOID
ToasterEvtDeviceSurpriseRemoval_Pass(
    _In_ WDFDEVICE Device)
{
    // No queue operations here -- correct
    return;
}

EVT_WDF_DEVICE_SELF_MANAGED_IO_CLEANUP ToasterEvtDeviceSelfManagedIoCleanup;
VOID
ToasterEvtDeviceSelfManagedIoCleanup(
    _In_ WDFDEVICE Device)
{
    PFDO_DATA fdoData = ToasterFdoGetData(Device);
    WdfIoQueuePurgeSynchronously(fdoData->Queue); // OK: correct callback
}
