// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

void InfiniteLoop(int a)
{
    for (short i = 0; i < a; i++) // BUG: infinite loop
    {
        // ...
    }
}
