// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}
#define ZeroMemory(a, b) memset(a, 0, b);

void bad_func()
{
    char Password[100];

    /*
     * The Buffer will be going out of scope
     * anyway so the compiler optimises away
     * the following
     */
    ZeroMemory(Password, sizeof(Password));
}
void bad_func2()
{
    char Password[100];

    /*
     * The Buffer will be going out of scope
     * anyway so the compiler optimises away
     * the following
     */
    RtlZeroMemory(Password, sizeof(Password));
}
void good_func()
{
    char Password[100];

    RtlSecureZeroMemory(Password, sizeof(Password));
}
char globalPassword[100];
void good_func2()
{
    char * Password;
    Password = globalPassword;
    // ... do something with Password
    RtlZeroMemory(Password, sizeof(globalPassword));
}
// TODO add tests for query