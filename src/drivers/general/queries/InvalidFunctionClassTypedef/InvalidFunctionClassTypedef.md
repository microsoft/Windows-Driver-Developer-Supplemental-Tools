# Invalid Function Class Typedef
The function class on the function does not match the function class on the typedef used here


## Recommendation
This warning indicates that an annotation on a function class does not match the function type, as specified by the type declaration. This warning indicates an error in the annotations, not in the code that is being analyzed.


## Example
Example where typedef of one type is used to declare the function but typedef of a different type is used in the function definition inside __drv_functionClass

```c
 
	typedef __drv_functionClass(TEST_ROUTINE)
    VOID
    TEST_ROUTINE(
		VOID);
	typedef TEST_ROUTINE *PTEST_ROUTINE;

    // declare function with above typedef
	TEST_ROUTINE func2;

	// define function, but with different function class which causes the warning
	__drv_functionClass(TEST_ROUTINE2)
		VOID func2(
			VOID)
	{
		; // Don't need to do anything heres
	}
		}
		
```

## Semmle-specific notes



## References
* [ C28268 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28268-function-class-does-not-match-typedef)
