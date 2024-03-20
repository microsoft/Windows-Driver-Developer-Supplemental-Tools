// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1
const extern ULONG myTag;
char * myString = "Hello!";
const ULONG myTag2 = '2gat';
ULONG * myTag3;

// Template. Not called in this test.
void top_level_call() {}

NTSTATUS
DriverEntryBad(
    _In_ PDRIVER_OBJECT  DriverObject,
    _In_ PUNICODE_STRING RegistryPath
    )
{
    return STATUS_SUCCESS;
}

DRIVER_INITIALIZE DriverEntryGood;
NTSTATUS
DriverEntryGood(
    _In_ PDRIVER_OBJECT  DriverObject,
    _In_ PUNICODE_STRING RegistryPath
    )
{
    return STATUS_SUCCESS;
}

