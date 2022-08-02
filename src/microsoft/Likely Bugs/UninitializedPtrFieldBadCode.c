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

	ComPtr<Test> ptr;
	// BAD: pointer is not initialized here
	val = ptr->it();
}
