/*
	Copyright (c) Microsoft Corporation.  All rights reserved.
*/

#ifndef SDV_STUBS_H
#define SDV_STUBS_H

void sdv_do_assert_check(int exp);
void sdv_do_paged_code_check(); 
void sdv_stub_driver_init();
void sdv_stub_PowerQuery();
void sdv_stub_PowerUpOrDown();
void sdv_stub_startio_begin();
void sdv_stub_startio_end();
void sdv_stub_dispatch_begin();
void sdv_stub_dispatch_end(NTSTATUS s, PIRP pirp);
void sdv_stub_cancel_begin(PIRP pirp);
void sdv_stub_cancel_end(PIRP pirp);
void sdv_stub_add_begin();
void sdv_stub_add_end();
void sdv_stub_unload_begin();
void sdv_stub_unload_end();
void sdv_stub_MoreProcessingRequired(PIRP pirp);
void sdv_stub_WmiIrpProcessed(PIRP pirp);
void sdv_stub_WmiIrpNotCompleted(PIRP pirp);
void sdv_stub_WmiIrpForward(PIRP pirp);
void sdv_stub_PnpIrpNotProcessed();
void sdv_stub_worker_begin();
void sdv_stub_worker_end();
void sdv_stub_io_completion_begin();
void sdv_stub_io_completion_end();
void sdv_stub_power_completion_begin();
char* malloc(int i);
void sdv_stub_ioctl_begin();
void sdv_stub_ioctl_end();
void sdv_stub_pnp_query_begin();
void sdv_stub_pnp_query_end();
void sdv_stub_power_runtime_begin();
void sdv_stub_power_runtime_critical_begin();
#endif
