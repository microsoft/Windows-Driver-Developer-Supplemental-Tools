# Irp stack entry copy
Copying a whole IRP stack entry leaves certain fields initialized that should be cleared or updated


## Recommendation
The driver is copying an IRP improperly. Improperly copying an IRP can cause serious problems with a driver, including loss of data and system crashes. If an IRP must be copied and IoCopyCurrentIrpStackLocationToNext does not suffice, then certain members of the IRP should not be copied or should be zeroed after copying.


## Example

```c
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
void bad_irp_copy2(
    PIRP irp)
{
    PIO_STACK_LOCATION irpSp;
    PIO_STACK_LOCATION nextIrpSp;
    irpSp = IoGetCurrentIrpStackLocation(irp);
    nextIrpSp = IoGetNextIrpStackLocation(irp);
    RtlCopyMemory(nextIrpSp+4, irpSp+4, FIELD_OFFSET(IO_STACK_LOCATION, DeviceObject)-4);
    nextIrpSp->Control = 0;
}
void good_irp_copy(
    PIRP irp)
{
    IoCopyCurrentIrpStackLocationToNext(irp);
}

```

## References
* [ C28114 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28114-improper-irp-stack-copy)
