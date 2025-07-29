// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}
int _fltused;

_Kernel_float_used_
void float_used_good()
{
    float f = 0.0f;
    f = f + 1.0f;
}

void float_used_good2()
{
    KFLOATING_SAVE saveData;
    NTSTATUS status;
    float f = 0.0f;
    status = KeSaveFloatingPointState(&saveData);
    for (int i = 0; i < 100; i++)
    {
        f = f + 1.0f;
    }
    KeRestoreFloatingPointState(&saveData);
}
void float_used_bad()
{
    float f = 0.0f;
    f = f + 1.0f;
}

