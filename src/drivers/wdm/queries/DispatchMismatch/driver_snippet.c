#ifdef __cplusplus
extern "C" {
#endif
#include <wdm.h>
#ifdef __cplusplus
}
#endif

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