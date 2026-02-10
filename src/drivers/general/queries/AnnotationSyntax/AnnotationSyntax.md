# Annotation syntax error
A syntax error in the annotations was found for the property in the function.


## Recommendation
This warning indicates an error in the annotations, not in the code that is being analyzed.


## Example
_IRQL_saves_global_ not applied to entire function

```c
 
		// FAIL 
		VOID test1(
			_IRQL_saves_global_(OldIrql, *Irql) PKIRQL Irql)
		{
			// ...
			;
		}
		
```
_Kernel_clear_do_init_ not used with either "yes" or "no"

```c
 
		// FAIL
		_Function_class_(DRIVER_ADD_DEVICE)
			_IRQL_requires_(PASSIVE_LEVEL)
				_IRQL_requires_same_
			_Kernel_clear_do_init_(IRP_MJ_CREATE)
		NTSTATUS
		test4(
			_In_ PDRIVER_OBJECT DriverObject,
			_In_ PDEVICE_OBJECT PhysicalDeviceObject)

		{
			; // do nothing
		}
		
```

## References
* [ C28266 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28266-function-property-syntax-error)
