# Multiple instances of PAGED_CODE or PAGED_CODE_LOCKED
The function has more than one instance of PAGED_CODE or PAGED_CODE_LOCKED. This warning indicates that there is more than one instance of the PAGED_CODE or PAGED_CODE_LOCKED macro in a function. This error is reported at the second or subsequent instances of the PAGED_CODE or PAGED_CODE_LOCKED macro.


## Recommendation
Remove all but one PAGED_CODE OR PAGED_CODE_LOCKED macro.


## Example

```c
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.


//Macros to enable or disable a code section that may or maynot conflict with this test.
#define SET_DISPATCH 1
#define SET_PAGE_CODE 1


_Dispatch_type_(IRP_MJ_CLEANUP) 
DRIVER_DISPATCH DispatchCleanup;

_Dispatch_type_(IRP_MJ_SHUTDOWN)
DRIVER_DISPATCH DispatchShutdown;

#ifndef __cplusplus
#pragma alloc_text (PAGE, DispatchCleanup)
#pragma alloc_text (PAGE, DispatchShutdown)
#endif


//Template
void top_level_call(){
}

//Passes
NTSTATUS
DispatchCleanup (
    PDEVICE_OBJECT DriverObject,
    PIRP Irp
    )
{
    UNREFERENCED_PARAMETER(DriverObject);
    UNREFERENCED_PARAMETER(Irp);
    PAGED_CODE();
    
    return STATUS_SUCCESS;
}

//Fails
NTSTATUS
DispatchShutdown (
    PDEVICE_OBJECT DriverObject,
    PIRP Irp
    )
{
    UNREFERENCED_PARAMETER(DriverObject);
    UNREFERENCED_PARAMETER(Irp);
    PAGED_CODE();
    PAGED_CODE();
    
    return STATUS_SUCCESS;
}






```

## References
* [ C28171 warning - Windows Drivers ](https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/28171-function-has-more-than-one-page-macro-instance)
