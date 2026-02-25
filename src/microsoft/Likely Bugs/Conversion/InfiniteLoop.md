# Comparison of narrow type with wide type in loop condition
Comparisons between types of different widths in a loop condition can cause the loop to fail to terminate.


## Recommendation
Use appropriate types in the loop condition.


## Example
In this example, the result of the comparison may result in an infinite loop if the value for argument `a` is larger than `SHRT_MAX`.


```c
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

void InfiniteLoop(int a)
{
    for (short i = 0; i < a; i++) // BUG: infinite loop
    {
        // ...
    }
}

```
To fix the bug, we are changing the type for the variable `i` to match the width of `a`.


```c
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

void NotInfiniteLoop(int a)
{
    for (int i = 0; i < a; i++) 
    {
        // ...
    }
}
```
