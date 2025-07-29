// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}

typedef __drv_functionClass(TEST_ROUTINE)
    VOID
    TEST_ROUTINE(
        VOID);

typedef TEST_ROUTINE *PTEST_ROUTINE;

typedef __drv_functionClass(TEST_ROUTINE2)
    VOID
    TEST_ROUTINE2(
        VOID);

typedef TEST_ROUTINE2 *PTEST_ROUTINE2;

TEST_ROUTINE func1;
TEST_ROUTINE func2;

__drv_functionClass(TEST_ROUTINE)
    VOID func1(
        VOID)
{
    ; // Don't need to do anything heres
}

__drv_functionClass(TEST_ROUTINE2)
    VOID func2(
        VOID)
{
    ; // Don't need to do anything heres
}