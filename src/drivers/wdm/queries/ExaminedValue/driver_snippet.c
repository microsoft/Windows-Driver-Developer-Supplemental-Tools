
_Check_return_
NTSTATUS func1(){
    return STATUS_SUCCESS;

}
_Check_return_
NTSTATUS func2(){
    return STATUS_SUCCESS;

}

_Must_inspect_result_
NTSTATUS func3(){
    return STATUS_SUCCESS;
}

// #if (NTDDI_VERSION >= NTDDI_VISTASP1)
// _When_(Flags | OPLOCK_FLAG_BACK_OUT_ATOMIC_OPLOCK, _Must_inspect_result_)
// _IRQL_requires_max_(APC_LEVEL)
// // NTKERNELAPI
// NTSTATUS func4();
// #endif

_Must_inspect_result_
NTSTATUS func4(){
    // int[] rank = new int[5];

    return STATUS_SUCCESS;
}

void top_level_call(){
    NTSTATUS status1, status2, status3, status4, status5;
    status1 = func1();
    status2 = func2();
    status3 = func3();

    status4 = func4();
    status4 = func3();
    
    status5 = func1();

    if(NT_SUCCESS(status1)){

    }

    if(!NT_SUCCESS(status2)){

    }
 
    if(status4){

    }

    if(status5){

    }

    func4();//special case
}









/**
The two function declarations below are unrelated to this test. The reason they are here is because including them in the WDMTestingTemplate will interfer with DispatchAnnotationMissing and DispatchMismatch tests.
 */

_Dispatch_type_(IRP_MJ_PNP)
DRIVER_DISPATCH DispatchPnp; 

_Dispatch_type_(IRP_MJ_CREATE) 
DRIVER_DISPATCH DispatchCreate;
