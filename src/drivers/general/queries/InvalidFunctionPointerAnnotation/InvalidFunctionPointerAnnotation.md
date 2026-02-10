# Invalid Function Pointer Annotation
The function pointer annotation class does not match the function class


## Recommendation
A function pointer has a __drv_functionClass annotation that specifies that only functions of a particular functional class should be assigned to it. In an assignment or implied assignment in a function call, the source and target must be of the same function class, but the function classes do not match.


## Example
A call to IoQueueWorkItem is expecting a function pointer annotated with __drv_functionClass(IO_WORKITEM_ROUTINE) but in this example, badAnnotationFunc1 is annotated with __drv_functionClass(IO_TIMER_ROUTINE).

```c
 
    	IoQueueWorkItem(IoWorkItem, badAnnotationFunc1, DelayedWorkQueue, Context);
		}
		
```

## Semmle-specific notes



## References
* [ Warning C28165 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28165-class-function-pointer-mismatch)
