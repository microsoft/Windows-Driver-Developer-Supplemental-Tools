# Incorrect dispatch table assignment
The dispatch table assignment satisfies any of these 3 scenarios: 1) The dispatch table assignment has a function whose type is not DRIVER_DISPATCH, or 2) The dispatch table assignment has a DRIVER_DISPATCH function at its right-hand side but the function doesn't have a driver dispatch type annotation, or 3) The dispatch function satisfies both of the above conditions but its dispatch type doesn't match the expected type for the dispatch table entry.


## Recommendation
This defect can be corrected either using a DRIVER_DISPATCH type function or by adding a _Dispatch_type_ annotation to the function or correcting the dispatch table entry being used.


## Example
In this example, the driver has a DRIVER_DISPATCH routine that is not annotated with the type(s) of IRP it handles.

```c

			DRIVER_DISPATCH SampleCreate;
			...
			pDo->MajorFunction[IRP_MJ_CREATE] = SampleCreate;
			
		
```
The driver should instead annotate its dispatch routines appropriately.

```c

			_Dispatch_type_(IRP_MJ_CREATE) DRIVER_DISPATCH SampleCreate;
			...
			pDo->MajorFunction[IRP_MJ_CREATE] = SampleCreate;...
			
		
```

## References
* [ C28168 warning - Windows Drivers ](https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/28168-dispatch-function-dispatch-annotation)
* [ C28169 warning - Windows Drivers ](https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/28169-dispatch-function-does-not-have-proper-annotation)
