// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}

void float_used_good0()
{
    float f = 0.0f;
    f = f + 1.0f;
}

_Kernel_float_saved_ void float_used_good1()
{
    KFLOATING_SAVE saveData;
    NTSTATUS status;
    float f = 0.0f;
    status = KeSaveFloatingPointState(&saveData);
    if (status != STATUS_SUCCESS)
    {
        return;
    }
    for (int i = 0; i < 100; i++)
    {
        f = f + 1.0f;
    }
    KeRestoreFloatingPointState(&saveData);
}

_Kernel_float_saved_ void float_used_good3()
{
    KFLOATING_SAVE saveData;
    float f = 0.0f;
    if (NT_SUCCESS(KeSaveFloatingPointState(&saveData)))
    {
        // Status not checked here
        for (int i = 0; i < 100; i++)
        {
            f = f + 1.0f;
        }
        KeRestoreFloatingPointState(&saveData);
    }
}



// Fail cases
_Kernel_float_saved_ void float_used_bad1()
{
    KFLOATING_SAVE saveData;
    NTSTATUS status;
    float f = 0.0f;
    status = KeSaveFloatingPointState(&saveData);
    // Status not checked here so the call to KeSaveFloatingPointState may fail 
    for (int i = 0; i < 100; i++)
    {
        f = f + 1.0f;
    }
    KeRestoreFloatingPointState(&saveData);
}
_Kernel_float_saved_ void float_used_bad2()
{
    float f = 0.0f;
    // Status not checked here
    for (int i = 0; i < 100; i++)
    {
        f = f + 1.0f;
    }
}
_Kernel_float_saved_ void float_used_bad3()
{
    float f = 0.0f;
    // Status not checked here
    int some_condition = 1;
    KFLOATING_SAVE saveData;
    NTSTATUS status;

    if (some_condition)
    {
        // This code path doesn't save the floating point state
        for (int i = 0; i < 100; i++)
        {
            f = f + 1;
        }
    }
    else
    {
        status = KeSaveFloatingPointState(&saveData);
        // Status not checked here 
        for (int i = 0; i < 100; i++)
        {
            f = f + 1.0f;
        }
    }
}
