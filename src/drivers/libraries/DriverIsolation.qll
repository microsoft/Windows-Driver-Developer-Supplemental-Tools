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
predicate exception1(Expr n1) {
  // Exception: zwWrite OK with this path
  n1.getValue()
      .toString()
      .toLowerCase()
      .matches("\\registry\\machine\\hardware\\devicemap\\serialcomm%")
  or
  n1.getValue().toString().toLowerCase().matches("\\registry\\machine\\system%")
  or
  n1.getValue().toString().toLowerCase().matches("\\registry\\machine\\software%")
}

predicate exception2(RegistryIsolationFunctionCall f) {
  // Exception: Rtl Writes OK if key is named SERIALCOMM and RelativeTo parameter is RTL_REGISTRY_DEVICEMAP
  f.getArgument(1).getValue().toString().toLowerCase().matches("serialcomm")
}
