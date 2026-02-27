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
