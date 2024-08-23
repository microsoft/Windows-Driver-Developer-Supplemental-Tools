// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}

void bad(){
    char* b = 0;
    memset(b, 0, sizeof(b));
}

void good(){
    char* b = 0;
    memset(b, 0, sizeof(*b));
}
// TODO add tests for query