# EvtSurpriseRemoveNoSuspendQueue
WDF drivers should not drain, stop, or purge I/O queues from the EvtDeviceSurpriseRemoval callback. Use self-managed I/O callbacks instead.
