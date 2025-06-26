// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}

__drv_functionClass(FAKE_DRIVER_ADD_DEVICE)
__drv_functionClass(FAKE_DRIVER_ADD_DEVICE2)
__drv_maxFunctionIRQL(PASSIVE_LEVEL)
__drv_requiresIRQL(PASSIVE_LEVEL)
__drv_sameIRQL
__drv_when(return >= 0, __drv_clearDoInit(yes)) typedef NTSTATUS
FAKE_DRIVER_ADD_DEVICE(
    __in struct _DRIVER_OBJECT *DriverObject,
    __in struct _DEVICE_OBJECT *PhysicalDeviceObject);

typedef FAKE_DRIVER_ADD_DEVICE *PDRIVER_ADD_DEVICE;

FAKE_DRIVER_ADD_DEVICE FakeDriverAddDevice;

_Use_decl_annotations_
    NTSTATUS
    FakeDriverAddDevice(
        __in struct _DRIVER_OBJECT *DriverObject,
        __in struct _DEVICE_OBJECT *PhysicalDeviceObject)
{
    return STATUS_SUCCESS;
}
