// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

NTSTATUS Status = x();

if (Status != 0)
{
    // Release pSomePointer if the call to x() failed

    ExFreePool(pSomePointer);

    // Setting pSomePointer to NULL after being freed
    pSomePointer = NULL;
}

Status = y();

// If pSomePointer was freed above, its value must have been set to NULL
if (Status == 0 && pSomePointer != NULL)
{
    Status = pSomePointer->Method();
}