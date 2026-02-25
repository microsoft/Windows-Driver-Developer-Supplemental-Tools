# Return value not examined (C28193)
This warning indicates that the calling function is not checking the value of the specified variable, which was supplied by a function.


## Recommendation
Make sure to check the result of the function that is annotated with _Check_result_ or _Must_check_result.


## Example
In this example, the driver tries to acquire a mutex but does not check the return value. This can cause a concurrency bug.

```c

			KeTryToAcquireGuardedMutex(&sharedMutex);
			DoDriverWork();
			
		
```
The driver should check if the mutex was successfully acquired before using it:

```c

			if(KeTryToAcquireGuardedMutex(&sharedMutex))
			{
				DoDriverWork();
			}
			else
			{
				// ...
			}
			
		
```

## References
* [ Warning C28193 | Microsoft Learn ](https://docs.microsoft.com/en-us/cpp/code-quality/c28193)

## Semmle-specific notes
To reduce noise, this rule only reports violations if more than 75% of the other calls to this function have their return values checked.

Note that this will still report issues if the value is only checked via ASSERTs that are compiled away at release time.

