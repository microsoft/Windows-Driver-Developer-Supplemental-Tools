/**
 * @name WDF Queue and Power Management Model
 * @description Models WDF I/O queue configuration and power management
 *              callback registration patterns. Provides classes and predicates
 *              for analyzing whether queues are power-managed and whether
 *              appropriate power-down callbacks are registered.
 *
 * ## Modeled APIs
 * - `WdfIoQueueCreate` — creates I/O queues with `WDF_IO_QUEUE_CONFIG`
 * - `WDF_IO_QUEUE_CONFIG_INIT` / `_INIT_DEFAULT_QUEUE` — initializes config
 * - `WdfDeviceInitSetPnpPowerEventCallbacks` — registers PnP/power callbacks
 * - `WdfFdoInitSetFilter` — marks driver as filter (affects power management defaults)
 *
 * ## Key Concepts
 * - Power-managed queues: `PowerManaged == WdfTrue(1)` or `WdfUseDefault(2)` for non-filter drivers
 * - `EvtIoStop`: callback invoked during power-down for pending requests
 * - `EvtDeviceSelfManagedIoSuspend`: alternative for handling power-down
 *
 * ## Limitations
 * - Field assignments through pointer indirection or helper functions may not be detected
 * - `WdfUseDefault` resolution depends on detecting `WdfFdoInitSetFilter` in the same function scope
 */

import cpp

/**
 * A call to `WdfIoQueueCreate`, which creates an I/O queue.
 * The second argument is a pointer to `WDF_IO_QUEUE_CONFIG`.
 */
class WdfIoQueueCreateCall extends FunctionCall {
  WdfIoQueueCreateCall() {
    this.getTarget().getName() = "WdfIoQueueCreate"
  }

  /** Gets the WDF_IO_QUEUE_CONFIG pointer argument (arg index 1). */
  Expr getConfigArg() { result = this.getArgument(1) }

  /**
   * Gets the local variable holding the WDF_IO_QUEUE_CONFIG struct,
   * traced from the `&config` argument.
   */
  Variable getConfigVariable() {
    // Pattern: WdfIoQueueCreate(device, &queueConfig, ...)
    result = this.getConfigArg().(AddressOfExpr).getOperand().(VariableAccess).getTarget()
  }
}

/**
 * An assignment to a field of a `WDF_IO_QUEUE_CONFIG` struct variable.
 * Matches patterns like `queueConfig.EvtIoStop = MyStopCallback;`
 */
class QueueConfigFieldAssignment extends AssignExpr {
  Variable configVar;
  string fieldName;

  QueueConfigFieldAssignment() {
    exists(FieldAccess fa |
      this.getLValue() = fa and
      fa.getQualifier().(VariableAccess).getTarget() = configVar and
      fa.getTarget().getName() = fieldName
    )
  }

  /** Gets the config variable being modified. */
  Variable getConfigVariable() { result = configVar }

  /** Gets the field name being assigned. */
  string getFieldName() { result = fieldName }
}

/**
 * Holds if `configVar` has its `EvtIoStop` field set to a non-null value
 * in the same function as `queueCreate`.
 */
predicate hasEvtIoStopCallback(Variable configVar, Function scope) {
  exists(QueueConfigFieldAssignment assign |
    assign.getFieldName() = "EvtIoStop" and
    assign.getConfigVariable() = configVar and
    assign.getEnclosingFunction() = scope and
    // The value assigned is not NULL/0
    not assign.getRValue().getValue() = "0"
  )
}

/**
 * Holds if `configVar` has its `PowerManaged` field explicitly set to
 * `WdfFalse` (0) in the same function.
 */
predicate isPowerManagedExplicitlyDisabled(Variable configVar, Function scope) {
  exists(QueueConfigFieldAssignment assign |
    assign.getFieldName() = "PowerManaged" and
    assign.getConfigVariable() = configVar and
    assign.getEnclosingFunction() = scope and
    assign.getRValue().getValue() = "0" // WdfFalse == 0
  )
}

