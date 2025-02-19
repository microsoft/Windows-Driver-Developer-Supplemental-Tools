// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}
KEVENT EventDone;

void test_func(
    MODE WaitMode)
{
    UNREFERENCED_PARAMETER(WaitMode);
};

void bad_call()
{
    KeWaitForSingleObject(
        &EventDone,
        Executive,
        Executive,
        FALSE,
        NULL);

    test_func(Executive);
}

void good_call()
{
    KeWaitForSingleObject(
        &EventDone,
        Executive,
        KernelMode,
        FALSE,
        NULL);
    
    test_func(KernelMode);

}