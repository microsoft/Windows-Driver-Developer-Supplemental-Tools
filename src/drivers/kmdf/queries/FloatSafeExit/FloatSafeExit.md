# Float Safe Exit
Exiting while holding the right to use floating-point hardware


## Recommendation
The _Kernel_float_restored_ annotation was used to release the right to use floating point, but a path through the function was detected where no function known to perform that operation was successfully called. This warning might indicate that a conditional (_When_) annotation is needed, or it might indicate a coding error.


## Example
Example of function with multiple issues

```c
 
	
		void func(){
			
			float f = 0.0f;
			int some_condition = 1;
			KFLOATING_SAVE saveData;
			NTSTATUS status;

			if (some_condition)
			{
				status = KeSaveFloatingPointState(&saveData);
				if (!NT_SUCCESS(status))
				{
					return;
				}
				for (int i = 0; i < 100; i++)
				{
					f = f + 1;
				}
				// doesn't restore the floating point state
			}
			else
			{
				status = KeSaveFloatingPointState(&saveData);
				if (!NT_SUCCESS(status))
				{
					return;
				}
				for (int i = 0; i < 100; i++)
				{
					f = f + 1.0f;
				}

				// doesn't check the return value of KeRestoreFloatingPointState
				status = KeRestoreFloatingPointState(&saveData);
			}
		}
		}
		
```

## Semmle-specific notes



## References
* [ Warning C28162 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28162-exiting-while-holding-right-to-use-floating-hardware)
