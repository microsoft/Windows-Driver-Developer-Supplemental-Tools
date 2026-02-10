# Null Character Pointer Assignment
Possible assignment of '\\\\0' directly to a pointer


## Recommendation
This warning indicates a probable typographical error: a null character is being assigned to a pointer; it is probably the case that the character is intended as a string terminator and should be assigned to the memory where the pointer is pointing.


## Example
Example of incorrect assignment of '\\0' to a pointer

```c
 
				char a[8];
				char *p = a;
				char x = 0;
				char y = '0';
				p = '\0'; // should be *p = '\0';
			}
		
```
Example of correct assignment of '\\0' to where the pointer is pointing

```c
 
			char a[8];
   			char *p = a;
    		*p = '\0'; // correct!
		}
		
```

## References
* [ Warning C28730 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28730-possible-null-character-assignment)
