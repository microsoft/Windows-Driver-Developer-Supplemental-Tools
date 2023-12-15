/*++

Module Name:

    driver.c

Abstract:

    This file contains the driver entry points and callbacks.

    This is a sample driver that contains intentionally placed
    code defects in order to illustrate how CodeQL finds and reports defects.
    This driver sample/template is not functional.

    The include directive below for driver_snippet.cpp is where test snippets
    will be loaded from.


Environment:

    Kernel-mode Driver Framework

--*/

#include "driver.h"
#include "driver.tmh"

PVOID operator new(
    size_t iSize,
    _When_((poolType & NonPagedPoolMustSucceed) != 0,
           __drv_reportError("Must succeed pool allocations are forbidden. "
                             "Allocation failures cause a system crash"))
        POOL_TYPE poolType)
{
    return ExAllocatePoolZero(poolType, iSize, 'wNCK');
}

PVOID operator new(
    size_t iSize,
    _When_((poolType & NonPagedPoolMustSucceed) != 0,
           __drv_reportError("Must succeed pool allocations are forbidden. "
                             "Allocation failures cause a system crash"))
        POOL_TYPE poolType,
    ULONG tag)
{
    return ExAllocatePoolZero(poolType, iSize, tag);
}

PVOID
operator new[](
    size_t iSize,
    _When_((poolType & NonPagedPoolMustSucceed) != 0,
           __drv_reportError("Must succeed pool allocations are forbidden. "
                             "Allocation failures cause a system crash"))
        POOL_TYPE poolType,
    ULONG tag)
{
    return ExAllocatePoolZero(poolType, iSize, tag);
}

/*++

Routine Description:

    Array delete() operator.

Arguments:

    pVoid -
        The memory to free.

Return Value:

    None

--*/
void __cdecl
operator delete[](
    PVOID pVoid)
{
    if (pVoid)
    {
        ExFreePool(pVoid);
    }
}

/*++

Routine Description:

    Sized delete() operator.

Arguments:

    pVoid -
        The memory to free.

    size -
        The size of the memory to free.

Return Value:

    None

--*/
void __cdecl operator delete(
    void *pVoid,
    size_t /*size*/
)
{
    if (pVoid)
    {
        ExFreePool(pVoid);
    }
}

/*++

Routine Description:

    Sized delete[]() operator.

Arguments:

    pVoid -
        The memory to free.

    size -
        The size of the memory to free.

Return Value:

    None

--*/
void __cdecl operator delete[](
    void *pVoid,
    size_t /*size*/
)
{
    if (pVoid)
    {
        ExFreePool(pVoid);
    }
}

void __cdecl operator delete(
    PVOID pVoid)
{
    if (pVoid)
    {
        ExFreePool(pVoid);
    }
}
#ifdef ALLOC_PRAGMA
#pragma alloc_text(INIT, DriverEntry)
#pragma alloc_text(PAGE, CppKMDFTestTemplateEvtDeviceAdd)
#pragma alloc_text(PAGE, CppKMDFTestTemplateEvtDriverContextCleanup)
#endif

#include "driver/driver_snippet.cpp"



extern "C" DRIVER_INITIALIZE DriverEntry;

extern "C" NTSTATUS
DriverEntry(
    _In_ PDRIVER_OBJECT DriverObject,
    _In_ PUNICODE_STRING RegistryPath)
/*++

Routine Description:
    DriverEntry initializes the driver and is the first routine called by the
    system after the driver is loaded. DriverEntry specifies the other entry
    points in the function driver, such as EvtDevice and DriverUnload.

Parameters Description:

    DriverObject - represents the instance of the function driver that is loaded
    into memory. DriverEntry must initialize members of DriverObject before it
    returns to the caller. DriverObject is allocated by the system before the
    driver is loaded, and it is released by the system after the system unloads
    the function driver from memory.

    RegistryPath - represents the driver specific path in the Registry.
    The function driver can use the path to store driver related data between
    reboots. The path does not store hardware instance specific data.

Return Value:

    STATUS_SUCCESS if successful,
    STATUS_UNSUCCESSFUL otherwise.

--*/
{
    WDF_DRIVER_CONFIG config;
    NTSTATUS status;
    WDF_OBJECT_ATTRIBUTES attributes;

    //
    // Initialize WPP Tracing
    //
    WPP_INIT_TRACING(DriverObject, RegistryPath);

    TraceEvents(TRACE_LEVEL_INFORMATION, TRACE_DRIVER, "%!FUNC! Entry");

    //
    // Register a cleanup callback so that we can call WPP_CLEANUP when
    // the framework driver object is deleted during driver unload.
    //
    WDF_OBJECT_ATTRIBUTES_INIT(&attributes);
    attributes.EvtCleanupCallback = CppKMDFTestTemplateEvtDriverContextCleanup;

    WDF_DRIVER_CONFIG_INIT(&config,
                           CppKMDFTestTemplateEvtDeviceAdd);

    status = WdfDriverCreate(DriverObject,
                             RegistryPath,
                             &attributes,
                             &config,
                             WDF_NO_HANDLE);

    if (!NT_SUCCESS(status))
    {
        TraceEvents(TRACE_LEVEL_ERROR, TRACE_DRIVER, "WdfDriverCreate failed %!STATUS!", status);
        WPP_CLEANUP(DriverObject);
        return status;
    }

    TraceEvents(TRACE_LEVEL_INFORMATION, TRACE_DRIVER, "%!FUNC! Exit");

    return status;
}

NTSTATUS
CppKMDFTestTemplateEvtDeviceAdd(
    _In_ WDFDRIVER Driver,
    _Inout_ PWDFDEVICE_INIT DeviceInit)
/*++
Routine Description:

    EvtDeviceAdd is called by the framework in response to AddDevice
    call from the PnP manager. We create and initialize a device object to
    represent a new instance of the device.

Arguments:

    Driver - Handle to a framework driver object created in DriverEntry

    DeviceInit - Pointer to a framework-allocated WDFDEVICE_INIT structure.

Return Value:

    NTSTATUS

--*/
{
    NTSTATUS status;

    UNREFERENCED_PARAMETER(Driver);

    PAGED_CODE();

    TraceEvents(TRACE_LEVEL_INFORMATION, TRACE_DRIVER, "%!FUNC! Entry");

    status = CppKMDFTestTemplateCreateDevice(DeviceInit);

    TraceEvents(TRACE_LEVEL_INFORMATION, TRACE_DRIVER, "%!FUNC! Exit");

    return status;
}

VOID CppKMDFTestTemplateEvtDriverContextCleanup(
    _In_ WDFOBJECT DriverObject)
/*++
Routine Description:

    Free all the resources allocated in DriverEntry.

Arguments:

    DriverObject - handle to a WDF Driver object.

Return Value:

    VOID.

--*/
{
    UNREFERENCED_PARAMETER(DriverObject);

    PAGED_CODE();

    TraceEvents(TRACE_LEVEL_INFORMATION, TRACE_DRIVER, "%!FUNC! Entry");

    //
    // Stop WPP Tracing
    //
    WPP_CLEANUP(WdfDriverWdmGetDriverObject((WDFDRIVER)DriverObject));
}
