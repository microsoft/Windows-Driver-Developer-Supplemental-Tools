//Macros to enable or disable a code section that may or maynot conflict with this test.
#define SET_PENDING 0
#define SET_DISPATCH 1

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

_Must_inspect_result_
NTSTATUS func4(){
    return STATUS_SUCCESS;
}

void top_level_call(){
    NTSTATUS status1, status2, status3, status4, status5;
    //Passes
    status1 = func1();
    //Passes
    status2 = func2();
    //Fails
    status3 = func3();
    //Fails
    status4 = func4();
    //Passes
    status4 = func3();
    //Passes
    status5 = func1();

    if(NT_SUCCESS(status1)){
    }

    if(!NT_SUCCESS(status2)){
    }
 
    if(status4){
    }

    if(status5){
    }
    
    //Fails
    func4();
}
