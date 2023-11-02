// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#include "wdm.h"
#define SET_DISPATCH 1

// Template. Not called in this test.
void top_level_call() {}

/*************************************************/
void testFunctionCalled(
    IN PKDPC Dpc,
    IN PVOID DeferredContext,
    IN PVOID SystemArg1,
    IN PVOID SystemArg2)
{
}
KDEFERRED_ROUTINE testFunctionCalled;

void badTestFunctionCalled(
    IN PKDPC Dpc,
    IN PVOID DeferredContext,
    IN PVOID SystemArg1,
    IN PVOID SystemArg2)
{
}

void call()
{
    KeInitializeDpc(NULL,
                    testFunctionCalled,
                    NULL);
    KeInitializeDpc(NULL,
                    badTestFunctionCalled, 
                    NULL);
}
