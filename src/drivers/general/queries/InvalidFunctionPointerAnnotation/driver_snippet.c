// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1
// Template function. Not used for this test.
void top_level_call()
{
}

IO_WORKITEM_ROUTINE workerFunc4;

_Use_decl_annotations_
    VOID
    workerFunc4(
        _In_ PDEVICE_OBJECT DeviceObject,
        _In_opt_ PVOID Context)
{
    ; // Don't actually need to do anything here.
}

IO_TIMER_ROUTINE workerFunc5;

_Use_decl_annotations_
    VOID
    workerFunc5(
        _In_ PDEVICE_OBJECT DeviceObject,
        _In_opt_ PVOID Context)
{
    ; // Don't actually need to do anything here.
}

__drv_functionClass(IO_WORKITEM_ROUTINE)
    __drv_requiresIRQL(PASSIVE_LEVEL)
        __drv_sameIRQL
    VOID
    workerFunc1(
        _In_ PDEVICE_OBJECT DeviceObject,
        _In_opt_ PVOID Context)
{
    ; // Don't actually need to do anything here.
}

__drv_functionClass(IO_TIMER_ROUTINE)
    __drv_requiresIRQL(PASSIVE_LEVEL)
        __drv_sameIRQL
    VOID
    workerFunc2(
        _In_ PDEVICE_OBJECT DeviceObject,
        _In_opt_ PVOID Context)
{
    ; // Don't actually need to do anything here.
}

void test_good()
{
    __drv_aliasesMem PIO_WORKITEM IoWorkItem = NULL;
    __drv_aliasesMem PVOID Context = NULL;
    IoQueueWorkItem(IoWorkItem, workerFunc1, DelayedWorkQueue, Context);
    IoQueueWorkItem(IoWorkItem, workerFunc4, DelayedWorkQueue, Context);
}

void test_bad()
{
    __drv_aliasesMem PIO_WORKITEM IoWorkItem = NULL;
    __drv_aliasesMem PVOID Context = NULL;
    IoQueueWorkItem(IoWorkItem, workerFunc2, DelayedWorkQueue, Context);
    IoQueueWorkItem(IoWorkItem, workerFunc5, DelayedWorkQueue, Context);
}
