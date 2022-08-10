//Both failing and passing tests added to the WDMTestingTemplate


/** Failing cases:
 * DispatchCreate will raise a warning as it has more than one invocation of PAGED_CODE. Read C28170 and C28171 on MSDN for details. 
 * 
 */


/** Passing cases:
 * All other dispatch routines should pass  
 * 
 * 
 */


void top_level_call(){
    
}


/**
The two function declarations below are unrelated to this test. The reason they are here is because including them in the WDMTestingTemplate will interfer with DispatchAnnotationMissing and DispatchMismatch tests.
 */

_Dispatch_type_(IRP_MJ_PNP)
DRIVER_DISPATCH DispatchPnp; 

_Dispatch_type_(IRP_MJ_CREATE) 
DRIVER_DISPATCH DispatchCreate;




