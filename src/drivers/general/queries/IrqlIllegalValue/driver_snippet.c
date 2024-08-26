// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}

_IRQL_requires_(PASSIVE_LEVEL)
    VOID DoNothing_RequiresPassive(void)
{
    __noop;
}

// This function has an IRQL requirement that is too high.
_IRQL_requires_(42)
    VOID DoNothing_bad(void)
{
    __noop;
}
