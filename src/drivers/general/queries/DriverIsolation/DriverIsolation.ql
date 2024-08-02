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

/*
 * OBJECT_ATTRIBUTES->RootDirectory is non-null
 */

module IsolationDataFlowNonNullRootDirConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(FieldAccess fa, VariableAccess va |
      fa.getTarget().getName().matches("RootDirectory") and
      va.getType().toString().matches("%OBJECT_ATTRIBUTES%") and
      va.getParent*() = fa.getParent*() and
      source.asIndirectExpr() = va and
      not exists(Expr assignedValue |
        assignedValue = fa.getTarget().getAnAssignedValue() and
        assignedValue.getParent*() = va.getParent*() and
        assignedValue.getValue().toString().matches("%") // assignedValue only has a value when it's constant
      )
    )
  }

  predicate isSink(DataFlow::Node sink) {
    exists(FunctionCall f |
      zwViolation(f) and
      sink.asIndirectExpr() = f.getAnArgument()
    )
  }
}

module IsolationDataFlowNonNullRootDir = DataFlow::Global<IsolationDataFlowNonNullRootDirConfig>;

/*
 * OBJECT_ATTRIBUTES->RootDirectory is NULL
 */

module IsolationDataFlowNullRootDirConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(FieldAccess fa, VariableAccess va, Expr assignedValue |
      fa.getTarget().getName().matches("RootDirectory") and
      va.getType().toString().matches("%OBJECT_ATTRIBUTES%") and
      va.getParent*() = fa.getParent*() and
      assignedValue = fa.getTarget().getAnAssignedValue() and
      assignedValue.getParent*() = va.getParent*() and
      assignedValue.getValue().toString().matches("%") and // assignedValue only has a value when it's constant
      source.asIndirectExpr() = va
    )
  }

  predicate isSink(DataFlow::Node sink) {
    exists(FunctionCall f |
      zwViolation(f) and
      sink.asIndirectExpr() = f.getAnArgument()
    )
  }
}

module IsolationDataFlowNullRootDir = DataFlow::Global<IsolationDataFlowNullRootDirConfig>;

/*
 * //
 */

module IsolationDataFlowObjectNameConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(FieldAccess fa, VariableAccess va, Expr assignedValue |
      fa.getTarget().getName().matches("ObjectName") and
      va.getType().toString().matches("%OBJECT_ATTRIBUTES%") and
      va.getParent*() = fa.getParent*() and
      source.asIndirectExpr() = va
    )
  }

  predicate isSink(DataFlow::Node sink) {
    exists(FunctionCall f |
      zwViolation(f) and
      sink.asIndirectExpr() = f.getAnArgument()
    )
  }
}

module IsolationDataFlowObjectName = DataFlow::Global<IsolationDataFlowObjectNameConfig>;

/*
 * Allow read access if OBJECT_ATTRIBUTES->ObjectName is initialized with \registry\machine\hardware%
 */

module IsolationDataFlowAllowedRead implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    //source.asExpr().getType().toString().matches("%UNICODE_STRING%")
    exists(VariableAccess assignedVal |
      assignedVal.getTarget().getAnAssignedValue().toString().toLowerCase().matches("%") and // TODO \registry\machine\hardware
      source.asIndirectExpr() = assignedVal and
      not assignedVal.getType().toString().matches("%OBJECT_ATTRIBUTES%")
    )
  }

  predicate isAdditionalFlowStep(DataFlow::Node pred, DataFlow::Node succ) {
    exists(VariableAccess va0, VariableAccess va1, FunctionCall fc |
      (
        fc.getTarget().getName().matches("RtlInitUnicodeString") or
        fc.getTarget().getName().matches("RtlUnicodeStringInit ")
      ) and
      fc.getArgument(1) = va1.getParent*() and
      fc.getArgument(0) = va0.getParent*() and
      va0 = succ.asIndirectArgument() and
      va1 = pred.asIndirectArgument()
    )
  }

  predicate isSink(DataFlow::Node sink) {
    exists(FieldAccess fa, VariableAccess va, Expr assignedValue |
      fa.getTarget().getName().matches("ObjectName") and
      va.getType().toString().matches("%OBJECT_ATTRIBUTES%") and
      va.getParent*() = fa.getParent*() and
      assignedValue = fa.getTarget().getAnAssignedValue() and
      assignedValue.getParent*() = va.getParent*() and
      sink.asIndirectExpr() = assignedValue
    )
  }
}

module AllowedReadFlow = DataFlow::Global<IsolationDataFlowAllowedRead>;

/*
 * If using a Zw* registry function and the OBJECT_ATTRIBUTES passed to it has a non-null RootDirectory
 * whether or not it is a violation depends on where the handle they specify in RootDirectory comes from.
 */

module AllowedRootDirectoryFlowConfig implements DataFlow::ConfigSig {
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

module AllowedRootDirectoryFlow = DataFlow::Global<AllowedRootDirectoryFlowConfig>;

// rule 1
predicate rtlViolation(RegistryIsolationFunctionCall f) {
  f.getTarget().getName().matches("Rtl%") and
  exists(MacroInvocation m |
    f.getArgument(0) = m.getExpr() and // more comments
    not m.getMacroName().matches("RTL_REGISTRY_DEVICEMAP")
  )
  // TODO read only OK
}

predicate zwViolation(RegistryIsolationFunctionCall f) { f.getTarget().getName().matches("Zw%") }


// 
from DataFlow::Node source, DataFlow::Node sink, DataFlow::Node source2, DataFlow::Node sink2, Element p1, Stmt p2
where
  IsolationDataFlowNullRootDir::flow(source, sink) 
  and AllowedReadFlow::flow(source2, sink2)
  and sink2 != source2
  //and source.asIndirectExpr().getParent*() = sink2.asIndirectExpr().getParent*()
  and p1 = source.asIndirectExpr().getEnclosingStmt().getEnclosingElement()
  and p2 = sink2.asIndirectExpr().getEnclosingStmt().getEnclosingElement()
  and p1 = p2
  and source.asIndirectExpr().getFile().getAbsolutePath().toString().matches("%shnotification.cpp%")
  and sink2.asIndirectExpr().getFile().getAbsolutePath().toString().matches("%shnotification.cpp%")

select source, sink, source2, sink2, p1, p2




// registry violation rtl functions
/*
 * from RegistryIsolationFunctionCall f, int n, VariableAccess s
 * where
 *   rtlViolation(f)
 * select f
 */

// // registry violation zw functions ( non-null RootDirectory)
// from DataFlow::Node source, DataFlow::Node sink
// where
//   IsolationDataFlowNonNullRootDir::flow(source, sink) and
//   not exists(DataFlow::Node source2, DataFlow::Node sink2 |
//     AllowedRootDirectoryFlow::flow(source2, sink2) and
//     source.asExpr().getParent*() = sink2.asExpr().getParent*()
//   )
//   or
//   IsolationDataFlowNullRootDir::flow(source, sink)
// select source, source.toString(), sink, sink.toString()
