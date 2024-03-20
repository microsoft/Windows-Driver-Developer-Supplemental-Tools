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