// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}
void test_bad()
{
    char a[8];
    char *p = a;
    char x = 0;
    char y = '0';
    
    p = '\0'; // should be *p = '\0';
}

void test_good()
{
    char a[8];
    char *p = a;
    *p = '\0'; // correct!
}
// TODO add tests for query