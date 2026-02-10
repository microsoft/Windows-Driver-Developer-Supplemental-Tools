# Float Unsafe Exit
Exiting without acquiring the right to use floating hardware


## Recommendation
The _Kernel_float_saved_ annotation was used to acquire the right to use floating point, but a path through the function was detected where no function known to perform that operation was successfully called. This warning might indicate that a conditional (_When_) annotation is needed, or it might indicate a coding error.


## Example
Function has _Kernel_float_saved_ annotation but has a path where the floating point state is not saved. Additionally, KeSaveFloatingPointState return value is not checked so the call might fail

```c
 
		_Kernel_float_saved_ 
		void float_used_bad3()
		{
			float f = 0.0f;
			// Status not checked here
			int some_condition = 1;
			KFLOATING_SAVE saveData;
			NTSTATUS status;

			if (some_condition)
			{
				// This code path doesn't save the floating point state
				for (int i = 0; i < 100; i++)
				{
					f = f + 1;
				}
			}
			else
			{
				status = KeSaveFloatingPointState(&saveData);
				// Status not checked here 
				for (int i = 0; i < 100; i++)
				{
					f = f + 1.0f;
				}
			}
		}
		}
		
```
Good example

```c
 
		Kernel_float_saved_ 
		void float_used_good1()
		{
			KFLOATING_SAVE saveData;
			NTSTATUS status;
			float f = 0.0f;
			status = KeSaveFloatingPointState(&saveData);
			if (status != STATUS_SUCCESS)
			{
				return;
			}
			for (int i = 0; i < 100; i++)
			{
				f = f + 1.0f;
			}
			KeRestoreFloatingPointState(&saveData);
		}
		}
		
```

## Semmle-specific notes



## References
* [ Warning C28161 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28161-exiting-without-right-to-use-floating-hardware)
