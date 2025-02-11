#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>
#include <tchar.h>
#include <wchar.h>


#include "driver_snippet.c"

int __cdecl
main(
    _In_ ULONG argc,
    _In_reads_(argc) PCHAR argv[]
)
{
	UNREFERENCED_PARAMETER(argc);
	UNREFERENCED_PARAMETER(argv);
	printf("Hello World!\n");
	return 0;


}