typedef unsigned char UCHAR, *PUCHAR;
typedef int SIZE_T;
typedef UCHAR BOOLEAN;           // winnt
#define FALSE   0
#define TRUE    1

#define NULL (0)
typedef unsigned long ULONG;
typedef long LONG;

typedef void * PVOID;

typedef long NTSTATUS;

typedef struct _IO_STATUS_BLOCK {
    union {
        NTSTATUS Status;
        PVOID Pointer;
    } DUMMYUNIONNAME;

    ULONG* Information;
} IO_STATUS_BLOCK, *PIO_STATUS_BLOCK;

typedef struct  _IRP {

    union {
        struct _IRP *MasterIrp;
        LONG IrpCount;
        PVOID SystemBuffer;
    } AssociatedIrp;

    //
    // I/O status - final status of operation.
    //

    IO_STATUS_BLOCK IoStatus;

    //
    // Note that the UserBuffer parameter is outside of the stack so that I/O
    // completion can copy data back into the user's address space without
    // having to know exactly which service was being invoked.  The length
    // of the copy is stored in the second half of the I/O status block. If
    // the UserBuffer field is NULL, then no copy is performed.
    //

    PVOID UserBuffer;
} IRP;

typedef IRP *PIRP;

typedef struct _IO_STACK_LOCATION {
  union {
        //
        // System service parameters for:  NtDeviceIoControlFile
        //
        // Note that the user's output buffer is stored in the UserBuffer field
        // and the user's input buffer is stored in the SystemBuffer field.
        //

        struct {
            ULONG OutputBufferLength;
            ULONG InputBufferLength;
            ULONG IoControlCode;
            PVOID Type3InputBuffer;
        } DeviceIoControl;

    } Parameters;

} IO_STACK_LOCATION, *PIO_STACK_LOCATION;

PIO_STACK_LOCATION
IoGetCurrentIrpStackLocation(
    PIRP Irp
);

#define EXCEPTION_EXECUTE_HANDLER 1

void Read(PVOID buf) { *((PIRP)buf); }

void ExRaiseAccessViolation();

void
TestIrp(
    PIRP    Irp
    )
{
    PIO_STACK_LOCATION IrpStack = IoGetCurrentIrpStackLocation(Irp);
    PVOID buf = IrpStack->Parameters.DeviceIoControl.Type3InputBuffer;
    Read(buf); // BAD
    *((PIRP)buf); // BAD

    buf = Irp->UserBuffer;
    Read(buf); // BAD
    *((PIRP)buf); // BAD
}

typedef struct _MYSTRUCT {
	ULONG Length;
	PUCHAR Data;
} MYSTRUCT, *PMYSTRUCT;

void
TestNestedDereference(
    PIRP    Irp
    )
{
    PIO_STACK_LOCATION IrpStack = IoGetCurrentIrpStackLocation(Irp);
    PVOID Buf = IrpStack->Parameters.DeviceIoControl.Type3InputBuffer;
    PMYSTRUCT MyStruct = NULL;
    PUCHAR Data = NULL;
    
    *Data; // BAD
}


void
TestSystemBufferNestedDereference(
    PIRP    Irp
    )
{
    PVOID Buf = Irp->AssociatedIrp.SystemBuffer;
	*Data; // BAD
}

__kernel_entry void TestSystemCall(int *buf)
{
    Read(buf); // BAD
    *((PIRP)buf); // BAD
}
