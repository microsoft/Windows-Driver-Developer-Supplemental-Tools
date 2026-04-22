# Uncontrolled data used in path expression
Accessing paths controlled by users can allow an attacker to access unexpected resources. This can result in sensitive information being revealed or deleted, or an attacker being able to influence behavior by modifying unexpected files.

Paths that are naively constructed from data controlled by a user may be absolute paths, or may contain unexpected special characters such as "..". Such a path could point anywhere on the file system.


## Recommendation
Validate user input before using it to construct a file path.

Common validation methods include checking that the normalized path is relative and does not contain any ".." components, or checking that the path is contained within a safe folder. The method you should use depends on how the path is used in the application, and whether the path should be a single path component.

If the path should be a single path component (such as a file name), you can check for the existence of any path separators ("/" or "\\"), or ".." sequences in the input, and reject the input if any are found.

Note that removing "../" sequences is *not* sufficient, since the input could still contain a path separator followed by "..". For example, the input ".../...//" would still result in the string "../" if only "../" sequences are removed.

Finally, the simplest (but most restrictive) option is to use an allow list of safe patterns and make sure that the user input matches one of these patterns.


## Example
In this example, a file name is read from a user and then used to access a file. However, a malicious user could enter a file name anywhere on the file system, such as "/etc/passwd" or "../../../etc/passwd".


```c
int main(int argc, char** argv) {
  char *userAndFile = argv[2];
  
  {
    char fileBuffer[PATH_MAX];
    snprintf(fileBuffer, sizeof(fileBuffer), "/home/%s", userAndFile);
    // BAD: a string from the user is used in a filename
    fopen(fileBuffer, "wb+");
  }
}

```
If the input should only be a file name, you can check that it doesn't contain any path separators or ".." sequences.


```c
#include <stdio.h>
#include <string.h>

int main(int argc, char** argv) {
    char *fileName = argv[2];
    // Check for invalid sequences in the user input
    if (strstr(fileName , "..") || strchr(fileName , '/') || strchr(fileName , '\\')) {
        printf("Invalid filename.\n");
        return 1;
    }

    char fileBuffer[PATH_MAX];
    snprintf(fileBuffer, sizeof(fileBuffer), "/home/user/files/%s", fileName);
    // GOOD: We know that the filename is safe and stays within the public folder
    FILE *file = fopen(fileBuffer, "wb+");
}
```
If the input should be within a specific directory, you can check that the resolved path is still contained within that directory.


```c
#include <stdio.h>
#include <string.h>

int main(int argc, char** argv) {
    char *userAndFile = argv[2];
    const char *baseDir = "/home/user/public/";
    char fullPath[PATH_MAX];

    // Attempt to concatenate the base directory and the user-supplied path
    snprintf(fullPath, sizeof(fullPath), "%s%s", baseDir, userAndFile);

    // Resolve the absolute path, normalizing any ".." or "."
    char *resolvedPath = realpath(fullPath, NULL);
    if (resolvedPath == NULL) {
        perror("Error resolving path");
        return 1;
    }

    // Check if the resolved path starts with the base directory
    if (strncmp(baseDir, resolvedPath, strlen(baseDir)) != 0) {
        free(resolvedPath);
        return 1;
    }

    // GOOD: Path is within the intended directory
    FILE *file = fopen(resolvedPath, "wb+");
    free(resolvedPath);
}
```

## References
* OWASP: [Path Traversal](https://owasp.org/www-community/attacks/Path_Traversal).
* Linux man pages: [realpath(3)](https://man7.org/linux/man-pages/man3/realpath.3.html).
* Common Weakness Enumeration: [CWE-22](https://cwe.mitre.org/data/definitions/22.html).
* Common Weakness Enumeration: [CWE-23](https://cwe.mitre.org/data/definitions/23.html).
* Common Weakness Enumeration: [CWE-36](https://cwe.mitre.org/data/definitions/36.html).
* Common Weakness Enumeration: [CWE-73](https://cwe.mitre.org/data/definitions/73.html).
