// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

template <typename T>
class ComPtr
{
public:
	T* ptr_;

	ComPtr() throw() : ptr_(nullptr)
	{
	}

	ComPtr(T* ptr) throw() : ptr_(ptr)
	{
	}

	T* operator->() const throw()
	{
		return ptr_;
	}

	void set(T* ptr) {
		ptr_ = ptr;
	}

	T** addr() {
		return &ptr_;
	}
};

class Test
{
public:
	int it_;
	int it() {
		return it_;
	}
};

void test() {
	Test t;
	int val;

	ComPtr<Test> ptr2(&t);
	// GOOD: pointer was initialized
	val = ptr2->it();

	ComPtr<Test> ptr3;
	ptr3.set(&t);
	// GOOD: pointer was set in between
	val = ptr3->it();
}
