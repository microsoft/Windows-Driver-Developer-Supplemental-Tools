/*
  Test snippet for DoubleCompletion rule.

  Scenario 1 (DEFECT): Direct double completion in the same callback.
  WdfRequestComplete is called twice on the same Request handle.

  Scenario 2 (DEFECT): Double completion through a helper function.
  The callback completes the request, then calls a helper that also completes it.

  Scenario 3 (PASS): Single completion at the end of the callback.

  Scenario 4 (PASS): Request completed in mutually exclusive branches (only once).

  Scenario 5 (PASS): Variable reused after WdfIoQueueRetrieveNextRequest.
*/

// Template function required by test harness.
void top_level_call() {}

#define IOCTL_CUSTOM  CTL_CODE(FILE_DEVICE_UNKNOWN, 0x800, METHOD_BUFFERED, FILE_ANY_ACCESS)
#define IOCTL_A       CTL_CODE(FILE_DEVICE_UNKNOWN, 0x801, METHOD_BUFFERED, FILE_ANY_ACCESS)
#define IOCTL_B       CTL_CODE(FILE_DEVICE_UNKNOWN, 0x802, METHOD_BUFFERED, FILE_ANY_ACCESS)

NTSTATUS ProcessCustomIoctl(_In_ WDFREQUEST Request) {
    UNREFERENCED_PARAMETER(Request);
    return STATUS_SUCCESS;
}

// -- Scenario 1: Direct double completion (DEFECT) --

EVT_WDF_IO_QUEUE_IO_INTERNAL_DEVICE_CONTROL EvtIoInternalDeviceControl_Defect;
VOID
EvtIoInternalDeviceControl_Defect(
    _In_ WDFQUEUE Queue,
    _In_ WDFREQUEST Request,
    _In_ size_t OutputBufferLength,
    _In_ size_t InputBufferLength,
    _In_ ULONG IoControlCode)
{
    NTSTATUS status;
    UNREFERENCED_PARAMETER(Queue);
    UNREFERENCED_PARAMETER(OutputBufferLength);
    UNREFERENCED_PARAMETER(InputBufferLength);

    switch (IoControlCode) {
    case IOCTL_CUSTOM:
        status = ProcessCustomIoctl(Request);
        WdfRequestComplete(Request, status);    // First completion
        break;
    default:
        status = STATUS_INVALID_DEVICE_REQUEST;
        break;
    }

    WdfRequestComplete(Request, status);        // DEFECT: second completion
}

// -- Scenario 2: Double completion via helper (DEFECT) --

VOID
CompleteHelper(
    _In_ WDFREQUEST Request,
    _In_ NTSTATUS Status)
{
    WdfRequestComplete(Request, Status);        // DEFECT: second completion
}

EVT_WDF_IO_QUEUE_IO_READ EvtIoRead_Defect;
VOID
EvtIoRead_Defect(
    _In_ WDFQUEUE Queue,
    _In_ WDFREQUEST Request,
    _In_ size_t Length)
{
    NTSTATUS status = STATUS_SUCCESS;
    UNREFERENCED_PARAMETER(Queue);
    UNREFERENCED_PARAMETER(Length);
    WdfRequestComplete(Request, status);        // First completion
    CompleteHelper(Request, status);             // Calls complete again
}

// -- Scenario 3: Single completion (PASS) --

EVT_WDF_IO_QUEUE_IO_READ EvtIoRead_Pass;
VOID
EvtIoRead_Pass(
    _In_ WDFQUEUE Queue,
    _In_ WDFREQUEST Request,
    _In_ size_t Length)
{
    NTSTATUS status = STATUS_SUCCESS;
    UNREFERENCED_PARAMETER(Queue);
    UNREFERENCED_PARAMETER(Length);
    // ... do work ...
    WdfRequestComplete(Request, status);        // OK: completed once
}

// -- Scenario 4: Mutually exclusive branches (PASS) --

EVT_WDF_IO_QUEUE_IO_DEVICE_CONTROL EvtIoDeviceControl_Pass;
VOID
EvtIoDeviceControl_Pass(
    _In_ WDFQUEUE Queue,
    _In_ WDFREQUEST Request,
    _In_ size_t OutputBufferLength,
    _In_ size_t InputBufferLength,
    _In_ ULONG IoControlCode)
{
    NTSTATUS status;
    UNREFERENCED_PARAMETER(Queue);
    UNREFERENCED_PARAMETER(OutputBufferLength);
    UNREFERENCED_PARAMETER(InputBufferLength);

    switch (IoControlCode) {
    case IOCTL_A:
        status = STATUS_SUCCESS;
        WdfRequestComplete(Request, status);    // OK: only in this branch
        return;
    case IOCTL_B:
        status = STATUS_NOT_SUPPORTED;
        WdfRequestCompleteWithInformation(Request, status, 0); // OK: different branch
        return;
    default:
        status = STATUS_INVALID_DEVICE_REQUEST;
        WdfRequestComplete(Request, status);    // OK: default branch
        return;
    }
}

// -- Scenario 5: Variable reused after WdfIoQueueRetrieveNextRequest (PASS) --
// The _Out_ parameter overwrites the request variable with a new handle,
// so the second completion is on a DIFFERENT request.

EVT_WDF_IO_QUEUE_IO_READ EvtIoRead_RetrieveNext_Pass;
VOID
EvtIoRead_RetrieveNext_Pass(
    _In_ WDFQUEUE Queue,
    _In_ WDFREQUEST Request,
    _In_ size_t Length)
{
    NTSTATUS status = STATUS_SUCCESS;
    UNREFERENCED_PARAMETER(Length);
    WdfRequestComplete(Request, status);            // Complete first request

    // Retrieve a NEW request -- overwrites the variable
    WdfIoQueueRetrieveNextRequest(Queue, &Request);

    WdfRequestComplete(Request, STATUS_SUCCESS);    // OK: completing NEW request
}

// -- Scenario 6: Direct double completion (DEFECT) --

EVT_WDF_IO_QUEUE_IO_INTERNAL_DEVICE_CONTROL EvtIoInternalDeviceControl_SafeConditionalPass;
VOID
EvtIoInternalDeviceControl_SafeConditionalPass(
    _In_ WDFQUEUE Queue,
    _In_ WDFREQUEST Request,
    _In_ size_t OutputBufferLength,
    _In_ size_t InputBufferLength,
    _In_ ULONG IoControlCode)
{
    NTSTATUS status;
    BOOLEAN isComplete = FALSE;
    UNREFERENCED_PARAMETER(Queue);
    UNREFERENCED_PARAMETER(OutputBufferLength);
    UNREFERENCED_PARAMETER(InputBufferLength);

    switch (IoControlCode) {
    case IOCTL_CUSTOM:
        status = ProcessCustomIoctl(Request);
        WdfRequestComplete(Request, status);    // First completion
        isComplete = TRUE;
        break;
    default:
        status = STATUS_INVALID_DEVICE_REQUEST;
        break;
    }

    if (!isComplete) {
        WdfRequestComplete(Request, status);    // OK: only complete if not already completed
    }
}