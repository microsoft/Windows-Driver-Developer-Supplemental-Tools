// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1
// Template. Not called in this test.
void top_level_call() {}

void bad_irp_copy(
    PIRP irp)
{
    PIO_STACK_LOCATION irpSp;
    PIO_STACK_LOCATION nextIrpSp;
    irpSp = IoGetCurrentIrpStackLocation(irp);
    nextIrpSp = IoGetNextIrpStackLocation(irp);
    RtlCopyMemory(nextIrpSp, irpSp, 0x24);
    nextIrpSp->Control = 0;
}

void good_irp_copy(
    PIRP irp)
{
    IoCopyCurrentIrpStackLocationToNext(irp);
}
