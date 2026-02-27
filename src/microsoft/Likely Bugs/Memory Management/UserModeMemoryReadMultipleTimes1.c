typedef unsigned char UCHAR;
typedef int SIZE_T;
typedef short SHORT;
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

typedef struct _MDL {
  SHORT Size;
} MDL, *PMDL;

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

    PMDL MdlAddress;
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

void Read(PVOID buf) { *((PIRP)buf); }

typedef struct _MyStruct {
  PVOID Field;
} MyStruct, *PMyStruct;

void DoDoubleFetch(PVOID buf)
{
    Read(buf);
    *((PIRP)buf);
}

void TestIrp(PIRP Irp)
{
    // IRP: Type3InputBuffer double fetch
    PIO_STACK_LOCATION IrpStack = IoGetCurrentIrpStackLocation(Irp);
    PVOID buf = IrpStack->Parameters.DeviceIoControl.Type3InputBuffer;
    DoDoubleFetch(buf);

    // IRP: UserBuffer double fetch
    buf = Irp->UserBuffer;
    DoDoubleFetch(buf);

    // IRP: Access to user buffer via IO manager copied SystemBuffer
    PMyStruct s = (PMyStruct)Irp->AssociatedIrp.SystemBuffer;
    DoDoubleFetch(s->Field);

    // MDL: MmGetSystemAddressForMdlSafe
    SIZE_T *input = (SIZE_T*) MmGetSystemAddressForMdlSafe(Irp->MdlAddress);
    DoDoubleFetch(input);
    
    // IRP: Access to SystemBuffer, no warning expected
    SIZE_T *sb = (SIZE_T*) Irp->AssociatedIrp.SystemBuffer;
    DoDoubleFetch(sb);
}