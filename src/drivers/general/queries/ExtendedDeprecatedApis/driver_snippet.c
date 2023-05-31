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

    strcpy(dst, src); // Unsuppressed

#pragma prefast(suppress : 28719)
    strcpy(dst, src);
#pragma prefast(suppress : 28719, "Suppression with comment")
    strcpy(dst, src);
#pragma prefast(suppress : __WARNING_BANNED_API_USAGE, "Suppression with name and comment")
    strcpy(dst, src);
#pragma prefast(suppress : cpp/windows/drivers/queries/extended-deprecated-apis)
    strcpy(dst, src);
#pragma prefast(suppress : 28719)
#pragma prefast(suppress : 28720)
    strcpy(dst, src);
#pragma prefast(suppress : 28720 28719)
    strcpy(dst, src); // BUG: Should be suppressed, isn't
#pragma prefast(disable : 28719)
    strcpy(dst, src); // BUG: Should be suppressed, isn't
#pragma prefast(push)
    strcpy(dst, src); // Unsuppressed

#pragma prefast(disable : 28719)
    strcpy(dst, src);
#pragma prefast(pop)
    strcpy(dst, src); // BUG: Should be suppressed, isn't
    
#pragma prefast(suppress : 28719)

    strcpy(dst, src);
}