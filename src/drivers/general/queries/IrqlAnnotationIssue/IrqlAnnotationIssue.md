# Irql Annotation Issue
The value for an IRQL from annotation could not be evaluated in this context.


## Recommendation
This warning indicates that the Code Analysis tool cannot interpret the function annotation because the annotation is not coded correctly. As a result, the Code Analysis tool cannot determine the specified IRQL value. This warning can occur with any of the driver-specific annotations that mention an IRQL when the Code Analysis tool cannot evaluate the expression for the IRQL.


## Example
Incorrect IRQL annotation

```c
 
			_IRQL_requires_(65)
		
```
Incorrect IRQL annotation

```c
 
			_IRQL_always_function_max_(irql_variable)
		
```

## References
* [ C28153 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28153-irql-annotation-eval-context)
