# Use of default pool tag in memory allocation (C28147)
Memory should not be allocated with the default tags of ' mdW' or ' kdD'.


## Recommendation
The driver is specifying a default pool tag. Because the system tracks pool use by pool tag, only those drivers that use a unique pool tag can identify and distinguish their pool use.


## Semmle-specific notes
This version of the query looks for bad tags passed through variables instead of just literals. Due to limitations in CodeQL data-flow analysis, the analysis will report a false negative if there is a global variable that is initialized with a default tag and there exists both a path where the variable is assigned a non-default tag, and a path where the variable is not assigned a non-default tag.


## Example

```c
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1
const extern ULONG myTag;
char * myString = "Hello!";
const ULONG myTag2 = '2gat';
ULONG * myTag3;

const ULONG defaultTag1 = ' mdW';
const ULONG defaultTag2 = ' kdD';
ULONG defaultTag3 = ' kdD';
ULONG changedTagGood = ' kdD';
ULONG changedTagBad = ' daB';

// Template. Not called in this test.
void top_level_call() {}

VOID PoolTagIntegral() {
    
    const ULONG defaultTagLocal = ' kdD';

    myTag3 = ExAllocatePool2(POOL_FLAG_NON_PAGED, sizeof(ULONG), 'gaT_');
    *myTag3 = '3gat';
    changedTagGood = 'dooG';
    changedTagBad = ' mdW';
    changedTagBad = 'fjio'; // Change to a good value...
    changedTagBad = ' kdD'; // And then back to bad, to test dataflow

    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, myTag); // GOOD
    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, myTag2); // GOOD
    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, *myTag3); // GOOD
    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, 'gaT_'); // GOOD
    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, changedTagGood); // GOOD
    
    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, defaultTag1); // ERROR
    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, defaultTag2); // ERROR   
    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, defaultTag3); // ERROR     
    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, ' mdW'); // ERROR
    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, ' kdD'); // ERROR
    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, changedTagBad); // ERROR
    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, defaultTagLocal); // ERROR
}
```

## References
* [ C28147 warning - Windows Drivers ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28147-improper-use-of-default-pool-tag)
