# Result of call that may return NULL dereferenced unconditionally
A null pointer dereference can cause program crash or exit.


## Recommendation
Make sure to initialize all pointer fields before usage.


## Example
The following examples show scenarios where a pointer is dereferenced without a null check.


```c
#define NULL (0)
typedef void * PVOID;
typedef enum _POOL_TYPE {
	NonPagedPool
	// ...
} POOL_TYPE;
typedef int SIZE_T;
typedef unsigned long ULONG;

PVOID ExAllocatePoolWithTag(POOL_TYPE, SIZE_T, ULONG);

void use(char* data);

void free(char* data);

char* malloc(int size);

void test(bool b) {
	char* data;
	data = (char*) ExAllocatePoolWithTag(NonPagedPool, sizeof(*data), 'tag');
	// BAD: 'data' is not null-checked
	use(data);

	char* data2 = (char*) ExAllocatePoolWithTag(NonPagedPool, sizeof(*data2), 'tag');
	// BAD: 'data2' is not null-checked
	use(data2);

	if (b)
	{
		// BAD
		char* data6 = (char*)malloc(12);
		use(data6);
	}
}

```
To correct the problem, check the pointer before dereferencing.


```c
#define NULL (0)
typedef void * PVOID;
typedef enum _POOL_TYPE {
	NonPagedPool
	// ...
} POOL_TYPE;
typedef int SIZE_T;
typedef unsigned long ULONG;

PVOID ExAllocatePoolWithTag(POOL_TYPE, SIZE_T, ULONG);

void use(char* data);

void free(char* data);

char* malloc(int size);

void test(bool b) {
	char* data;

	data = (char*) ExAllocatePoolWithTag(NonPagedPool, sizeof(*data), 'tag');
	if (data != NULL)
		// GOOD: 'data' is null-checked
		use(data);

	char* data3 = (char*) ExAllocatePoolWithTag(NonPagedPool, sizeof(*data3), 'tag');
	if (data3 != NULL)
		// GOOD: 'data' is null-checked
		use(data3);
	
	char *data4 = malloc(12);
	// GOOD: 'free' is null-safe
	free(data4);

	// GOOD
	if (char* data5 = (char*)malloc(12))
	{
		use(data5);
	}

	// GOOD
	if (data4 = (char*)malloc(12))
	{
		use(data4);
	}
}

```

## References
* CWE: [CWE-476: NULL Pointer Dereference](https://cwe.mitre.org/data/definitions/476.html).
* Common Weakness Enumeration: [CWE-476](https://cwe.mitre.org/data/definitions/476.html).
