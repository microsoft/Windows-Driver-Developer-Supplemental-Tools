// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1

// Template. Not called in this test.
void top_level_call() {}

// Passing case: uses approved replacements
VOID ExtendedDeprecatedApis_Pass()
{
    PSTR src = "Passing case!";
    char dst[100];
    strcpy_s(dst, sizeof(dst), src);
}

// Failing case: includes calls to deprecated APIs
VOID ExtendedDeprecatedApis_Fail()
{
    PSTR src = "Failing case, even though we have enough space!";
    char dst[100];
    strcpy(dst, src);
}

/*  Test code for AlertSuppression.ql.
    Because alert suppression queries don't directly output to SARIF,
    this code should be built as a database and then have both ExtendedDeprecatedApis and
    DriverAlertSuppression.ql run to test suppression. */
VOID AlertSuppressionTesting()
{
    PSTR src = "Testing suppression";
    char dst[100];

    strcpy(dst, src); // Intentionally unsuppressed

#pragma prefast(suppress : 28719) // Suppress a single rule
    strcpy(dst, src);

#pragma prefast(suppress : 28719, "Suppression with comment") // Suppress a rule with rationale provided
    strcpy(dst, src); 

#pragma prefast(suppress : __WARNING_BANNED_API_USAGE, "Suppression with name and comment") // Suppress a rule via legacy CA name
    strcpy(dst, src); 

#pragma prefast(suppress : cpp/windows/drivers/queries/extended-deprecated-apis) // Suppress a rule via CodeQL name
    strcpy(dst, src);
    
#pragma prefast(suppress : 28719) // Suppress a rule when there is whitespace between the pragma and the result

    strcpy(dst, src);

#pragma prefast(suppress : 28719) // Suppress a rule when there is an additional suppression between the suppress pragma and the violating code
#pragma prefast(suppress : 28720) 
    strcpy(dst, src);

#pragma prefast(suppress : 28720 28719) // Suppress multiple rules in a single command
    strcpy(dst, src);

#pragma prefast(disable : 28719) // Suppress a rule indefinitely until the stack is pushed
    strcpy(dst, src); 

#pragma prefast(push) // Push the pragma state onto the stack, nullifying the disable command
    strcpy(dst, src); // Intentionally unsuppressed

#pragma prefast(disable : 28719) // Apply a new disable command in this stack frame
    strcpy(dst, src);

#pragma prefast(pop) // Pop the pragma stack, re-applying the original disable pragma
    strcpy(dst, src); 
}