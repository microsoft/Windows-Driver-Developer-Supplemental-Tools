# Incorrect Role Type Use
Driver callback functions should be declared with the appropriate function role type.


## Recommendation
Make sure the role type of the function being used matches the expected role type.


## Example
In this example, the driver does not correctly annotate FdoDevPrepareHardware before setting it as the EvtDevicePrepareHardware callback function.

```c
 
		NTSTATUS FdoDevPrepareHardware;

		VOID DriverSetDeviceCallbackEvents(
		_In_  PWDFDEVICE_INIT  _DeviceInit
		)
	// Initialize device callback events    
	{
		WDF_POWER_POLICY_EVENT_CALLBACKS PowerPolicyCallbacks;
		WDF_PNPPOWER_EVENT_CALLBACKS PnpPowerCallbacks;    

		PAGED_CODE();  

		DoTrace(LEVEL_INFO, TFLAG_PNP,("+DriverSetDeviceCallbackEvents"));    
		
		//
		// Set event callbacks
		//   1. Pnp & Power events
		//   2. Power Policy events
		//

		WDF_PNPPOWER_EVENT_CALLBACKS_INIT(&PnpPowerCallbacks);
		
		//
		// Register PnP callback
		//
		PnpPowerCallbacks.EvtDevicePrepareHardware = FdoDevPrepareHardware;

	}
		
```
The driver annotate the FdoDevPrepareHardware function with the appropriate role type.

```c
 
		EVT_WDF_DEVICE_PREPARE_HARDWARE FdoDevPrepareHardware;

		VOID DriverSetDeviceCallbackEvents(
		_In_  PWDFDEVICE_INIT  _DeviceInit
		)
	// Initialize device callback events    
	{
		WDF_POWER_POLICY_EVENT_CALLBACKS PowerPolicyCallbacks;
		WDF_PNPPOWER_EVENT_CALLBACKS PnpPowerCallbacks;    

		PAGED_CODE();  

		DoTrace(LEVEL_INFO, TFLAG_PNP,("+DriverSetDeviceCallbackEvents"));    
		
		//
		// Set event callbacks
		//   1. Pnp & Power events
		//   2. Power Policy events
		//

		WDF_PNPPOWER_EVENT_CALLBACKS_INIT(&PnpPowerCallbacks);
		
		//
		// Register PnP callback
		//
		PnpPowerCallbacks.EvtDevicePrepareHardware = FdoDevPrepareHardware;

	}
		
```

## Semmle-specific notes
C++ functions not currently supported. See https://github.com/github/codeql/issues/14869


## References
* [ C28158 warning - Windows Drivers ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/declaring-functions-using-function-role-types-for-wdm-drivers)
