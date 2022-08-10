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


void top_level_call(){
    
}