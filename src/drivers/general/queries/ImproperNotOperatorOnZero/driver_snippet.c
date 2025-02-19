// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}

NTSTATUS test_func()
{
    return !0;
}

HRESULT test_func2()
{
    return !0;
}

void test_test_func()
{
    if(test_func()){
        ;
    }else if(test_func2()){
        ;
    }
    else{
        ;
    }
}
// TODO add tests for query