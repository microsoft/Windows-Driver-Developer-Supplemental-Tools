# DoubleCompletion
WDF drivers must not complete the same I/O request twice. Double-completing a WDFREQUEST corrupts framework state and can crash the system.
