// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

NTSTATUS Status = x();

if (Status != 0)
{
    // Release pSomePointer if the call to x() failed

    ExFreePool(pSomePointer);
}

Status = y();

if (Status == 0)
{
    // Because Status may no longer be the same value than it was before the pointer was released,
    // this code may be using pSomePointer after it was freed, potentially executing arbitrary code.

    Status = pSomePointer->Method();
}