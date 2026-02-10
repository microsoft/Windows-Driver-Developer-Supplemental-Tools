# Important function call optimized out
Function call used to clear sensitive data will be optimized away


## Recommendation
This Function call may be optimized away during compile, resulting in sensitive data lingering in memory. Use SecureZeroMemory or RtlSecureZeroMemory instead. A heuristic looks for identifier names that contain items such as "key" or "pass" to trigger this warning.


## Example
Example of instance where function call may be optimized away

```c
 
		void bad_func()
		{
			char Password[100];

			/*
			* The Buffer will be going out of scope
			* anyway so the compiler optimises away
			* the following
			*/
			ZeroMemory(Password, sizeof(Password));
		}
		}
		
```
Using SecureZeroMemory or RtlSecureZeroMemory will prevent the compiler from optimizing away the function call.

```c
 
		void good_func()
		{
			char Password[100];

			RtlSecureZeroMemory(Password, sizeof(Password));
		}
		}
		
```

## References
* [ C28625 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28625-sensitive-data-may-be-retained)
