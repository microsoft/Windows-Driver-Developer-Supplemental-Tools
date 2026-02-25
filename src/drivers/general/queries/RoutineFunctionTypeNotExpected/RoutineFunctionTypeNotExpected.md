# Unexpected function return type for routine (C28127)
The driver is passing or assigning a function (pointer) of an unexpected type (that is, function signature)


## Recommendation
Verify function pointer is correct


## Example
In this example, the driver provides a pointer to a function that returns long where a function that returns int is expected:

```c
 
		typedef long
		functionCallLong(void);
		typedef functionCallLong *funcCallLong;
		
		int useFP(funcCallLong);

		int badFunction(void);
		
		void doError() {
			useFP(&badFunction);
		}
		
```
Ensure your function definitions match what is expected, and use roletypes and typedefs to help reduce issues.

```c
 
		typedef long
		functionCallLong(void);
		typedef functionCallLong *funcCallLong;
		
		int useFP(funcCallLong);

		functionCallLong goodFunction;
		
		void doCorrect() {
			useFP(&goodFunction);
		}
		
```

## References
* [ C28127 warning - Windows Drivers ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28127-function-routine-mismatch)

## Semmle-specific notes
In some cases, this rule may report false positives where it claims two identical parameter types do not match. This issue is under investigation.

