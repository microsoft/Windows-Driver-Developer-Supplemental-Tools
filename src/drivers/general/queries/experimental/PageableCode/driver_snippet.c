// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1

// Template. Not called in this test.
void top_level_call() {}

#include <wdm.h>

typedef struct _DAM_THROTTLE_WORKER_EVENTS {

    //
    // Events for stopping throttling.
    //

    KEVENT Stop;
    KEVENT StopComplete;

    //
    // Timer for scheduling and running throttling work.
    //

    PEX_TIMER Timer;
} DAM_THROTTLE_WORKER_EVENTS, *PDAM_THROTTLE_WORKER_EVENTS;

typedef struct _DAM_THROTTLE_WORKER_CONTEXT {

    //
    // The setting, delegates, and timer context required for interacting with
    // the DAM Throttling Library.
    //

  //  DAM_THROTTLE_CONTEXT ThrottleContext;

    //
    // The events used in this file for timers and stopping throttling.
    //

    DAM_THROTTLE_WORKER_EVENTS Events;

    //
    // The structures used in kernel timer calls.
    //

  //  DAM_THROTTLE_WORKER_EXT_PARAMETRS ExtParameters;

    union {
        BOOLEAN AllFlags;

        struct {

            //
            // ThrottleRunning is set by the thread which starts throttling
            // and is then used, set, and unset on the worker thread.
            //

            BOOLEAN ThrottleRunning : 1;

            //
            // GroupsFrozen must be set by the thread which starts the throttle
            // prior to starting the throttle. While the throttle is running,
            // the worker thread uses GroupsFrozen. After calling ThrottleStop,
            // which synchronizes with the StopComplete event, the thread which
            // stopped the throttle must use GroupsFrozen to set the correct
            // frozen or thawed state for the throttled groups.
            //

            BOOLEAN GroupsFrozen : 1;
            BOOLEAN Reserved : 6;
        };
    };

} DAM_THROTTLE_WORKER_CONTEXT, *PDAM_THROTTLE_WORKER_CONTEXT;


VOID
DamThrottleWorkerThrottleStop (
    _Inout_ DAM_THROTTLE_WORKER_CONTEXT* Context
    );

#define ALLOC_PRAGMA
#ifdef ALLOC_PRAGMA
    #pragma alloc_text (PAGE, DamThrottleWorkerThrottleStop)
#endif


VOID
DamThrottleWorkerThrottleStop (
    _Inout_ DAM_THROTTLE_WORKER_CONTEXT* Context
    )

/*++

Routine Description:
/onecore/base/background/dam/sys/damthrottle.c
    Signals the throttling library to stop and waits for the stop signal from
    the worker thread. The exemption groups may be in either the frozen or
    thawed state on stop. It is safe to call this function if the throttle
    isn't running.

    N.B. When the throttle stops, the exemption groups may be either frozen
    or thawed and it is left to the caller to check the current state using
    the GroupsFrozen flag and then enact the desired state.

    This is done because there are multiple scenarios where Stop is called
    and those scenarios want the exemption groups to be in different states
    after stopping throttling and these code paths are performance critical.

Arguments:

    Context - The DAM Throttle Worker Context.

Return Value:

    None.

--*/

{
    DAM_THROTTLE_WORKER_EVENTS* Events;
    NTSTATUS Status;

    PAGED_CODE();

    Events = &Context->Events;

    //DampTraceThrottleStart("DamThrottleWorkerStopThrottle");

    KeSetEvent(&Events->Stop, LOW_REALTIME_PRIORITY, TRUE);

    Status = KeWaitForSingleObject(&Events->StopComplete,
                                   Executive,
                                   KernelMode,
                                   FALSE,
                                   NULL);

    //
    // As this is an unlimited wait, the only expected result is success. If
    // the throttle fails to stop, we'd expect a PDC Watchdog to fire.
    //

    NT_ASSERT(Status == STATUS_SUCCESS);

   // DampTraceThrottleStop("DamThrottleWorkerStopThrottle",
   //                       TraceLoggingNTStatus(Status));

    return;
}


// TODO multi-threaded tests
// function has max IRQL requirement, creates two threads where one is above that requirement and one is below
