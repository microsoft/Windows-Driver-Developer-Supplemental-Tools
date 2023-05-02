// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1

// Template. Not called in this test.
void top_level_call() {}

// Passing case: uses approved replacements
VOID WdkDeprecatedApi_Pass()
{
    ExAllocatePool2(POOL_FLAG_NON_PAGED, sizeof(int), 'ssaP');
}

// Failing case: includes calls to deprecated APIs
VOID WdkDeprecatedApi_Fail()
{
    ExAllocatePool(POOL_FLAG_NON_PAGED, sizeof(int));
}

// Failing case: call a macro invocation of an obsolete API
VOID WdkDeprecatedApi_Fail2()
{
#ifndef ExAllocatePoolWithTag(a, b, c)
#define ExAllocatePoolWithTag(a, b, c) ExAllocatePool(a, b)
#endif
    ExAllocatePoolWithTag(POOL_FLAG_NON_PAGED, sizeof(int), '_gaT');
}