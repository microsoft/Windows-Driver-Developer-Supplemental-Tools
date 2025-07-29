// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1
// Template. Not called in this test.
void top_level_call() {}
PDEVICE_OBJECT fdo = NULL;

void bad_operand_assignment()
{
    fdo->Flags = DO_BUFFERED_IO;
}
void good_operand_assignment()
{
    fdo->Flags |= DO_BUFFERED_IO;

}
