

/* this ALWAYS GENERATED file contains the definitions for the interfaces */


 /* File created by MIDL compiler version 8.01.0628 */
/* Compiler settings for Mft0.idl:
    Oicf, W1, Zp8, env=Win64 (32b run), target_arch=AMD64 8.01.0628 
    protocol : all , ms_ext, c_ext, robust
    error checks: allocation ref bounds_check enum stub_data 
    VC __declspec() decoration level: 
         __declspec(uuid()), __declspec(selectany), __declspec(novtable)
         DECLSPEC_UUID(), MIDL_INTERFACE()
*/
/* @@MIDL_FILE_HEADING(  ) */



/* verify that the <rpcndr.h> version is high enough to compile this file*/
#ifndef __REQUIRED_RPCNDR_H_VERSION__
#define __REQUIRED_RPCNDR_H_VERSION__ 500
#endif

/* verify that the <rpcsal.h> version is high enough to compile this file*/
#ifndef __REQUIRED_RPCSAL_H_VERSION__
#define __REQUIRED_RPCSAL_H_VERSION__ 100
#endif

#include "rpc.h"
#include "rpcndr.h"

#ifndef __RPCNDR_H_VERSION__
#error this stub requires an updated version of <rpcndr.h>
#endif /* __RPCNDR_H_VERSION__ */

#ifndef COM_NO_WINDOWS_H
#include "windows.h"
#include "ole2.h"
#endif /*COM_NO_WINDOWS_H*/

#ifndef __Mft0_h__
#define __Mft0_h__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#ifndef DECLSPEC_XFGVIRT
#if defined(_CONTROL_FLOW_GUARD_XFG)
#define DECLSPEC_XFGVIRT(base, func) __declspec(xfg_virtual(base, func))
#else
#define DECLSPEC_XFGVIRT(base, func)
#endif
#endif

/* Forward Declarations */ 

#ifndef __ISocMft0_FWD_DEFINED__
#define __ISocMft0_FWD_DEFINED__
typedef interface ISocMft0 ISocMft0;

#endif 	/* __ISocMft0_FWD_DEFINED__ */


#ifndef __Mft0_FWD_DEFINED__
#define __Mft0_FWD_DEFINED__

#ifdef __cplusplus
typedef class Mft0 Mft0;
#else
typedef struct Mft0 Mft0;
#endif /* __cplusplus */

#endif 	/* __Mft0_FWD_DEFINED__ */


/* header files for imported files */
#include "oaidl.h"
#include "ocidl.h"
#include "Inspectable.h"
#include "mftransform.h"

#ifdef __cplusplus
extern "C"{
#endif 


#ifndef __ISocMft0_INTERFACE_DEFINED__
#define __ISocMft0_INTERFACE_DEFINED__

/* interface ISocMft0 */
/* [unique][nonextensible][oleautomation][uuid][object] */ 


EXTERN_C const IID IID_ISocMft0;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("7B917902-D657-4437-9F93-93B94482F286")
    ISocMft0 : public IUnknown
    {
    public:
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE SetState( 
            /* [in] */ UINT32 state) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE GetState( 
            /* [out] */ __RPC__out UINT *pState) = 0;
        
    };
    
    
#else 	/* C style interface */

    typedef struct ISocMft0Vtbl
    {
        BEGIN_INTERFACE
        
        DECLSPEC_XFGVIRT(IUnknown, QueryInterface)
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            __RPC__in ISocMft0 * This,
            /* [in] */ __RPC__in REFIID riid,
            /* [annotation][iid_is][out] */ 
            _COM_Outptr_  void **ppvObject);
        
        DECLSPEC_XFGVIRT(IUnknown, AddRef)
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            __RPC__in ISocMft0 * This);
        
        DECLSPEC_XFGVIRT(IUnknown, Release)
        ULONG ( STDMETHODCALLTYPE *Release )( 
            __RPC__in ISocMft0 * This);
        
        DECLSPEC_XFGVIRT(ISocMft0, SetState)
        /* [id] */ HRESULT ( STDMETHODCALLTYPE *SetState )( 
            __RPC__in ISocMft0 * This,
            /* [in] */ UINT32 state);
        
        DECLSPEC_XFGVIRT(ISocMft0, GetState)
        /* [id] */ HRESULT ( STDMETHODCALLTYPE *GetState )( 
            __RPC__in ISocMft0 * This,
            /* [out] */ __RPC__out UINT *pState);
        
        END_INTERFACE
    } ISocMft0Vtbl;

    interface ISocMft0
    {
        CONST_VTBL struct ISocMft0Vtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define ISocMft0_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define ISocMft0_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define ISocMft0_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define ISocMft0_SetState(This,state)	\
    ( (This)->lpVtbl -> SetState(This,state) ) 

#define ISocMft0_GetState(This,pState)	\
    ( (This)->lpVtbl -> GetState(This,pState) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __ISocMft0_INTERFACE_DEFINED__ */



#ifndef __SampleSocMft0Lib_LIBRARY_DEFINED__
#define __SampleSocMft0Lib_LIBRARY_DEFINED__

/* library SampleSocMft0Lib */
/* [version][uuid] */ 


EXTERN_C const IID LIBID_SampleSocMft0Lib;

EXTERN_C const CLSID CLSID_Mft0;

#ifdef __cplusplus

class DECLSPEC_UUID("424BF154-D92A-42EB-B041-1395F9E5B4A2")
Mft0;
#endif
#endif /* __SampleSocMft0Lib_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif


