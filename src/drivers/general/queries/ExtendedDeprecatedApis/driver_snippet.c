// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1

// Template. Not called in this test.
void top_level_call() {}

// Passing case: uses approved replacements
VOID ExtendedDeprecatedApis_Pass()
{
    PSTR src = "Passing case!";
    char dst[100]; 
    strcpy_s(dst, sizeof(dst), src); 
}

// Failing case: includes calls to deprecated APIs
VOID ExtendedDeprecatedApis_Fail()
{
    PSTR src = "Failing case, even though we have enough space!";
    char dst[100]; 
    strcpy(dst, src); 
}