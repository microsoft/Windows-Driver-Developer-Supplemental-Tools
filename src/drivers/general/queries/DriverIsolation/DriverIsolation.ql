// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/TODO
 * @kind problem
 * @name TODO
 * @description TODO
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-TODO
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import semmle.code.cpp.dataflow.new.DataFlow

class RegistryIsolationFunction extends Function {
  RegistryIsolationFunction() {
    this.getName().matches("IoOpenDriverRegistryKey") or
    this.getName().matches("ZwCreateKey") or
    this.getName().matches("ZwCreateKeyTransacted") or
    this.getName().matches("ZwDeleteKey") or
    this.getName().matches("ZwDeleteValueKey") or
    this.getName().matches("ZwOpenKey") or
    this.getName().matches("ZwOpenKeyTransacted") or
    this.getName().matches("ZwOpenKeyEx") or
    this.getName().matches("ZwOpenKeyTransactedEx") or
    this.getName().matches("ZwQueryKey") or
    this.getName().matches("ZwRenameKey") or
    this.getName().matches("ZwSetInformationKey") or
    this.getName().matches("ZwSetValueKey") or
    this.getName().matches("ZwQueryValueKey") or
    this.getName().matches("RtlCreateRegistryKey") or
    this.getName().matches("RtlCheckRegistryKey") or
    this.getName().matches("RtlDeleteRegistryValue") or
    this.getName().matches("RtlWriteRegistryValue") or
    this.getName().matches("RtlQueryRegistryValues") or
    this.getName().matches("RtlQueryRegistryValuesEx")
  }
}

/**
 * todo structured comment
 */
class RegistryIsolationFunctionAccess extends FunctionAccess {
  RegistryIsolationFunctionAccess() { this.getTarget() instanceof RegistryIsolationFunction }
}

class RegistryIsolationFunctionCall extends FunctionCall {
  RegistryIsolationFunctionCall() { this.getTarget() instanceof RegistryIsolationFunction }
}

/*
 * InitializeObjectAttributes: For second param (PUNICODE_STRING), if fully qualified object name passed, then RootDirectory is NULL.
 * If relative path name to the object directory specified by RootDirectory (not null)
 */

module FlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(FieldAccess fa, VariableAccess va |
      fa.getTarget().getName().matches("RootDirectory") and
      va.getType().toString().matches("%OBJECT_ATTRIBUTES%") and
      va.getParent*() = fa.getParent*() and
      source.asExpr() = va
    )
  }

  // Block the flow if value assigned to RootDirectory is null
  predicate isBarrier(DataFlow::Node barrier) {
    exists(Expr assignedValue, FieldAccess fa, VariableAccess va |
      fa.getTarget().getName().matches("RootDirectory") and
      va.getType().toString().matches("%OBJECT_ATTRIBUTES%") and
      va.getParent*() = fa.getParent*() and
      assignedValue = fa.getTarget().getAnAssignedValue() and
      assignedValue.getParent*() = va.getParent*() and
      assignedValue.getValue().toString().matches("%") and // assignedValue only has a value when it's constant
      barrier.asExpr() = assignedValue
    )
  }

  predicate isSink(DataFlow::Node sink) {
    exists(FunctionCall f |
      zwViolation(f) and
      sink.asExpr() = f.getAnArgument()
    )
  }
}

module IsolationDataFlow = DataFlow::Global<FlowConfig>;

module FlowConfig2 implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(Expr arg, FunctionCall fc |
      (
        fc.getTarget().getName().matches("IoOpenDeviceRegistryKey") or
        fc.getTarget().getName().matches("WdfDeviceOpenRegistryKey") or
        fc.getTarget().getName().matches("WdfFdoInitOpenRegistryKey ") or
        fc.getTarget().getName().matches("CM_Open_DevNode_Key")
      ) and
      arg = fc.getAnArgument() and
      (
        arg.getType().toString().matches("%HANDLE%") or
        arg.getType().toString().matches("%WDFKEY%")
      ) and
      source.asIndirectExpr() = arg
    )
  }

  predicate isSink(DataFlow::Node sink) {
    exists(Expr assignedValue, FieldAccess fa, VariableAccess va |
      fa.getTarget().getName().matches("RootDirectory") and
      va.getType().toString().matches("%OBJECT_ATTRIBUTES%") and
      va.getParent*() = fa.getParent*() and
      assignedValue = fa.getTarget().getAnAssignedValue() and
      assignedValue.getParent*() = va.getParent*() and
      sink.asExpr() = assignedValue
    )
  }
}

module IsolationDataFlow2 = DataFlow::Global<FlowConfig2>;

// rule 1
predicate rtlViolation(RegistryIsolationFunctionCall f) {
  f.getTarget().getName().matches("Rtl%") and
  exists(MacroInvocation m |
    f.getArgument(0) = m.getExpr() and // more comments
    not m.getMacroName().matches("RTL_REGISTRY_DEVICEMAP")
  )
  // TODO read only OK
}

predicate zwViolation(RegistryIsolationFunctionCall f) {
  f.getTarget().getName().matches("ZwCreateKey%")
}

// registry violation rtl functions
/*
 * from RegistryIsolationFunctionCall f, int n, VariableAccess s
 * where
 *   rtlViolation(f)
 * select f
 */

// registry violation zw functions (only checks for non-null RootDirectory)

from DataFlow::Node source, DataFlow::Node sink
where
 IsolationDataFlow::flow(source, sink) and
 not exists(DataFlow::Node source2, DataFlow::Node sink2 | 
  IsolationDataFlow2::flow(source2, sink2) and
  source.asExpr().getParent*() = sink2.asExpr().getParent*()
 )
select source, sink
 
// from FunctionCall fc, Expr arg
// where
//   (
//     fc.getTarget().getName().matches("IoOpenDeviceRegistryKey") or
//     fc.getTarget().getName().matches("WdfDeviceOpenRegistryKey") or
//     fc.getTarget().getName().matches("WdfFdoInitOpenRegistryKey ") or
//     fc.getTarget().getName().matches("CM_Open_DevNode_Key")
//   ) and
//   arg = fc.getAnArgument() and
//   (
//     arg.getType().toString().matches("%HANDLE%") or
//     arg.getType().toString().matches("%WDFKEY%")
//   )
// select arg, arg.toString(), arg.getType(), arg.getType().toString()
