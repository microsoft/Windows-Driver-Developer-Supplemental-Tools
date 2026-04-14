# Uncontrolled allocation size
This code allocates memory using a size value based on user input, with no apparent bound on its magnitude being established. This allows for arbitrary amounts of memory to be allocated.

If the allocation size is calculated by multiplying user input by a `sizeof` expression, the multiplication can overflow. When an integer multiplication overflows in C, the result wraps around and can be much smaller than intended. A later attempt to write data into the allocated memory can then be out of bounds.


## Recommendation
Guard all integer parameters that come from an external user. Implement a guard with the expected range for the parameter and make sure that the input value meets both the minimum and maximum requirements for this range. If the input value fails this guard then reject the request before proceeding further. If the input value passes the guard then subsequent calculations should not overflow.


## Example

```c
int factor = atoi(getenv("BRANCHING_FACTOR"));

// BAD: This can allocate too little memory if factor is very large due to overflow.
char **root_node = (char **) malloc(factor * sizeof(char *));

// GOOD: Prevent overflow and unbounded allocation size by checking the input.
if (factor > 0 && factor <= 1000) {
    char **root_node = (char **) malloc(factor * sizeof(char *));
}

```
This code shows one way to guard that an input value is within the expected range. If `factor` fails the guard, then an error is returned, and the value is not used as an argument to the subsequent call to `malloc`. Without this guard, the allocated buffer might be too small to hold the data intended for it.


## References
* The CERT Oracle Secure Coding Standard for C: [INT04-C. Enforce limits on integer values originating from tainted sources](https://www.securecoding.cert.org/confluence/display/c/INT04-C.+Enforce+limits+on+integer+values+originating+from+tainted+sources).
* Common Weakness Enumeration: [CWE-190](https://cwe.mitre.org/data/definitions/190.html).
* Common Weakness Enumeration: [CWE-789](https://cwe.mitre.org/data/definitions/789.html).
