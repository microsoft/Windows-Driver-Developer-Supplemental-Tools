// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//
#include "ntstrsafe.h"

#define SET_DISPATCH 1
// Template. Not called in this test.
void top_level_call() {}

PUNICODE_STRING g_RP1;

NTSTATUS
DriverEntryBad(
    PDRIVER_OBJECT DriverObject,
    PUNICODE_STRING RegistryPath
    )
{
    g_RP1 = RegistryPath;
    return 0;
}


UNICODE_STRING g_RP2;

NTSTATUS
DriverEntryGood(
    PDRIVER_OBJECT DriverObject,
    PUNICODE_STRING RegistryPath
    )
{
    return RtlUnicodeStringCopy(&g_RP2,RegistryPath); 
}


UNICODE_STRING g_RP3;

NTSTATUS
DriverEntryGood2(
    PDRIVER_OBJECT DriverObject,
    PUNICODE_STRING RegistryPath
    )
{
    g_RP3 = *RegistryPath;
    return 0;
}

typedef struct _test_struct {
    int a;
    PUNICODE_STRING g_RP4;
    char b;
} test_struct;

test_struct g_test_struct;

NTSTATUS
DriverEntryBad2(
    PDRIVER_OBJECT DriverObject,
    PUNICODE_STRING RegistryPath
    )
{
    test_struct* localPtr = &g_test_struct;
    localPtr->g_RP4 = RegistryPath;
    return 0;
}