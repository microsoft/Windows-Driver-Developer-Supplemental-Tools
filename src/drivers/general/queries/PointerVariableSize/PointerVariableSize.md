# Pointer Variable Size
The driver is taking the size of a pointer variable, not the size of the value that is pointed to


## Recommendation
If the driver needs the size of the pointed-to value, change the code so that it references the value. If the driver actually needs the size of the pointer, take the size of the pointer type (for example, LPSTR, char\* or even void\*) to clarify that this is the intent.


## Example
The following code example elicits this warning.

```c
 
			void bad(){
				char* b = 0;
				memset(b, 0, sizeof(b));
			}
		}
		
```
The following code example avoids this warning.

```c
 
			void good(){
				char* b = 0;
				memset(b, 0, sizeof(*b));
			}
		}
		
```

## References
* [ Warning C28132 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28132-driver-taking-the-size-of-pointer)
