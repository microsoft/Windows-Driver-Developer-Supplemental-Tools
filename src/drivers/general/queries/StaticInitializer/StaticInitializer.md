# Static Initializer
Static initializers of global or static const variables can often be fully evaluated at compile time, thus generated in RDATA. However if any initializer is a pointer-to-member-function where it is a non-static function, the entire initialier may be placed in copy-on-write pages, which has a performance cost.


## Recommendation
For binaries which require fast loading and minimizing copy on write pages, consider making sure all function pointer in the static initializer are not pointer-to-member-function. If a pointer-to-member-function is required, write a simple static member function that wraps a call to the actual member function.


## Example
Code which triggers this query:

```c
 
                    class MyClass
                    {
                        ...
                        bool memberFunc();
                        ...
                    };
                    const StructType MyStruct[] = {
                        ...
                        &MyClass::memberFunc,
                        ...
                    };
                
		
```
Good code:

```c
 
                    class MyClass
                    {
                        ...
                        bool memberFunc();
                        static bool memberFuncWrap(MyClass *thisPtr)
                            { return thisPtr->memberFunc(); }
                        ...
                    };
                    const StructType MyStruct[] = {
                        ...
                        &MyClass::memberFuncWrap,
                        ...
                    };
                
		
```

## Semmle-specific notes



## References
* [ C28651 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28651-member-function-pointers-cause-write-pages-copy)
