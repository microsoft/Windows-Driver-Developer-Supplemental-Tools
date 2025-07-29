// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}
void test_zw_violation_1()
{
    // OBJECT_ATTRIBUTES->RootDirectory == NULL
    // AND OBJECT_ATTRIBUTES->ObjectName starts with "\registry\machine\hardware\"
    // AND function writes
}

// OBJECT_ATTRIBUTES->RootDirectory == NULL
// AND OBJECT_ATTRIBUTES->ObjectName doesn't start with "\registry\machine\hardware\"
void test_zw_not_allowed_read()
{

    NTSTATUS Status = STATUS_SUCCESS;
    HANDLE ChildKey = NULL;
    KEY_FULL_INFORMATION FullKeyInformation = {};
    OBJECT_ATTRIBUTES ObjectAttributes;
    ULONG ReturnedSize = 0;
    UNICODE_STRING FrameRateKey;

    RtlInitUnicodeString(&FrameRateKey, L"\\some\\bad\\path\\test\\test.txt");
    InitializeObjectAttributes(&ObjectAttributes, &FrameRateKey, OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE, 0, NULL);
    ZwOpenKey(&ChildKey, KEY_READ, &ObjectAttributes);
    Status = ZwQueryKey(ChildKey, KeyFullInformation, &FullKeyInformation, sizeof(FullKeyInformation), &ReturnedSize);
}

void test_zw_allowed_read()
{

    NTSTATUS Status = STATUS_SUCCESS;
    HANDLE ChildKey = NULL;
    KEY_FULL_INFORMATION FullKeyInformation = {};
    OBJECT_ATTRIBUTES ObjectAttributes;
    ULONG ReturnedSize = 0;
    UNICODE_STRING FrameRateKey;

    RtlInitUnicodeString(&FrameRateKey, L"\\Registry\\Machine\\Hardware\\test\\test.txt");
    InitializeObjectAttributes(&ObjectAttributes, &FrameRateKey, OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE, 0, NULL);
    ZwOpenKey(&ChildKey, KEY_READ, &ObjectAttributes);

    Status = ZwQueryKey(ChildKey, KeyFullInformation, &FullKeyInformation, sizeof(FullKeyInformation), &ReturnedSize);
}

