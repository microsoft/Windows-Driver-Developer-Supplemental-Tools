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

DEFINE_GUID (GUID_DEVINTERFACE_KMDFTestTemplate,
    0xd1b64617,0xe15b,0x41b0,0xaf,0x1c,0xd3,0xfd,0xd5,0x62,0x67,0xe6);
// {d1b64617-e15b-41b0-af1c-d3fdd56267e6}
