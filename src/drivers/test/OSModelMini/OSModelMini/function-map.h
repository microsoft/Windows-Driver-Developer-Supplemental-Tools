//Approved=false
//DriverEntry
#define fun_DriverEntry DriverEntry

//WDM
#define fun_AddDevice DriverAddDevice
#define fun_DriverStartIo StartIo
#define fun_IRP_MJ_INTERNAL_DEVICE_CONTROL InternalDeviceControl
#define fun_DRIVER_CONTROL FailDriverControllerRoutine
#define fun_DriverUnload DriverUnload
#define fun_IO_DPC_ROUTINE_1 DpcForIsrRoutine
#define fun_DispatchPnp DispatchPnp
#define fun_DispatchPower DispatchPower


#define fun_DriverEntry DriverEntry_good
#define fun_AddDevice_good DriverAddDevice_good
#define fun_DriverStartIo_good StartIo_good
#define fun_IRP_MJ_INTERNAL_DEVICE_CONTROL_good InternalDeviceControl_good
#define fun_DRIVER_CONTROL_good FailDriverControllerRoutine_good
#define fun_DriverUnload_good DriverUnload_good
#define fun_IO_DPC_ROUTINE_1_good DpcForIsrRoutine_good
#define fun_DispatchPnp_good DispatchPnp_good
#define fun_DispatchPower_good DispatchPower_good


//WDF
/*
#define fun_WDF_DRIVER_DEVICE_ADD EvtDriverDeviceAdd
#define fun_WDF_IO_QUEUE_IO_DEVICE_CONTROL EvtIoDeviceControl

*/