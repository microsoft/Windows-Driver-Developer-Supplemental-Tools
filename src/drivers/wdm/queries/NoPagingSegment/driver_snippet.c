//Both failing and passing tests cases are added to the WDMTestingTemplate


/** Failing cases:
 * DispatchPower should show failure as it has PAGED_CODE macro invocation but wasn't placed in a PAGE secion 
 * using pragmas #pragma alloc_text or #pragma code_seg.
 * 
 */


/** Passing cases:
 * All other dispatch routines should pass  
 * 
 * 
 */


/**
The two function declarations below are unrelated to this test. The reason they are here is because including them in the WDMTestingTemplate will interfer with DispatchAnnotationMissing and DispatchMismatch tests.
 */


#ifdef __cplusplus
extern "C" {
#endif
#include <wdm.h>
#ifdef __cplusplus
}
#endif

_Dispatch_type_(IRP_MJ_PNP)
DRIVER_DISPATCH DispatchPnp; 

_Dispatch_type_(IRP_MJ_CREATE) 
DRIVER_DISPATCH DispatchCreate;
void top_level_call(){
    
}