# Strict Type Match
The argument should exactly match the type


## Recommendation
An enumerated value in a function call does not match the type specified for the parameter in the function declaration. This error can occur when parameters are mis-coded, missing, or out of order. Because C permits enumerated values to be used interchangeably, and to be used interchangeably with integer constants, it is not unusual to pass the wrong enumerated value to a function without recognizing the error.


## Example
The following code example elicits this warning.

```c
 
 		KeWaitForSingleObject(
			&EventDone,
			Executive,
			Executive,
			FALSE,
			NULL);
		
```
The following code example avoids this warning.

```c
 
		KeWaitForSingleObject(
			&EventDone,
			Executive,
			KernelMode,
			FALSE,
			NULL);
		
```

## References
* [ C28139 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28139-argument-operand-should-exactly-match)
