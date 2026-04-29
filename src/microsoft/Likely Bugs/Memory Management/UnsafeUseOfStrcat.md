# Potentially unsafe use of strcat
The standard library function `strcat` appends a source string to a target string. If you do not check the size of the source string then you cannot guarantee that appending the data to the target string will not cause a buffer overflow. Buffer overflows can lead to anything from a segmentation fault to a security vulnerability.


## Recommendation
Check the highlighted function calls carefully to ensure that no buffer overflow is possible. For a more robust solution, consider adding explicit range checks or using the `strncat` function instead.


## Example

```cpp
void f(char *s) {
	char buf[80];
	strcpy(buf, "s: ");
	strcat(buf, s);  // wrong: buffer not checked before strcat
}

void g(char *s) {
	char buf[80];
	strcpy(buf, "s: ");
	if(strlen(s) < 77)
		strcat(buf, s);  // correct: buffer size checked before strcat
}

```

## References
* I. Gerg, *An Overview and Example of the Buffer-Overflow Exploit*. IANewsletter vol 7, no 4, 2005.
* M. Donaldson, *Inside the Buffer Overflow Attack: Mechanism, Method &amp; Prevention*. SANS Institute InfoSec Reading Room. 2002.
* Common Weakness Enumeration: [CWE-676](https://cwe.mitre.org/data/definitions/676.html).
* Common Weakness Enumeration: [CWE-120](https://cwe.mitre.org/data/definitions/120.html).
* Common Weakness Enumeration: [CWE-251](https://cwe.mitre.org/data/definitions/251.html).
