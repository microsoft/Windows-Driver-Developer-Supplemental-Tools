
/**
The two function declarations below are unrelated to this test. The reason they are here is because including them in the WDMTestingTemplate will interfer with DispatchAnnotationMissing and DispatchMismatch tests.
 */

_Dispatch_type_(IRP_MJ_PNP)
DRIVER_DISPATCH DispatchPnp; 

_Dispatch_type_(IRP_MJ_CREATE) 
DRIVER_DISPATCH DispatchCreate;
void top_level_call(){
    
}