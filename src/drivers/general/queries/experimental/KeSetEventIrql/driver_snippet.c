// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1

// Template. Not called in this test.
void top_level_call() {}

_IRQL_always_function_max_(HIGH_LEVEL)
_IRQL_always_function_min_(5)
void KeSetEventIrql_Fail1(PRKEVENT Event);

_IRQL_always_function_min_(DISPATCH_LEVEL) 
void KeSetEventIrql_Fail2(PRKEVENT Event);

_IRQL_always_function_min_(PASSIVE_LEVEL) 
void KeSetEventIrql_Pass1(PRKEVENT Event);

_IRQL_always_function_min_(DISPATCH_LEVEL) 
void KeSetEventIrql_Pass2(PRKEVENT Event);

#pragma alloc_text(PAGE, KeSetEventIrql_Fail2)
#pragma alloc_text(PAGE, KeSetEventIrql_Pass2)

#include <wdm.h>

void KeSetEventIrql_Fail1(PRKEVENT Event)
{
    // This function is running at a high IRQL.  It should not call KeSetEvent.

    KeSetEvent(Event, HIGH_PRIORITY, FALSE); // Calling at too high of an IRQL
}

void KeSetEventIrql_Fail2(PRKEVENT Event)
{
    // This function runs at DISPATCH_LEVEL, which is too high to call KeSetEvent with the Wait argument.

    KeSetEvent(Event, HIGH_PRIORITY, TRUE); // Calling at too high of an IRQL
}

void KeSetEventIrql_Pass1(PRKEVENT Event)
{
    // This function runs at passive, so there's no problem.

    KeSetEvent(Event, HIGH_PRIORITY, TRUE);
}

void KeSetEventIrql_Pass2(PRKEVENT Event)
{
    // This function runs at DISPATCH_LEVEL but is calling with Wait set to FALSE, so there is no issue.

    KeSetEvent(Event, HIGH_PRIORITY, FALSE);
}

// TODO multi-threaded tests
// function has max IRQL requirement, creates two threads where one is above that requirement and one is below

