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