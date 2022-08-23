/*
//Bad use example 1
DRIVER_DISPATCH SampleCreate;
pDo->MajorFunction[IRP_MJ_CREATE] = SampleCreate;

//Good use
_Dispatch_type_(IRP_MJ_CREATE) DRIVER_DISPATCH SampleCreate;
pDo->MajorFunction[IRP_MJ_CREATE] = SampleCreate;
*/

//No dispatch annotation
DRIVER_DISPATCH DispatchPnp;
//Right dispatch function annotation
_Dispatch_type_(IRP_MJ_CREATE)
DRIVER_DISPATCH DispatchCreate;
<<<<<<< HEAD
=======


void top_level_call(){
    
}
>>>>>>> 9cc8e27942839d6c64e90599f4c96ab8bbfeefd4
