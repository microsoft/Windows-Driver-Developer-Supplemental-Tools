# User provided pointer dereferenced without a probe.
In low-level Windows kernel code, dereferencing a pointer originating from user mode is dangerous if the pointer has not been validated (probed). An unvalidated pointer may point to privileged kernel memory or invalid addresses. Using proper user-mode accessors such as `ReadULongFromUser` or probing via APIs such as `ProbeForRead` ensures that invalid or malicious user-supplied addresses do not compromise the kernel.


## Recommendation
Before dereferencing pointers from user memory in kernel-mode code, always validate them.


## References
* Microsoft Learn: [User-mode accessors](https://learn.microsoft.com/en-us/windows-hardware/drivers/kernel/user-mode-accessors).
* Microsoft Learn: [ProbeForRead](https://learn.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-probeforread).
* Common Weakness Enumeration: [CWE-668](https://cwe.mitre.org/data/definitions/668.html).
