/*
  Test snippet for DrvAckIoStop rule.

  Scenario 1 (DEFECT): Power-managed queue with no EvtIoStop and no SelfManagedIoSuspend.
  Scenario 2 (PASS): Queue has EvtIoStop registered.
  Scenario 3 (PASS): Queue is not power-managed (PowerManaged = WdfFalse).
  Scenario 4 (PASS): Driver has EvtDeviceSelfManagedIoSuspend registered.
  Scenario 5 (PASS): Filter driver with default PowerManaged (not power-managed).
*/

// Template function required by test harness.
void top_level_call() {}

// Forward declarations
EVT_WDF_IO_QUEUE_IO_READ EvtIoRead_Test;
EVT_WDF_IO_QUEUE_IO_WRITE EvtIoWrite_Test;
EVT_WDF_IO_QUEUE_IO_STOP EvtIoStop_Test;
EVT_WDF_DEVICE_SELF_MANAGED_IO_SUSPEND EvtSelfManagedIoSuspend_Test;

VOID EvtIoRead_Test(WDFQUEUE Q, WDFREQUEST R, size_t L) {
    UNREFERENCED_PARAMETER(Q); UNREFERENCED_PARAMETER(L);
    WdfRequestComplete(R, STATUS_SUCCESS);
}
VOID EvtIoWrite_Test(WDFQUEUE Q, WDFREQUEST R, size_t L) {
    UNREFERENCED_PARAMETER(Q); UNREFERENCED_PARAMETER(L);
    WdfRequestComplete(R, STATUS_SUCCESS);
}
VOID EvtIoStop_Test(WDFQUEUE Q, WDFREQUEST R, ULONG F) {
    UNREFERENCED_PARAMETER(Q); UNREFERENCED_PARAMETER(F);
    WdfRequestStopAcknowledge(R, FALSE);
}
NTSTATUS EvtSelfManagedIoSuspend_Test(WDFDEVICE D) {
    UNREFERENCED_PARAMETER(D);
    return STATUS_SUCCESS;
}

// -- Scenario 1: DEFECT - power-managed queue, no EvtIoStop, no SelfManagedIoSuspend --

NTSTATUS Scenario1_CreateQueue(WDFDEVICE Device) {
    WDF_IO_QUEUE_CONFIG queueConfig;
    WDFQUEUE queue;

    WDF_IO_QUEUE_CONFIG_INIT_DEFAULT_QUEUE(&queueConfig, WdfIoQueueDispatchSequential);
    queueConfig.EvtIoRead = EvtIoRead_Test;
    queueConfig.EvtIoWrite = EvtIoWrite_Test;
    // Missing EvtIoStop - DEFECT
    return WdfIoQueueCreate(Device, &queueConfig, WDF_NO_OBJECT_ATTRIBUTES, &queue);
}

// -- Scenario 2: PASS - has EvtIoStop --

NTSTATUS Scenario2_CreateQueue(WDFDEVICE Device) {
    WDF_IO_QUEUE_CONFIG queueConfig;
    WDFQUEUE queue;

    WDF_IO_QUEUE_CONFIG_INIT_DEFAULT_QUEUE(&queueConfig, WdfIoQueueDispatchSequential);
    queueConfig.EvtIoRead = EvtIoRead_Test;
    queueConfig.EvtIoStop = EvtIoStop_Test;  // Has EvtIoStop - PASS
    return WdfIoQueueCreate(Device, &queueConfig, WDF_NO_OBJECT_ATTRIBUTES, &queue);
}

// -- Scenario 3: PASS - not power-managed --

NTSTATUS Scenario3_CreateQueue(WDFDEVICE Device) {
    WDF_IO_QUEUE_CONFIG queueConfig;
    WDFQUEUE queue;

    WDF_IO_QUEUE_CONFIG_INIT_DEFAULT_QUEUE(&queueConfig, WdfIoQueueDispatchSequential);
    queueConfig.EvtIoRead = EvtIoRead_Test;
    queueConfig.PowerManaged = WdfFalse;  // Not power-managed - PASS
    return WdfIoQueueCreate(Device, &queueConfig, WDF_NO_OBJECT_ATTRIBUTES, &queue);
}

// -- Scenario 4: PASS - has EvtDeviceSelfManagedIoSuspend --
// NOTE: This scenario registers EvtDeviceSelfManagedIoSuspend globally,
// which suppresses findings for ALL queues in the same driver. In a real
// driver, this is correct — the callback applies to the whole device.
// Uncommenting this scenario will suppress Scenario 1's defect.
// To test this scenario, compile it in a separate driver.
/*
NTSTATUS Scenario4_Setup(PWDFDEVICE_INIT DeviceInit, WDFDEVICE Device) {
    WDF_PNPPOWER_EVENT_CALLBACKS pnpCallbacks;
    WDF_IO_QUEUE_CONFIG queueConfig;
    WDFQUEUE queue;

    WDF_PNPPOWER_EVENT_CALLBACKS_INIT(&pnpCallbacks);
    pnpCallbacks.EvtDeviceSelfManagedIoSuspend = EvtSelfManagedIoSuspend_Test;
    WdfDeviceInitSetPnpPowerEventCallbacks(DeviceInit, &pnpCallbacks);

    WDF_IO_QUEUE_CONFIG_INIT_DEFAULT_QUEUE(&queueConfig, WdfIoQueueDispatchSequential);
    queueConfig.EvtIoRead = EvtIoRead_Test;
    // No EvtIoStop, but has SelfManagedIoSuspend - PASS
    return WdfIoQueueCreate(Device, &queueConfig, WDF_NO_OBJECT_ATTRIBUTES, &queue);
}
*/
