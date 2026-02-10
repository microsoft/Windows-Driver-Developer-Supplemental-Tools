# Weak cryptography
An initialization vector (IV) is an input to a cryptographic primitive being used to provide the initial state. The IV is typically required to be random or pseudorandom (randomized scheme), but sometimes an IV only needs to be unpredictable or unique (stateful scheme).

Randomization is crucial for some encryption schemes to achieve semantic security, a property whereby repeated usage of the scheme under the same key does not allow an attacker to infer relationships between (potentially similar) segments of the encrypted message.


## Recommendation
All symmetric block ciphers must also be used with an appropriate initialization vector (IV) according to the mode of operation being used.

If using a randomized scheme such as CBC, it is recommended to use cryptographically secure pseudorandom number generator such as `BCryptGenRandom`.


## References
* [BCryptEncrypt function (bcrypt.h)](https://docs.microsoft.com/en-us/windows/win32/api/bcrypt/nf-bcrypt-bcryptencrypt) [BCryptGenRandom function (bcrypt.h)](https://docs.microsoft.com/en-us/windows/win32/api/bcrypt/nf-bcrypt-bcryptgenrandom) [Initialization vector (Wikipedia)](https://en.wikipedia.org/wiki/Initialization_vector)
* Common Weakness Enumeration: [CWE-327](https://cwe.mitre.org/data/definitions/327.html).
