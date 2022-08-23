<<<<<<< HEAD
/*
//Bad use example
DRIVER_DISPATCH SampleCreate;
pDo->MajorFunction[IRP_MJ_CREATE] = SampleCreate;

//Good use example 
_Dispatch_type_(IRP_MJ_CREATE) DRIVER_DISPATCH SampleCreate;
pDo->MajorFunction[IRP_MJ_CREATE] = SampleCreate;

*/

=======
>>>>>>> 9cc8e27942839d6c64e90599f4c96ab8bbfeefd4
#ifdef __cplusplus
extern "C" {
#endif
#include <wdm.h>
#ifdef __cplusplus
}
#endif

<<<<<<< HEAD
//passes
_Dispatch_type_(IRP_MJ_PNP)
DRIVER_DISPATCH DispatchPnp; 
//raises warning: the SAL annotation in the declaration doesn't match the expected type in MajorFunction table. 
_Dispatch_type_(IRP_MJ_CLOSE) 
DRIVER_DISPATCH DispatchCreate;
=======
//Passes
_Dispatch_type_(IRP_MJ_PNP)
DRIVER_DISPATCH DispatchPnp; 
//Fails: The two function declarations below result in bug check as a routine's declared type doesn't match the type expected in the driver table entry.
_Dispatch_type_(IRP_MJ_CLOSE) 
DRIVER_DISPATCH DispatchCreate;

_Function_class_(IRP_MJ_READ)
_Function_class_(DRIVER_DISPATCH)
NTSTATUS
DispatchRead (
    _In_ PDEVICE_OBJECT DeviceObject,
    _Inout_ PIRP Irp
    );

void top_level_call(){
}
>>>>>>> 9cc8e27942839d6c64e90599f4c96ab8bbfeefd4
