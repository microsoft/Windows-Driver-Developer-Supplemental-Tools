# Potential use after free (high precision, for drivers)
This version of the query has high precision, which helps in bug automation, but there are some limitations and therefore it will not be able to detect some cases.

An allocated memory block is used after it has been freed (also known as dangling pointer).

Behavior in such cases is undefined and in practice can have many unintended consequences including memory corruption, use incorrect values, or arbitrary code execution.


## Recommendation
If possible set the pointers to NULL immediately after they are freed.


## Example
In the following example, `pSomePointer` is freed only if `Status` value was not zero, and before deferrencing `pSomePointer` to call `Method`, we check again `Status`; unfortunately `Status` was changed between the two references to `pSomePointer`, which allows for the possiblity that the call to `pSomePointer->Method()` is being performed over a previously freed pointer.


```c
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
```
In the corrected example, `pSomePointer` is set to `NULL` immediately after being freed, and the condition to check if it is safe to call `pSomePointer->Method()` checks for this additional condition to prevent the possible bug.


```c
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
```