void test_zw_multiple_nulls(PUNICODE_STRING RegistryPath)
{
    OBJECT_ATTRIBUTES objectAttributes = {0};
    HANDLE serviceKey = NULL;
    HANDLE parametersKey = NULL;
    RTL_QUERY_REGISTRY_TABLE parameters[3] = {0};

    UNICODE_STRING paramStr;

    NTSTATUS status;
    // open the service key.
    InitializeObjectAttributes(&objectAttributes,
                               RegistryPath,
                               OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE,
                               NULL,
                               NULL);

    status = ZwOpenKey(&serviceKey,
                       KEY_READ,
                       &objectAttributes);

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

// OBJECT_ATTRIBUTES->RootDirectory == NULL and OBJECT_ATTRIBUTES->ObjectName starts with "\registry\machine\hardware\ BUT Zw function does a write"
#include <ntstrsafe.h>
#include <ntddscsi.h>
void test_zw_violation_3(
    PCHAR DeviceName,
    ULONG DeviceNumber)
{
    NTSTATUS status;
    SCSI_ADDRESS scsiAddress = {0};
    OBJECT_ATTRIBUTES objectAttributes = {0};
    STRING string;
    UNICODE_STRING unicodeName = {0};
    UNICODE_STRING unicodeRegistryPath = {0};
    UNICODE_STRING unicodeData = {0};
    HANDLE targetKey;
    UCHAR buffer[256] = {0};

    PAGED_CODE();

    targetKey = NULL;
    status = RtlStringCchPrintfA((NTSTRSAFE_PSTR)buffer,
                                 sizeof(buffer) - 1,
                                 "\\Registry\\Machine\\Hardware\\DeviceMap\\Scsi\\Scsi Port %d\\Scsi Bus %d\\Target Id %d\\Logical Unit Id %d",
                                 scsiAddress.PortNumber,
                                 scsiAddress.PathId,
                                 scsiAddress.TargetId,
                                 scsiAddress.Lun);

    RtlInitString(&string, (PCSZ)buffer);

    status = RtlAnsiStringToUnicodeString(&unicodeRegistryPath,
                                          &string,
                                          TRUE);

    // Open the registry key

    InitializeObjectAttributes(&objectAttributes,
                               &unicodeRegistryPath,
                               OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE,
                               NULL,
                               NULL);

    status = ZwOpenKey(&targetKey,
                       KEY_READ,
                       &objectAttributes);

    RtlInitUnicodeString(&unicodeName, L"DeviceName");
    status = RtlStringCchPrintfA((NTSTRSAFE_PSTR)buffer, sizeof(buffer) - 1, "%s%d", DeviceName, DeviceNumber);
    RtlInitString(&string, (PCSZ)buffer);
    status = RtlAnsiStringToUnicodeString(&unicodeData,
                                          &string,
                                          TRUE);
    if (NT_SUCCESS(status))
    {
        status = ZwSetValueKey(targetKey,
                               &unicodeName,
                               0,
                               REG_SZ,
                               unicodeData.Buffer,
                               unicodeData.Length);
    }
}

void test_zw_allowed_rootdirectory_source()
{
    OBJECT_ATTRIBUTES ObjectAttributes;
    NTSTATUS Status;
    HANDLE ParentKey, RootKey;
    UNICODE_STRING UnicodeEnumName;
    const WCHAR EnumString[] = L"Enum";

    PAGED_CODE();

    PDEVICE_OBJECT PhysicalDeviceObject = NULL;

    Status = IoOpenDeviceRegistryKey(PhysicalDeviceObject,
                                     PLUGPLAY_REGKEY_DRIVER,
                                     STANDARD_RIGHTS_ALL,
                                     &ParentKey);

    RtlInitUnicodeString(&UnicodeEnumName, EnumString);

    InitializeObjectAttributes(&ObjectAttributes,
                               &UnicodeEnumName,
                               OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE,
                               ParentKey,
                               NULL);

    Status = ZwOpenKey(&RootKey, KEY_READ, &ObjectAttributes);

    if (!NT_SUCCESS(Status))
    {
        ZwClose(ParentKey);
        return Status;
    }
}

BOOLEAN
TestUsingFunctionParam(
    IN PUNICODE_STRING RegistryPath)
{
    OBJECT_ATTRIBUTES objectAttributes = {0};
    HANDLE serviceKey = NULL;
    HANDLE parametersKey = NULL;
    RTL_QUERY_REGISTRY_TABLE parameters[3] = {0};

    NTSTATUS status;

    PAGED_CODE();

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

    return NT_SUCCESS(status);
}

void BadCallTestUsingFunctionParam()
{
    UNICODE_STRING RegistryPath;
    const WCHAR EnumString[] = L"invalid";

    RtlInitUnicodeString(&RegistryPath, EnumString);

    TestUsingFunctionParam(&RegistryPath);
}

void GoodCallTestUsingFunctionParam()
{
    UNICODE_STRING RegistryPath;
    const WCHAR EnumString[] = L"\\Registry\\Machine\\Hardware\\DeviceMap\\Scsi\\Scsi Port %d\\Scsi Bus %d\\Target Id %d\\Logical Unit Id %d";

    RtlInitUnicodeString(&RegistryPath, EnumString);

    TestUsingFunctionParam(&RegistryPath);
}

void TestZwWithRelativeHandle()
{
    OBJECT_ATTRIBUTES ObjectAttributes;
    OBJECT_ATTRIBUTES ObjectAttributes2;
    OBJECT_ATTRIBUTES ObjectAttributes3;
    NTSTATUS Status;
    HANDLE ParentKey, RootKey, RootKey2, RootKey3;
    UNICODE_STRING UnicodeEnumName;
    const WCHAR EnumString[] = L"Enum";

    PAGED_CODE();

    PDEVICE_OBJECT PhysicalDeviceObject = NULL;

    Status = IoOpenDeviceRegistryKey(PhysicalDeviceObject,
                                     PLUGPLAY_REGKEY_DRIVER,
                                     STANDARD_RIGHTS_ALL,
                                     &ParentKey);

    RtlInitUnicodeString(&UnicodeEnumName, EnumString);

    InitializeObjectAttributes(&ObjectAttributes,
                               &UnicodeEnumName,
                               OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE,
                               ParentKey,
                               NULL);

    // Allowed because ParentKey came from IoOpenDeviceRegistryKey
    Status = ZwOpenKey(&RootKey, KEY_READ, &ObjectAttributes);

    if (!NT_SUCCESS(Status))
    {
        ZwClose(ParentKey);
        return Status;
    }

    InitializeObjectAttributes(&ObjectAttributes2,
                               &UnicodeEnumName,
                               OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE,
                               RootKey,
                               NULL);
    // Allowed because RootKey is a valid handle
    Status = ZwOpenKey(&RootKey2, KEY_READ, &ObjectAttributes2);


    InitializeObjectAttributes(&ObjectAttributes3,
                               &UnicodeEnumName,
                               OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE,
                               RootKey2,
                               NULL);
    // Allowed because RootKey is a valid handle
    Status = ZwOpenKey(&RootKey3, KEY_READ, &ObjectAttributes3);
}

void TestZwWithRelativeHandleBad()
{
    OBJECT_ATTRIBUTES ObjectAttributes;
    OBJECT_ATTRIBUTES ObjectAttributes2;
    NTSTATUS Status;
    HANDLE ParentKey = NULL;
    HANDLE RootKey, RootKey2;
    UNICODE_STRING UnicodeEnumName;
    const WCHAR EnumString[] = L"Enum";

    PAGED_CODE();

    PDEVICE_OBJECT PhysicalDeviceObject = NULL;

    InitializeObjectAttributes(&ObjectAttributes,
                               &UnicodeEnumName,
                               OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE,
                               ParentKey,
                               NULL);

    // Not allowed
    Status = ZwOpenKey(&RootKey, KEY_READ, &ObjectAttributes);

    if (!NT_SUCCESS(Status))
    {
        ZwClose(ParentKey);
        return Status;
    }

    InitializeObjectAttributes(&ObjectAttributes2,
                               &UnicodeEnumName,
                               OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE,
                               RootKey,
                               NULL);
    // Not allowed
    Status = ZwOpenKey(&RootKey2, KEY_READ, &ObjectAttributes2);
}