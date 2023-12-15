/*++

Module Name:

    public.h

Abstract:

    This module contains the common declarations shared by driver
    and user applications.

Environment:

    user and kernel

--*/

//
// Define an Interface Guid so that app can find the device and talk to it.
//

DEFINE_GUID (GUID_DEVINTERFACE_CppKMDFTestTemplate,
    0x0d5d117a,0x5f21,0x4cca,0xaf,0x97,0x5a,0x2f,0x71,0x10,0xae,0x85);
// {0d5d117a-5f21-4cca-af97-5a2f7110ae85}
