# InitRegisterInterrupt
NDIS miniport drivers that register interrupts with NdisMRegisterInterruptEx during initialization must deregister them with NdisMDeregisterInterruptEx during MiniportHaltEx.
