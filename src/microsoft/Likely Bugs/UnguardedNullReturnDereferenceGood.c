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
