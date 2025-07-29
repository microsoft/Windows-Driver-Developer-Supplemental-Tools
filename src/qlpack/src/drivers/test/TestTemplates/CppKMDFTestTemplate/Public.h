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
    0xd36d883a,0x7580,0x4aec,0xaf,0xf6,0x2c,0xf3,0x7a,0xc9,0xfa,0x35);
// {d36d883a-7580-4aec-aff6-2cf37ac9fa35}
