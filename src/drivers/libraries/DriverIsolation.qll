import cpp
import semmle.code.cpp.dataflow.new.DataFlow
import semmle.code.cpp.dataflow.new.TaintTracking
import semmle.code.cpp.controlflow.ControlFlowGraph

class RtlRegistryIsolationFunction extends Function {
  RtlRegistryIsolationFunction() {
    this.getName().matches("RtlCreateRegistryKey") or
    this.getName().matches("RtlCheckRegistryKey") or
    this.getName().matches("RtlDeleteRegistryValue") or
    this.getName().matches("RtlWriteRegistryValue") or
    this.getName().matches("RtlQueryRegistryValues") or
    this.getName().matches("RtlxQueryRegistryValues") or
    this.getName().matches("RtlQueryRegistryValuesEx")
  }
}

class ZwRegistryIsolationFunction extends Function {
  ZwRegistryIsolationFunction() {
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
    this.getName().matches("ZwQueryValueKey")
  }
}

class RegistryIsolationFunction extends Function {
  RegistryIsolationFunction() {
    this instanceof RtlRegistryIsolationFunction or
    this instanceof ZwRegistryIsolationFunction
  }
}

class RegistryIsolationFunctionCall extends FunctionCall {
  RegistryIsolationFunctionCall() { this.getTarget() instanceof RegistryIsolationFunction }
}

class NullRootDirectoryObjAttr extends VariableAccess {
  NullRootDirectoryObjAttr() {
    exists(FieldAccess fa, VariableAccess va |
      fa.getTarget().getName().matches("RootDirectory") and
      va.getType().toString().matches("OBJECT_ATTRIBUTES") and // TODO need wild cards?
      va.getParent+() = fa.getParent+() and
      exists(Expr assignedValue |
        assignedValue = fa.getTarget().getAnAssignedValue() and
        assignedValue.getParent+() = va.getParent+() and
        assignedValue.getValue().toString().matches("%") // assignedValue only has a value when it's constant
      ) and
      this = va
    )
  }
}

class NullRootDirectoryNode extends DataFlow::Node {
  NullRootDirectoryNode() {
    exists(FieldAccess fa, VariableAccess va |
      fa.getTarget().getName().matches("RootDirectory") and
      va.getType().toString().matches("OBJECT_ATTRIBUTES") and // TODO need wild cards?
      va.getParent+() = fa.getParent+() and
      exists(Expr assignedValue |
        assignedValue = fa.getTarget().getAnAssignedValue() and
        assignedValue.getParent+() = va.getParent+() and
        assignedValue.getValue().toString().matches("%") // assignedValue only has a value when it's constant
      ) and
      this.asIndirectExpr() = va
    )
  }
}

class NonNullRootDirectoryNode extends DataFlow::Node {
  NonNullRootDirectoryNode() {
    exists(FieldAccess fa, VariableAccess va |
      fa.getTarget().getName().matches("RootDirectory") and
      va.getType().toString().matches("OBJECT_ATTRIBUTES") and // TODO need wild cards?
      va.getParent+() = fa.getParent+() and
      not exists(Expr assignedValue |
        assignedValue = fa.getTarget().getAnAssignedValue() and
        assignedValue.getParent+() = va.getParent+() and
        assignedValue.getValue().toString().matches("%") // assignedValue only has a value when it's constant
      ) and
      this.asIndirectExpr() = va
    )
  }
}

module IsolationDataFlowNullRootDirConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source.asIndirectExpr().getValue().toString().toLowerCase().matches("%")
    //source.asIndirectExpr().getType().toString().toLowerCase().matches("%string%") //potential violations
  }

  // barrier prevents flow from source to source
  predicate isBarrierIn(DataFlow::Node node) {
    isSource(node) or node instanceof NonNullRootDirectoryNode
  }

  predicate isAdditionalFlowStep(DataFlow::Node pred, DataFlow::Node succ) {
    // flow between input/output of string functions
    exists(Expr va0, Expr va1, FunctionCall fc |
      (
        fc.getTarget().getName().matches("RtlInitUnicodeString") or
        fc.getTarget().getName().matches("RtlUnicodeStringInit") or
        fc.getTarget().getName().matches("RtlInitString") or
        fc.getTarget().getName().matches("RtlAnsiStringToUnicodeString") or
        fc.getTarget().getName().matches("RtlStringCchPrintf%")
      ) and
      va0 = fc.getArgument(0) and // output of the above functions is the first argument
      va1 = fc.getAnArgument() and
      va0 != va1 and
      pred.asIndirectExpr() = va1 and
      succ.asIndirectExpr() = va0
    )
    or
    // flow between parameters of InitializeObjectAttributes macro
    exists(FieldAccess fa, VariableAccess va, Expr assignedValue, MacroInvocation m |
      fa.getTarget().getName().matches("ObjectName") and
      va.getType().toString().matches("%OBJECT_ATTRIBUTES%") and
      va.getParent*() = fa.getParent*() and
      assignedValue = fa.getTarget().getAnAssignedValue() and
      assignedValue.getParent*() = va.getParent*() and
      pred.asIndirectExpr() = assignedValue and
      pred.asIndirectExpr().isAffectedByMacro() and
      succ.asIndirectExpr().isAffectedByMacro() and
      m.getAnAffectedElement() = succ.asIndirectExpr() and
      m.getAnAffectedElement() = pred.asIndirectExpr()
    ) and
    succ instanceof NullRootDirectoryNode
  }

  /*
   * Allows tracking flow from UNICODE_STRING.Buffer to OBJECT_ATTRIBUTES.RootDirectory as in example below
   *  KeyName.Buffer = SOME_CONSTANT;
   *  InitializeObjectAttributes(&ObjectAttributes,&KeyName,OBJ_CASE_INSENSITIVE,NULL,NULL);
   */

  predicate allowImplicitRead(DataFlow::Node n, DataFlow::ContentSet cs) {
    isAdditionalFlowStep(n, any(DataFlow::Node succ)) and
    cs.getAReadContent().(DataFlow::FieldContent).getField().hasName(["Buffer"])
  }

  predicate isSink(DataFlow::Node sink) {
    exists(FunctionCall f |
      zwCall(f) and
      sink.asIndirectExpr() = f.getAnArgument() and
      sink.asIndirectExpr()
          .(VariableAccess)
          .getTarget()
          .getType()
          .toString()
          .matches("%OBJECT_ATTRIBUTES%")
    )
  }
}

module IsolationDataFlowNullRootDir = DataFlow::Global<IsolationDataFlowNullRootDirConfig>;

class AllowedHandleRegFuncCall extends RegistryIsolationFunctionCall {
  AllowedHandleRegFuncCall() {
    exists(DataFlow::Node source, DataFlow::Node sink |
      IsolationDataFlowNullRootDir::flow(source, sink) and
      (
        allowedPath(source.asIndirectExpr()) and
        zwRead(this)
        or
        // null RootDirectory, valid ObjectName, read is allowed
        pathWriteException(source.asIndirectExpr()) and
        zwWrite(this)
      ) and
      sink.asIndirectExpr().getParent*() = this
    )
  }
}

class NotAllowedHandleRegFuncCall extends RegistryIsolationFunctionCall {
  NotAllowedHandleRegFuncCall() {
    exists(DataFlow::Node source, DataFlow::Node sink |
      IsolationDataFlowNullRootDir::flow(source, sink) and
      (
        // violation if RootDirectory=NULL and writes, even if ObjectName is valid. (Reads are OK)
        allowedPath(source.asIndirectExpr()) and
        not pathWriteException(source.asIndirectExpr()) and // this path allowed for now
        zwWrite(this) // null RootDirectory, valid ObjectName, write
        or
        // All other paths are violations for both read and write
        not allowedPath(source.asIndirectExpr()) and
        zwCall(this) // null RootDirectory, invalid ObjectName
      ) and
      sink.asIndirectArgument().getParent*() = this
    )
  }
}

