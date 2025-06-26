// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1

DRIVER_ADD_DEVICE AddDevice_Pass1;
DRIVER_ADD_DEVICE AddDevice_Pass2;
DRIVER_ADD_DEVICE AddDevice_Fail1;
DRIVER_ADD_DEVICE AddDevice_Fail2;

// Template. Not called in this test.
void top_level_call() {}

// PASS: Directly creates the FDO and clears flags

NTSTATUS
AddDevice_Pass1 (
    PDRIVER_OBJECT DriverObject,
    PDEVICE_OBJECT PhysicalDeviceObject
    )
{
    PDEVICE_OBJECT device;
	PDEVICE_OBJECT TopOfStack;
    NTSTATUS status;
    
    UNREFERENCED_PARAMETER(PhysicalDeviceObject);
    
    PAGED_CODE();

    status = IoCreateDevice(DriverObject,                 
                            sizeof(DRIVER_DEVICE_EXTENSION), 
                            NULL,                   
                            FILE_DEVICE_DISK,  
                            0,                     
                            FALSE,                 
                            &device                
                            );
    if(status==STATUS_SUCCESS)
    {
        device->Flags &= ~DO_DEVICE_INITIALIZING;
    }

   return status;
}

// PASS: Indirectly creates the FDO and clears flags
NTSTATUS
AddDevice_Pass2 (
    PDRIVER_OBJECT DriverObject,
    PDEVICE_OBJECT PhysicalDeviceObject
    )
{
    NTSTATUS status;
    
    UNREFERENCED_PARAMETER(PhysicalDeviceObject);
    
    PAGED_CODE();

    status = AddDevice_Pass1(DriverObject, PhysicalDeviceObject);

   return status;
}

// FAIL: Creates the FDO but doesn't clear flags
NTSTATUS
AddDevice_Fail1 (
    PDRIVER_OBJECT DriverObject,
    PDEVICE_OBJECT PhysicalDeviceObject
    )
{
    PDEVICE_OBJECT device;
	PDEVICE_OBJECT TopOfStack;
    NTSTATUS status;
    
    UNREFERENCED_PARAMETER(PhysicalDeviceObject);
    
    PAGED_CODE();

    status = IoCreateDevice(DriverObject,                 
                            sizeof(DRIVER_DEVICE_EXTENSION), 
                            NULL,                   
                            FILE_DEVICE_DISK,  
                            0,                     
                            FALSE,                 
                            &device                
                            );
   return status;
}

// FAIL: Creates the FDO but doesn't clear the correct flags 
NTSTATUS
AddDevice_Fail2 (
    PDRIVER_OBJECT DriverObject,
    PDEVICE_OBJECT PhysicalDeviceObject
    )
{
    PDEVICE_OBJECT device;
	PDEVICE_OBJECT TopOfStack;
    NTSTATUS status;
    
    UNREFERENCED_PARAMETER(PhysicalDeviceObject);
    
    PAGED_CODE();

    status = IoCreateDevice(DriverObject,                 
                            sizeof(DRIVER_DEVICE_EXTENSION), 
                            NULL,                   
                            FILE_DEVICE_DISK,  
                            0,                     
                            FALSE,                 
                            &device                
                            );
    if(status==STATUS_SUCCESS)
    {
        device->Flags &= ~DO_POWER_PAGABLE;
    }
   return status;
}