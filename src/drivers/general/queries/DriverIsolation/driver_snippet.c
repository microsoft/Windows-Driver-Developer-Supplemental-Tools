// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
    // PAGED_CODE();
    // NTSTATUS ntStatus = STATUS_SUCCESS;
    // IO_STATUS_BLOCK ioStatusBlock;

    // if (!m_FileHandle)
    // {
    //     ntStatus =
    //         ZwCreateFile(
    //             &m_FileHandle,
    //             GENERIC_READ,
    //             &m_objectAttributes,
    //             &ioStatusBlock,
    //             NULL,
    //             FILE_ATTRIBUTE_NORMAL,
    //             FILE_SHARE_READ,
    //             FILE_OPEN,
    //             FILE_SYNCHRONOUS_IO_NONALERT,
    //             NULL,
    //             0);
    // }

    // return ntStatus;
}
void test_rtl_violation_0()
{
    // RelativeTo != RTL_REGISTRY_DEVICEMAP
    HANDLE DriverKey = NULL;
    static WCHAR ValueName[] = L"KS", ValueValue[] = L"1";

    // Status = IoOpenDeviceRegistryKey(PhysicalDevice,
    //                                  PLUGPLAY_REGKEY_DRIVER,
    //                                  KEY_WRITE,
    //                                  &DriverKey);
    RtlWriteRegistryValue(RTL_REGISTRY_HANDLE,
                          (PCWSTR)DriverKey,
                          ValueName,
                          REG_SZ,
                          ValueValue,
                          sizeof ValueValue);
    ZwClose(DriverKey);
}

void test_rtl_violation_1()
{
    // RelativeTo == RTL_REGISTRY_DEVICEMAP AND function writes
}

void test_zw_violation_1()
{
    // OBJECT_ATTRIBUTES->RootDirectory == NULL
    // AND OBJECT_ATTRIBUTES->ObjectName starts with "\registry\machine\hardware\"
    // AND function writes
}


// OBJECT_ATTRIBUTES->RootDirectory == NULL and OBJECT_ATTRIBUTES->ObjectName starts with "\registry\machine\hardware\ BUT Zw function does a write"
#include <ntstrsafe.h>
#include <ntddscsi.h>
void test_zw_violation_3(_In_ PDEVICE_OBJECT Fdo,
                         _In_ PCHAR DeviceName,
                         _In_ ULONG DeviceNumber,
                         _In_ ULONG InquiryDataLength)
{
    NTSTATUS status;
    SCSI_ADDRESS scsiAddress = {0};
    OBJECT_ATTRIBUTES objectAttributes = {0};
    STRING string;
    UNICODE_STRING unicodeName = {0};
    UNICODE_STRING unicodeRegistryPath = {0};
    UNICODE_STRING unicodeData = {0};
    HANDLE targetKey;
    IO_STATUS_BLOCK ioStatus;
    UCHAR buffer[256] = {0};

    PAGED_CODE();

    targetKey = NULL;

    // Issue GET_ADDRESS Ioctl to determine path, target, and lun information.
    //

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

    //
    // Open the registry key for the scsi information for this
    // scsibus, target, lun.
    //

    InitializeObjectAttributes(&objectAttributes,
                               &unicodeRegistryPath,
                               OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE,
                               NULL,
                               NULL);

    status = ZwOpenKey(&targetKey,
                       KEY_READ | KEY_WRITE,
                       &objectAttributes);

    //
    // Now construct and attempt to create the registry value
    // specifying the device name in the appropriate place in the
    // device map.
    //

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

    
} // end ClassUpdateInformationInRegistry()

void test_zw_allowed_rootdirectory_source()
{
    OBJECT_ATTRIBUTES ObjectAttributes;
    NTSTATUS Status;
    HANDLE ParentKey, RootKey, ChildKey;
    UNICODE_STRING UnicodeEnumName;
    const WCHAR EnumString[] = L"Enum";

    PAGED_CODE();

    PDEVICE_OBJECT PhysicalDeviceObject = NULL;

    Status = IoOpenDeviceRegistryKey(PhysicalDeviceObject,
                                     PLUGPLAY_REGKEY_DRIVER,
                                     STANDARD_RIGHTS_ALL,
                                     &ParentKey);

    //
    // create the subkey for the enum section, in the form "\enum"
    //
    RtlInitUnicodeString(&UnicodeEnumName, EnumString);

    //
    // read the registry to determine if children are present.
    //
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

// OBJECT_ATTRIBUTES->RootDirectory != NULL AND didn't get RootDirectory from OK source
void test_zw_not_allowed_rootdirectory_source()
{
    OBJECT_ATTRIBUTES ObjectAttributes;
    NTSTATUS Status;
    HANDLE ParentKey, RootKey, ChildKey;
    UNICODE_STRING UnicodeEnumName;
    const WCHAR EnumString[] = L"Enum";

    PAGED_CODE();
    Status = ZwOpenKey(&ParentKey, KEY_ALL_ACCESS, &ObjectAttributes);
    PDEVICE_OBJECT PhysicalDeviceObject = NULL;

    RtlInitUnicodeString(&UnicodeEnumName, EnumString);

    InitializeObjectAttributes(&ObjectAttributes,
                               &UnicodeEnumName,
                               OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE,
                               ParentKey,
                               NULL);

    // Violation because ObjectAttributes->RootDirectory is not from an OK source
    Status = ZwOpenKey(&RootKey, KEY_READ, &ObjectAttributes);

    if (!NT_SUCCESS(Status))
    {
        ZwClose(ParentKey);
        return Status;
    }
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
/*
void test_with_multiple_version()
{
    typedef NTSTATUS NTAPI QUERYFN(
        ULONG, PCWSTR, PRTL_QUERY_REGISTRY_TABLE, PVOID, PVOID);

    UNICODE_STRING FunctionName;
    QUERYFN *QueryRoutine;

    RtlInitUnicodeString(&FunctionName, L"RtlQueryRegistryValuesEx");

    QueryRoutine = (QUERYFN *)MmGetSystemRoutineAddress(&FunctionName);

    if (QueryRoutine == NULL)
    {
        QueryRoutine = &RtlQueryRegistryValues;
    }

    return QueryRoutine(RelativeTo,
                        Path,
                        QueryTable,
                        Context,
                        Environment);
}
*/
