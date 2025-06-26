// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}
BOOLEAN SomeMemAllocFunction(void *p)
{
    if (p == NULL)
    {
        return FALSE;
    }
    return TRUE;
}

NTSTATUS test_good()
{
    void *MyPtr;
    if (SomeMemAllocFunction(&MyPtr) == TRUE)
    {
        return STATUS_SUCCESS;
    }
    else
    {
        return STATUS_NO_MEMORY;
    }
}

NTSTATUS test_bad()
{
    void *MyPtr;
    return SomeMemAllocFunction(&MyPtr);
}
// TODO add tests for query