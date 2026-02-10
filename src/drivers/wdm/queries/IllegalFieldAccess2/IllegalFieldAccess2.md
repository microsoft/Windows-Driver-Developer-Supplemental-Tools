# Illegal access to a protected field (C28175)
Drivers should not read inaccessible fields of driver structs.


## Recommendation
Driver developers should avoid reading these fields in their drivers.


## Example
In this example, the driver directly reads a DeviceObject's "Size" field.

```c

			NTSTATUS CompletionRoutine(
						PDEVICE_OBJECT DeviceObject,
						PIRP Irp,
						PVOID Context
			)
			{
				if (DeviceObject->Size > 0x10)
				{
					// Do some logic
				}
				return;
			}
			
		
```
The driver should not access this field.


## References
* [ C28175 warning - Windows Drivers ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28175struct-member-should-not-be-accessed-by-driver)

## Semmle-specific notes
It is legal for filesystem drivers to access some fields that should not be accessed by other drivers; this case is not accounted for in the rule at this time.

