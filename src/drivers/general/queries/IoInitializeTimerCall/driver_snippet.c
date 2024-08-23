// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//
#define SET_DISPATCH 1

// Template. Not called in this test.
void top_level_call() {}

VOID functionThatsNotAddDevice()
{
    PDEVICE_OBJECT DeviceObject = NULL;
    PIO_TIMER_ROUTINE TimerRoutine= NULL;
    PVOID Context= NULL;
    IoInitializeTimer(
        DeviceObject,
        TimerRoutine,
        Context);
}

