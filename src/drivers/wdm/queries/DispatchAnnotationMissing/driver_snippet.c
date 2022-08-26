// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.


//No dispatch annotation
DRIVER_DISPATCH DispatchPnp;
//Right dispatch function annotation
_Dispatch_type_(IRP_MJ_CREATE)
DRIVER_DISPATCH DispatchCreate;


void top_level_call(){    
}
