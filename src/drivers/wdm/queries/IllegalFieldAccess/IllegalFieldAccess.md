# Incorrect access to protected field (C28128)
Assignments to private fields of DeviceObjects, DPCs, and IRPs should not be made directly.

The MSDN documentation for the Code Analysis version of this check is not consistent with the behavior of the check; it states that the check looks for incorrect assignments to an IRP's CancelRoutine field, while the check actually looks for incorrect assignments to DPCs or DPC fields. This verison of the check implements both these behaviors.


## Recommendation
Instead of making direct assignments, refer to MSDN and the output of running this query for the correct API to use.


## Example
In this example, the driver directly edits an IRP's CancelRoutine, which is not supported.

```c

			irp->CancelRoutine = myCancelRoutine;
			
		
```
The driver should instead call IoSetCancelRoutine:

```c

			oldCancel = IoSetCancelRoutine(irp, myCancelRoutine);
			
		
```

## References
* [ C28128 warning - Windows Drivers ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28128-structure-member-directly-accessed)
