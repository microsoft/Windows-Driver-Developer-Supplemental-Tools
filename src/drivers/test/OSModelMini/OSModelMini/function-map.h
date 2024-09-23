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
//WDF
/*
#define fun_WDF_DRIVER_DEVICE_ADD EvtDriverDeviceAdd
#define fun_WDF_IO_QUEUE_IO_DEVICE_CONTROL EvtIoDeviceControl

*/