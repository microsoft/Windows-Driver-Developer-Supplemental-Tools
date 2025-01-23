// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}

// FAIL _IRQL_saves_global_ not applied to entire function
VOID test1(
    _IRQL_saves_global_(OldIrql, *Irql) PKIRQL Irql)
{
    // ...
    ;
}

// FAIL using when with dispatch type
_When_(return >= 0, __drv_dispatchType(IRP_MJ_CREATE))
    VOID test2(
        IN PDRIVER_OBJECT DriverObject)
{
    ; // do nothing
}

// FAIL
_Function_class_(DRIVER_ADD_DEVICE)
    _IRQL_requires_(PASSIVE_LEVEL)
        _IRQL_requires_same_
    _When_(return >= 0, _Kernel_clear_do_init_(IRP_MJ_CREATE))
        NTSTATUS
    test3(
        _In_ PDRIVER_OBJECT DriverObject,
        _In_ PDEVICE_OBJECT PhysicalDeviceObject)

{
    ; // do nothing
}

// OK
_Function_class_(DRIVER_ADD_DEVICE)
    _IRQL_requires_(PASSIVE_LEVEL)
        _IRQL_requires_same_
    _When_(return >= 0, _Kernel_clear_do_init_(__yes))
        NTSTATUS
    test3Ok(
        _In_ PDRIVER_OBJECT DriverObject,
        _In_ PDEVICE_OBJECT PhysicalDeviceObject)

{
    ; // do nothing
}

// FAIL
_Function_class_(DRIVER_ADD_DEVICE)
    _IRQL_requires_(PASSIVE_LEVEL)
        _IRQL_requires_same_
    _Kernel_clear_do_init_(IRP_MJ_CREATE)
NTSTATUS
test4(
    _In_ PDRIVER_OBJECT DriverObject,
    _In_ PDEVICE_OBJECT PhysicalDeviceObject)

{
    ; // do nothing
}

// out of range
__drv_dispatchType(65)
    VOID test5(
        IN PDRIVER_OBJECT DriverObject)
{
    ; // do nothing
}