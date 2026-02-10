# Illegal write to a protected field (C28176)
The driver is writing to a read-only field of a driver struct.

Note that this check only reports violations when the field is explicitly read-only, and not completely inaccessible. For finding reads of inaccessible fields, use IllegalFieldAccess and IllegalFieldAccess2.


## Recommendation
Driver writers should not make changes to these fields except in specific contexts.


## Example
In this example, the driver directly edits a DriverObject's flags in a DriverUnload callback, which is not supported.

```c

			VOID
			DriverUnload (
				PDRIVER_OBJECT DriverObject
			)
			{
				DriverObject->Flags &= 0x100000;
				return;
			}
			
		
```
The driver should only adjust the Flags field in DriverEntry.


## References
* [ C28176 warning - Windows Drivers ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28176-struct-member-should-not-be-modified-by-driver)
