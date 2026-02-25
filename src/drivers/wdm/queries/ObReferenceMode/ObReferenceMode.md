# The AccessMode parameter to ObReferenceObject* should be IRP->RequestorMode (C28126)
In a dispatch routine call to ObReferenceObjectByHandle or ObReferenceObjectByPointer, the driver is passing UserMode or KernelMode for the AccessMode parameter, instead of using Irp-&gt;RequestorMode.

This check applies only to the top driver in the stack. It can be ignored or suppressed otherwise.


## Recommendation
The top-level driver in the driver stack should use Irp-&gt;RequestorMode, rather than specifying UserMode or KernelMode. This allows the senders of kernel-mode IRP to supply kernel-mode handles safely.


## Example

```c
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1
#define SET_CUSTOM_CREATE

_Dispatch_type_(IRP_MJ_PNP)
DRIVER_DISPATCH DispatchPnp; 
_Dispatch_type_(IRP_MJ_READ) 
DRIVER_DISPATCH DispatchRead;

// Template. Not called in this test.
void top_level_call() {}

_Dispatch_type_(IRP_MJ_CREATE) 
NTSTATUS
DispatchCreate (
    PDEVICE_OBJECT DeviceObject,
    PIRP Irp
    )
{
    ObReferenceObjectByPointer(NULL, 0, 0, KernelMode); // ERROR
    ObReferenceObjectByPointer(NULL, 0, 0, Irp->RequestorMode); // GOOD
    return STATUS_SUCCESS;
}
```

## References
* [ C28126 warning - Windows Drivers ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28126-accessmode-param-incorrect)
