# Potential integer arithmetic overflow
Performing calculations on user-controlled data can result in integer overflows unless the input is validated.

Integer overflow occurs when the result of an arithmetic expression is too large to be represented by the (integer) output type of the expression. For example, if the result of the expression is 200, but the output type is a signed 8-bit integer, then overflow occurs because the largest value that can be represented is 127. The behavior of overflow is implementation defined, but the most common implementation is two's complement arithmetic, in which case the result is -56. Overflow can cause unexpected results, particularly when a large value overflows and the result is negative. It can also pose a security risk if the value of the expression is controllable by user, because it could enable an attacker to deliberately cause an overflow.

Negative integer overflow is another form of integer overflow, in which a negative result cannot be represented in the output type.


## Recommendation
Always guard against overflow in arithmetic operations on user-controlled data by doing one of the following:

* Validate the user input.
* Define a guard on the arithmetic expression, so that the operation is performed only if the result can be known to be less than, or equal to, the maximum value for the type, for example `INT_MAX`.
* Use a wider type, so that larger input values do not cause overflow.

## Example
In this example, a value is read from standard input into an `int`. Because the value is a user-controlled value, it could be extremely large. Performing arithmetic operations on this value could therefore cause an overflow. To avoid this happening, the example shows how to perform a check before performing a multiplication.


```c
int main(int argc, char** argv) {
	char buffer[20];
	fgets(buffer, 20, stdin);

	int num = atoi(buffer);
	// BAD: may overflow if input is very large
	int scaled = num + 1000;

	// ...

	int num2 = atoi(buffer);
	int scaled2;
	// GOOD: use a guard to prevent overflow
	if (num2 < INT_MAX-1000)
		scaled2 = num2 + 1000;
	else
		scaled2 = INT_MAX;
}

```

## References
* Common Weakness Enumeration: [CWE-190](https://cwe.mitre.org/data/definitions/190.html).
* Common Weakness Enumeration: [CWE-197](https://cwe.mitre.org/data/definitions/197.html).
* Common Weakness Enumeration: [CWE-681](https://cwe.mitre.org/data/definitions/681.html).
