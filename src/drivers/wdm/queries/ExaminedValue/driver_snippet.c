// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macro to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

_Check_return_
NTSTATUS func1(){
    return STATUS_SUCCESS;
}


_Must_inspect_result_
NTSTATUS func2(){
    return STATUS_PENDING;
}

void top_level_call(){
    NTSTATUS status1, status2, status3;
    //Passes
    status1 = func1();
    //Fails
    status2 = func2();
    //Passes
    status2 = func2();
    //Fails
    status3 = func1();

    if(NT_SUCCESS(status1)){
    }

    if(!NT_SUCCESS(status2)){
    } 

    // We now artificially run func2 a bunch and check its result to get over the 
    // reporting threshold for the query.

    //Passes
    status2 = func2();
    if(!NT_SUCCESS(status2)){
    } 

    //Passes
    status2 = func2();
    if(!NT_SUCCESS(status2)){
    } 

    //Passes
    status2 = func2();
    if(!NT_SUCCESS(status2)){
    } 

    //Passes
    status2 = func2();
    if(!NT_SUCCESS(status2)){
    } 

    //Passes
    status2 = func2();
    if(!NT_SUCCESS(status2)){
    } 

    //Passes
    status2 = func2();
    if(!NT_SUCCESS(status2)){
    } 

    //Fails
    func2();

    //Passes
    if(NT_SUCCESS(func1())){
    }

}
