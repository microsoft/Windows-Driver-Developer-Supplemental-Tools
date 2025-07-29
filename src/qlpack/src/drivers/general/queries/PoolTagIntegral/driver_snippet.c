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

// Template. Not called in this test.
void top_level_call() {}

VOID PoolTagIntegral() {

    myTag3 = ExAllocatePool2(POOL_FLAG_NON_PAGED, sizeof(ULONG), 'gaT_');
    *myTag3 = '3gat';

    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, myTag); // GOOD
    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, myTag2); // GOOD
    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, *myTag3); // GOOD
    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, 'gaT_'); // GOOD
    
    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, myString); // ERROR
    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, &myTag); // ERROR
    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, myTag3); // ERROR
    ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, "gaT_"); // ERROR
}