/**
 * Holds if `configVar` has its `PowerManaged` field explicitly set to
 * `WdfTrue` (1) in the same function.
 */
predicate isPowerManagedExplicitlyEnabled(Variable configVar, Function scope) {
  exists(QueueConfigFieldAssignment assign |
    assign.getFieldName() = "PowerManaged" and
    assign.getConfigVariable() = configVar and
    assign.getEnclosingFunction() = scope and
    assign.getRValue().getValue() = "1" // WdfTrue == 1
  )
}

/**
 * A call to `WdfFdoInitSetFilter`, indicating this is a filter driver.
 * Filter drivers have non-power-managed queues by default.
 */
class WdfFdoInitSetFilterCall extends FunctionCall {
  WdfFdoInitSetFilterCall() {
    this.getTarget().getName() = "WdfFdoInitSetFilter"
  }
}

/**
 * Holds if the driver calls `WdfFdoInitSetFilter` anywhere in its codebase,
 * indicating it is a filter driver.
 */
predicate isFilterDriver() {
  exists(WdfFdoInitSetFilterCall fc | fc.getTarget().getName() = "WdfFdoInitSetFilter")
}

/**
 * A call to `WdfDeviceInitSetPnpPowerEventCallbacks`, which registers
 * PnP and power event callbacks via a `WDF_PNPPOWER_EVENT_CALLBACKS` struct.
 */
class WdfSetPnpPowerCallbacksCall extends FunctionCall {
  WdfSetPnpPowerCallbacksCall() {
    this.getTarget().getName() = "WdfDeviceInitSetPnpPowerEventCallbacks"
  }

  /** Gets the WDF_PNPPOWER_EVENT_CALLBACKS pointer argument (arg index 1). */
  Expr getCallbacksArg() { result = this.getArgument(1) }

  /** Gets the local variable holding the callbacks struct. */
  Variable getCallbacksVariable() {
    result = this.getCallbacksArg().(AddressOfExpr).getOperand().(VariableAccess).getTarget()
  }
}

/**
 * Holds if `EvtDeviceSelfManagedIoSuspend` is registered anywhere in the driver.
 * Checks for assignments to the `EvtDeviceSelfManagedIoSuspend` field of any
 * `WDF_PNPPOWER_EVENT_CALLBACKS` struct that is passed to
 * `WdfDeviceInitSetPnpPowerEventCallbacks`.
 */
predicate hasSelfManagedIoSuspendCallback() {
  exists(WdfSetPnpPowerCallbacksCall setPnp, Variable callbacksVar, AssignExpr assign, FieldAccess fa |
    callbacksVar = setPnp.getCallbacksVariable() and
    assign.getLValue() = fa and
    fa.getQualifier().(VariableAccess).getTarget() = callbacksVar and
    fa.getTarget().getName() = "EvtDeviceSelfManagedIoSuspend" and
    not assign.getRValue().getValue() = "0"
  )
}

/**
 * Holds if the I/O queue created by `queueCreate` is power-managed.
 *
 * A queue is power-managed if:
 * - `PowerManaged` is explicitly set to `WdfTrue` (1), OR
 * - `PowerManaged` is `WdfUseDefault` (2, the default) AND the driver is
 *   not a filter driver (filter queues default to non-power-managed)
 *
 * A queue is NOT power-managed if:
 * - `PowerManaged` is explicitly set to `WdfFalse` (0)
 */
predicate isQueuePowerManaged(WdfIoQueueCreateCall queueCreate) {
  exists(Variable configVar, Function scope |
    configVar = queueCreate.getConfigVariable() and
    scope = queueCreate.getEnclosingFunction() and
    not isPowerManagedExplicitlyDisabled(configVar, scope) and
    (
      isPowerManagedExplicitlyEnabled(configVar, scope)
      or
      // Default (WdfUseDefault) is power-managed for non-filter drivers
      (
        not isPowerManagedExplicitlyEnabled(configVar, scope) and
        not isFilterDriver()
      )
    )
  )
}
