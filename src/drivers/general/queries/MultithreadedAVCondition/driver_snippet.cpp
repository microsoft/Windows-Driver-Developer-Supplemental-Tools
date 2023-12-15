// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1
// Template. Not called in this test.
void top_level_call() {}

// Module Ref count
volatile LONG g_cRefModule = 0;

ULONG DllAddRef()
{
    return InterlockedIncrement(&g_cRefModule);
}

ULONG DllRelease()
{
    return InterlockedDecrement(&g_cRefModule);
}

class CObject
{

public:
    static HRESULT CreateInstance()
    {

        HRESULT hr = 0;

        CObject *obj1 = new CObject();

        obj1->Release_good();

        CObject *obj2 = new CObject();

        obj2->Release_good();
        return hr;
    };

    ULONG Release_good()
    {
        ASSERT(0 != m_cRef);
        ULONG cRef = InterlockedDecrement(&m_cRef);
        if (0 == cRef)
        {
            delete this;
            return NULL;
        }
        return cRef;
    }

    ULONG Release_bad()
    {
        if (0 == InterlockedDecrement(&m_cRef))
        {
            delete this;
            return NULL;
        }
        /* this.m_cRef isn't thread safe */
        return m_cRef;
    }
    ULONG
    AddRef()
    {
        return InterlockedIncrement(&m_cRef);
    }

private:
    CObject() : m_cRef(1)
    {
        DllAddRef();
    }

    ~CObject()
    {
        DllRelease();
    }

    long m_cRef;
};