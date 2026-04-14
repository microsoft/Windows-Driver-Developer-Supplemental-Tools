# Possibly wrong buffer size in string copy
The standard library function `strncpy` copies a source string to a destination buffer. The third argument defines the maximum number of characters to copy and should be less than or equal to the size of the destination buffer. Calls of the form `strncpy(dest, src, strlen(src))` or `strncpy(dest, src, sizeof(src))` incorrectly set the third argument to the size of the source buffer. Executing a call of this type may cause a buffer overflow. Buffer overflows can lead to anything from a segmentation fault to a security vulnerability.


## Recommendation
Check the highlighted function calls carefully, and ensure that the size parameter is derived from the size of the destination buffer, not the source buffer.


## Example
In the following examples, the size of the source buffer is incorrectly used as a parameter to `strncpy`:


```cpp
char src[256];
char dest1[128];

...

strncpy(dest1, src, sizeof(src)); // wrong: size of dest should be used

char *dest2 = (char *)malloc(sz1 + sz2 + sz3);
strncpy(dest2, src, strlen(src)); // wrong: size of dest should be used

```
The corrected version uses the size of the destination buffer, or a variable containing the size of the destination buffer as the size parameter to `strncpy`:


```cpp
char src[256];
char dest1[128];

...

strncpy(dest1, src, sizeof(dest1)); // correct

size_t destSize = sz1 + sz2 + sz3;
char *dest2 = (char *)malloc(destSize);
strncpy(dest2, src, destSize); // correct

```

## References
* cplusplus.com: [strncpy](https://cplusplus.com/reference/cstring/strncpy/).
* I. Gerg. *An Overview and Example of the Buffer-Overflow Exploit*. IANewsletter vol 7 no 4. 2005.
* M. Donaldson. *Inside the Buffer Overflow Attack: Mechanism, Method &amp; Prevention*. SANS Institute InfoSec Reading Room. 2002.
* Common Weakness Enumeration: [CWE-676](https://cwe.mitre.org/data/definitions/676.html).
* Common Weakness Enumeration: [CWE-119](https://cwe.mitre.org/data/definitions/119.html).
* Common Weakness Enumeration: [CWE-251](https://cwe.mitre.org/data/definitions/251.html).
