# No paging segment for PAGED_CODE macro invocation
The function has PAGED_CODE or PAGED_CODE_LOCKED but is not declared to be in a paged segment. A function that contains a PAGED_CODE or PAGED_CODE_LOCKED macro has not been placed in paged memory by using \#pragma alloc_text or \#pragma code_seg.


## Recommendation
Put a function/routine that calls PAGED_CODE in a paged section using \#pragma alloc_text or \#pragma code_seg.


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
    
    return STATUS_SUCCESS;
}


#pragma code_seg("PAGE")
//Passes
NTSTATUS func1(){
    PAGED_CODE();
    if(TRUE){
    }
    return STATUS_SUCCESS;
}
#pragma code_seg()

//Fails
NTSTATUS func2(){
    PAGED_CODE();
    return STATUS_SUCCESS;
}

#define PAGED_CODE_SEG __declspec(code_seg("PAGE"))
//Passes
PAGED_CODE_SEG
NTSTATUS func3(){
    PAGED_CODE();
    return STATUS_SUCCESS;
}
```

## References
* [ C28172 warning - Windows Drivers ](https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/28172-function-macros-not-in-paged-segment)
