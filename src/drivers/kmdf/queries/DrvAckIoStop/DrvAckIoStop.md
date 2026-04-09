# DrvAckIoStop
KMDF drivers with power-managed I/O queues must register EvtIoStop or EvtDeviceSelfManagedIoSuspend to handle pending requests during power-down. Missing both causes Bug Check 0x9F.
