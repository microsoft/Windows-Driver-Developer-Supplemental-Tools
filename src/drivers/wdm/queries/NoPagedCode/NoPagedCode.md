# No PAGED_CODE invocation
The function has been declared to be in a paged segment, but neither PAGED_CODE nor PAGED_CODE_LOCKED was found.


## Recommendation
The functions in pageable code must contain a PAGED_CODE or PAGED_CODE_LOCKED macro at the beginning of the function. The PAGED_CODE macro ensures that the calling thread is running at an IRQL that is low enough to permit paging.


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
    
    return STATUS_SUCCESS;
}


#pragma code_seg("PAGE")
//Fails
NTSTATUS func1(){
    if(TRUE){

    }
    return STATUS_SUCCESS;
}
#pragma code_seg()

//Passes
NTSTATUS func2(){
    return STATUS_SUCCESS;
}

#define PAGED_CODE_SEG __declspec(code_seg("PAGE"))
//Fails
PAGED_CODE_SEG
NTSTATUS func3(){
    return STATUS_SUCCESS;
}
```

## References
* [ C28170 warning - Windows Drivers ](https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/28170-pageable-code-macro-not-found)
