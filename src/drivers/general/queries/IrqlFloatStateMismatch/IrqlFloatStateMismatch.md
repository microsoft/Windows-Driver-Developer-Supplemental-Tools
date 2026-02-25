# Irql Float State Mismatch
The IRQL where the floating-point state was saved does not match the current IRQL (for this restore operation).


## Recommendation
The IRQL at which the driver is executing when it restores a floating-point state is different than the IRQL at which it was executing when it saved the floating-point state. Because the IRQL at which the driver runs determines how the floating-point state is saved, the driver must be executing at the same IRQL when it calls the functions to save and to restore the floating-point state.


## Example
Example of incorrect code. Floating point state was saved at APC_LEVEL but restored at PASSIVE_LEVEL

```c
 
		_IRQL_requires_(PASSIVE_LEVEL) 
		void driver_utility_bad(void)
		{
			KIRQL oldIRQL;
			KeRaiseIrql(APC_LEVEL, &oldIRQL);
			// running at APC level
			KFLOATING_SAVE FloatBuf;
			if (KeSaveFloatingPointState(&FloatBuf))
			{
				KeLowerIrql(oldIRQL); // lower back to PASSIVE_LEVEL
				// ...
				KeRestoreFloatingPointState(&FloatBuf);
			}
		}
		
```
Correct example

```c
 
			_IRQL_requires_(PASSIVE_LEVEL) 
			void driver_utility_good(void)
			{
				// running at APC level
				KFLOATING_SAVE FloatBuf;
				KIRQL oldIRQL;
				KeRaiseIrql(APC_LEVEL, &oldIRQL);

				if (KeSaveFloatingPointState(&FloatBuf))
				{
					KeLowerIrql(oldIRQL);
					// ...
					KeRaiseIrql(APC_LEVEL, &oldIRQL);
					KeRestoreFloatingPointState(&FloatBuf);
				}
			}
		
```

## References
* [ C28111 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28111-floating-point-irql-mismatch)