class AllowedHandleDDI extends Function {
  AllowedHandleDDI() {
    this.getName().matches("IoOpenDeviceRegistryKey") or
    this.getName().matches("IoOpenDeviceInterfaceRegistryKey") or
    this.getName().matches("IoOpenDriverRegistryKey") or
    this.getName().matches("WdfDriverOpenParametersRegistryKey") or
    this.getName().matches("WdfDriverOpenPersistentStateRegistryKey") or
    this.getName().matches("WdfDeviceOpenRegistryKey") or
    this.getName().matches("WdfFdoInitOpenRegistryKey") or
    this.getName().matches("CM_Open_DevNode_Key")
  }
}

/*
 * Call to a Zw* registry function that reads only
 */

predicate zwRead(RegistryIsolationFunctionCall f) {
  (
    f.getTarget().getName().matches("ZwQueryKey") or
    f.getTarget().getName().matches("ZwQueryValueKey")
  )
  or
  f.getTarget().getName().matches("Zw%") and
  f.getAnArgument().getType().toString().matches("ACCESS_MASK") and
  exists(MacroInvocation m |
    f.getAnArgument() = m.getExpr() and
    (
      m.getMacroName().matches("KEY_QUERY_VALUE") or
      m.getMacroName().matches("KEY_ENUMERATE_SUB_KEYS") or
      m.getMacroName().matches("KEY_CREATE_LINK") or
      m.getMacroName().matches("KEY_NOTIFY") or
      m.getMacroName().matches("KEY_READ") or
      m.getMacroName().matches("KEY_EXECUTE")
    )
  )
  or
  f.getTarget().getName().matches("Zw%") and
  exists(Expr e, int n |
    e = f.getArgument(n) and
    (
      e.getValue() = "131097" or // KEY_READ and KEY_EXECUTE
      e.getValue() = "1" or // KEY_QUERY_VALUE
      e.getValue() = "8" or // KEY_ENUMERATE_SUB_KEYS
      e.getValue() = "32" or // KEY_CREATE_LINK
      e.getValue() = "16" // KEY_NOTIFY
    ) and
    n = 1
  )
}

/*
 * Call to a Zw* registry function that writes
 */

predicate zwWrite(RegistryIsolationFunctionCall f) {
  (
    f.getTarget().getName().matches("ZwDeleteKey") or
    f.getTarget().getName().matches("ZwDeleteValueKey") or
    f.getTarget().getName().matches("ZwSetValueKey")
  )
  or
  f.getTarget().getName().matches("Zw%") and
  not zwRead(f)
}

/*
 * Any call to a Zw* registry function that reads only
 */

predicate zwCall(RegistryIsolationFunctionCall f) {
  zwRead(f)
  or
  zwWrite(f)
}

// Exceptions to rules
predicate exception2(RegistryIsolationFunctionCall f) {
  // Exception: Rtl Writes OK if key is named SERIALCOMM or SERIALCOMM\* and RelativeTo parameter is RTL_REGISTRY_DEVICEMAP
  f.getArgument(1).getValue().toString().toLowerCase().matches("serialcomm") or
  f.getArgument(1).getValue().toString().toLowerCase().matches("serialcomm\\%")
}

predicate pathWriteException(Expr n1) {
  // Exception: zwWrite OK with this path
  n1.getValue()
      .toString()
      .toLowerCase()
      .matches("\\registry\\machine\\hardware\\devicemap\\serialcomm%")
}

predicate pathException(Expr e) {
  e.getValue().toString().toLowerCase().matches("%registry\\machine\\software%") or
  e.getValue().toString().toLowerCase().matches("%registry\\machine\\system%")
}

predicate allowedPath(Expr e) {
  e.getValue().toString().toLowerCase().matches("%registry%machine%hardware%") or
  pathException(e)
}
