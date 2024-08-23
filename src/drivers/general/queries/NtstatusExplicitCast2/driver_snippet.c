// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}

BOOLEAN SomeFunction()
{
    return TRUE;
}
void test_good1()
{
    if (SomeFunction() == TRUE)
    {
        return 0;
    }
    else
    {
        return -1;
    }
}

void test_bad1()
{
    if (NT_SUCCESS(SomeFunction()))
    {
        return 0;
    }
    else
    {
        return -1;
    }
}
