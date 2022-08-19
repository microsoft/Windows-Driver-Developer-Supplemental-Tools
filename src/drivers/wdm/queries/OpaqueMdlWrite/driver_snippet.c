// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

// Template. Not called in this test.
void top_level_call() {}

_Use_decl_annotations_
    NTSTATUS
    DispatchWrite(
        PDEVICE_OBJECT DeviceObject,
        PIRP Irp)
{
    UNREFERENCED_PARAMETER(DeviceObject);
    UNREFERENCED_PARAMETER(Irp);
    return STATUS_SUCCESS;
}

_Dispatch_type_(IRP_MJ_SET_INFORMATION)
    DRIVER_DISPATCH DispatchSetInformation;

_Use_decl_annotations_
    NTSTATUS
    DispatchSetInformation(
        PDEVICE_OBJECT DeviceObject,
        PIRP Irp)
{
    UNREFERENCED_PARAMETER(DeviceObject);
    UNREFERENCED_PARAMETER(Irp);
    return STATUS_SUCCESS;
}

// Passing case: no writing occurs.  Note that this would fail OpaqueMdlUse.
VOID OpaqueMdlWrite_Pass1(PMDL Mdl)
{
    PMDL currentMdl, nextMdl;

    for (currentMdl = Mdl; currentMdl != NULL; currentMdl = nextMdl)
    {
        nextMdl = currentMdl->Next;
        if (currentMdl->MdlFlags & MDL_PAGES_LOCKED && currentMdl->ByteCount > 0)
        {
            MmUnlockPages(currentMdl);
        }
        IoFreeMdl(currentMdl);
    }
}

// Passing case: only the Next field is written to.  Note that this would fail OpaqueMdlUse.
VOID OpaqueMdlWrite_Pass2(PMDL Mdl)
{
    PMDL currentMdl, nextMdl;

    for (currentMdl = Mdl; currentMdl != NULL; currentMdl = nextMdl)
    {
        nextMdl = currentMdl->Next;
        if (currentMdl->MdlFlags & MDL_PAGES_LOCKED && currentMdl->ByteCount > 0)
        {
            MmUnlockPages(currentMdl);
            currentMdl->Next = NULL;
        }
        IoFreeMdl(currentMdl);
    }
}

// Failing case: a field is written to that is not the Next field.
VOID OpaqueMdlWrite_Fail(PMDL Mdl)
{
    PMDL currentMdl, nextMdl;

    for (currentMdl = Mdl; currentMdl != NULL; currentMdl = nextMdl)
    {
        nextMdl = currentMdl->Next;
        if (currentMdl->MdlFlags & MDL_PAGES_LOCKED && currentMdl->ByteCount > 0)
        {
            currentMdl->ByteCount = 0;
            MmUnlockPages(currentMdl);
        }
        IoFreeMdl(currentMdl);
    }
}