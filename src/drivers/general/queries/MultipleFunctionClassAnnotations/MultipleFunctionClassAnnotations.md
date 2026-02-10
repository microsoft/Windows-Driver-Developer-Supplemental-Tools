# Multiple Function Class Annotations
Function is annotated with more than one function class. All but one will be ignored.


## Recommendation
This warning can be generated when there is a chain of typedefs. Only use one function class annotation.


## Example
Example function with multiple __drv_functionClass annotations

```c
 
		__drv_functionClass(FAKE_DRIVER_ADD_DEVICE)
		__drv_functionClass(FAKE_DRIVER_ADD_DEVICE2)
		__drv_maxFunctionIRQL(PASSIVE_LEVEL)
		__drv_requiresIRQL(PASSIVE_LEVEL)
		__drv_sameIRQL
		__drv_when(return >= 0, __drv_clearDoInit(yes)) typedef NTSTATUS
		FAKE_DRIVER_ADD_DEVICE(
			__in struct _DRIVER_OBJECT *DriverObject,
			__in struct _DEVICE_OBJECT *PhysicalDeviceObject);

		typedef FAKE_DRIVER_ADD_DEVICE *PDRIVER_ADD_DEVICE;

		FAKE_DRIVER_ADD_DEVICE FakeDriverAddDevice;

		_Use_decl_annotations_
			NTSTATUS
			FakeDriverAddDevice(
				__in struct _DRIVER_OBJECT *DriverObject,
				__in struct _DEVICE_OBJECT *PhysicalDeviceObject)
		{
			return STATUS_SUCCESS;
		}
		
```

## References
* [ C28177 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28177-function-annotated-with-more-than-one-class)
