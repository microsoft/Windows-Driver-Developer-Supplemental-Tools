
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}

// BOOL WINAPI DllMain(
//     HINSTANCE hinstDLL, // handle to DLL module
//     DWORD fdwReason,    // reason for calling function
//     LPVOID lpvReserved) // reserved
// {
//     // Perform actions based on the reason for calling.
//     switch (fdwReason)
//     {
//     case DLL_PROCESS_ATTACH:
//         LoadLibrary(L"kernel32.dll"); // Unsafe: LoadLibrary in global init
//         // Initialize once for each new process.
//         // Return FALSE to fail DLL load.
//         break;

//     case DLL_THREAD_ATTACH:
//         // Do thread-specific initialization.
//         break;

//     case DLL_THREAD_DETACH:
//         // Do thread-specific cleanup.
//         break;

//     case DLL_PROCESS_DETACH:

//         if (lpvReserved != nullptr)
//         {
//             break; // do not do cleanup if process termination scenario
//         }

//         // Perform any necessary cleanup.
//         break;
//     }
//     return TRUE; // Successful DLL_PROCESS_ATTACH.
// }
