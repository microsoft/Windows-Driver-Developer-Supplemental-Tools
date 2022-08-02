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