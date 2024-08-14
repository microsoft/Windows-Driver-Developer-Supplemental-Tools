// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

//Driver isolation violation if there is a Zw* registry function call with OBJECT_ATTRIBUTES parameter passed to it with
// *  RootDirectory!=NULL and the handle specified in RootDirectory comes from an unapproved ddi.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

#include <ntstrsafe.h>
#include <ntddscsi.h>

// Template function. Not used for this test.
void top_level_call()
{
}


// OBJECT_ATTRIBUTES->RootDirectory == NULL
// AND OBJECT_ATTRIBUTES->ObjectName doesn't start with "\registry\machine\hardware\"
void test_zw_not_allowed_read()
{

    NTSTATUS Status = STATUS_SUCCESS;
    HANDLE RootKey = NULL;
    HANDLE ChildKey = NULL;
    KEY_FULL_INFORMATION FullKeyInformation = {};
    OBJECT_ATTRIBUTES ObjectAttributes;
    PKEY_BASIC_INFORMATION pKeyInformation = NULL;
    ULONG Index = 0;
    ULONG InformationSize = 0;
    ULONG ReturnedSize = 0;
    UNICODE_STRING FrameRateKey;
    PUNICODE_STRING pwszSymbolicLink = NULL;

    RtlInitUnicodeString(&FrameRateKey, L"\\some\\bad\\path\\test\\test.txt");
    InitializeObjectAttributes(&ObjectAttributes, &FrameRateKey, OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE, 0, NULL);
    ZwOpenKey(&ChildKey, KEY_READ, &ObjectAttributes);
    // Open RGB data file for conversion to YUV space

    Status = ZwQueryKey(ChildKey, KeyFullInformation, &FullKeyInformation, sizeof(FullKeyInformation), &ReturnedSize);
}

void test_zw_allowed_read()
{

    NTSTATUS Status = STATUS_SUCCESS;
    HANDLE RootKey = NULL;
    HANDLE ChildKey = NULL;
    KEY_FULL_INFORMATION FullKeyInformation = {};
    OBJECT_ATTRIBUTES ObjectAttributes;
    PKEY_BASIC_INFORMATION pKeyInformation = NULL;
    ULONG Index = 0;
    ULONG InformationSize = 0;
    ULONG ReturnedSize = 0;
    UNICODE_STRING FrameRateKey;
    PUNICODE_STRING pwszSymbolicLink = NULL;

    RtlInitUnicodeString(&FrameRateKey, L"\\Registry\\Machine\\Hardware\\test\\test.txt");
    InitializeObjectAttributes(&ObjectAttributes, &FrameRateKey, OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE, 0, NULL);
    ZwOpenKey(&ChildKey, KEY_READ, &ObjectAttributes);
    // Open RGB data file for conversion to YUV space

    Status = ZwQueryKey(ChildKey, KeyFullInformation, &FullKeyInformation, sizeof(FullKeyInformation), &ReturnedSize);
}

void test_zw_multiple_nulls(PUNICODE_STRING RegistryPath)
{
    OBJECT_ATTRIBUTES objectAttributes = {0};
    HANDLE serviceKey = NULL;
    HANDLE parametersKey = NULL;
    RTL_QUERY_REGISTRY_TABLE parameters[3] = {0};

    UNICODE_STRING paramStr;
    //
    //  Default to ENABLING MediaChangeNotification (!)
    //

    ULONG mcnRegistryValue = 1;

    NTSTATUS status;

    //
    // open the service key.
    //

    InitializeObjectAttributes(&objectAttributes,
                               RegistryPath,
                               OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE,
                               NULL,
                               NULL);

    status = ZwOpenKey(&serviceKey,
                       KEY_READ,
                       &objectAttributes);

    //
    // Open the parameters key (if any) beneath the services key.
    //

    RtlInitUnicodeString(&paramStr, L"Parameters");

    InitializeObjectAttributes(&objectAttributes,
                               L"\\Registry\\Machine\\Hardware\\test\\test.txt",
                               OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE,
                               NULL,
                               NULL);

    status = ZwOpenKey(&parametersKey,
                       KEY_READ,
                       &objectAttributes);
}
