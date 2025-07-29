// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1
int _fltused;

// Template function. Not used for this test.
void top_level_call()
{
}

void float_used_good0()
{
    float f = 0.0f;
    f = f + 1.0f;
}

_Kernel_float_restored_ void float_used_good1()
{
    KFLOATING_SAVE saveData;
    NTSTATUS status;
    float f = 0.0f;
    status = KeSaveFloatingPointState(&saveData);
    if (status != STATUS_SUCCESS)
    {
        status = KeRestoreFloatingPointState(&saveData);
        return;
    }
    for (int i = 0; i < 100; i++)
    {
        f = f + 1.0f;
    }
    status = KeRestoreFloatingPointState(&saveData);
    if (!NT_SUCCESS(status))
    {
        ;
        // handle error
    }
}

// Fail cases
_Kernel_float_restored_ void float_used_bad1()
{
    KFLOATING_SAVE saveData;
    NTSTATUS status;
    float f = 0.0f;
    status = KeSaveFloatingPointState(&saveData);
    if (!NT_SUCCESS(status))
    {
        return;
    }
    for (int i = 0; i < 100; i++)
    {
        f = f + 1.0f;
    }
    // doesn't check the return value of KeRestoreFloatingPointState
    KeRestoreFloatingPointState(&saveData);
}
_Kernel_float_restored_ void float_used_bad2()
{
    float f = 0.0f;
    for (int i = 0; i < 100; i++)
    {
        f = f + 1.0f;
    }
    // No call to KeRestoreFloatingPointState
}
_Kernel_float_restored_ void float_used_bad3()
{
    float f = 0.0f;
    int some_condition = 1;
    KFLOATING_SAVE saveData;
    NTSTATUS status;

    if (some_condition)
    {
        status = KeSaveFloatingPointState(&saveData);
        if (!NT_SUCCESS(status))
        {
            return;
        }
        for (int i = 0; i < 100; i++)
        {
            f = f + 1;
        }
        // doesn't restore the floating point state
    }
    else
    {
        status = KeSaveFloatingPointState(&saveData);
        if (!NT_SUCCESS(status))
        {
            return;
        }
        for (int i = 0; i < 100; i++)
        {
            f = f + 1.0f;
        }

        // doesn't check the return value of KeRestoreFloatingPointState
        status = KeRestoreFloatingPointState(&saveData);
    }
}
