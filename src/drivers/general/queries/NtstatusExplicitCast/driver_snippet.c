// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}
int _fltused; 
void test_good1(){
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

void test_bad1()
{
    KFLOATING_SAVE saveData;
    NTSTATUS status;
    float f = 0.0f;
    status = KeSaveFloatingPointState(&saveData);
    if (!status)
    {
        status = KeRestoreFloatingPointState(&saveData);
        return;
    }
    for (int i = 0; i < 100; i++)
    {
        f = f + 1.0f;
    }
    status = KeRestoreFloatingPointState(&saveData);
    if (!((BOOLEAN)status))
    {
        ;
        // handle error
    }
}
