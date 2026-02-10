# Bad overflow check
Checking for overflow of an addition by comparing against one of the arguments of the addition fails if the size of all the argument types are smaller than 4 bytes. This is because the result of the addition is promoted to a 4 byte int.


## Recommendation
Check the overflow by comparing the addition against a value that is at least 4 bytes.


## Example
In this example, the result of the comparison will result in an integer overflow.


```c
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

unsigned short CheckForInt16OverflowBadCode(unsigned short v, unsigned short b)
{
    if (v + b < v) // BUG: "v + b" will be promoted to 32 bits
    {
        // ... do something
    }

    return v + b;
}

```
To fix the bug, check the overflow by comparing the addition against a value that is at least 4 bytes.


```c
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

unsigned short CheckForInt16OverflowCorrectCode(unsigned short v, unsigned short b)
{
    if (v + b > 0x00FFFF)
    {
        // ... do something
    }

    return v + b;
}
```
