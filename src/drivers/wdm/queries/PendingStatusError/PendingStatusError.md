# Did not return STATUS_PENDING after IoMarkIrpPending call
A dispatch routine that calls IoMarkIrpPending must also return STATUS_PENDING


## Recommendation
A dispatch routine that calls IoMarkIrpPending includes at least one path in which the driver returns a value other than STATUS_PENDING. The IoMarkIrpPending routine marks the specified IRP, indicating that a driver's dispatch routine subsequently returned STATUS_PENDING because further processing is required by other driver routines.


## Example
In this example, the driver marks an IRP pending but returns STATUS_SUCCESS.

```c

			IoMarkIrpPending(Irp);
			...
			return STATUS_SUCCESS;
			
		
```
The driver should instead ensure that it returns STATUS_PENDING.

```c

			IoMarkIrpPending(Irp);
			...
			return STATUS_PENDING;
			
		
```

## References
* [ C28143 warning - Windows Drivers ](https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/28143-iomarkirppending-must-return-statuspending)
