// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

//Macros to enable or disable a code section that may or maynot conflict with this test.
#define SET_DISPATCH 1

//Template function. Not used for this test.
void top_level_call(){
}

//This header contains kernel mode programming interfaces
#include <ntddk.h>
//Contains versions of the functions found in strsafe.h that are suitable for use in kernel mode code.
#include <ntstrsafe.h> //Passes
#include <strsafe.h> //Fails
