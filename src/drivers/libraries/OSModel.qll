import cpp
import RoleTypes

/*
 * Functions called by the OS and not directly from the driver code
 */

class OsCalledFunction extends Function {
  OsCalledFunction() {
    this.getName().matches("OsCalledFunction") //?
    or
    this instanceof RoleTypeFunction
  }
}

/*
 * Flow allowed from DriverEntry to AddDevice
 */

class OSFunctionCallEdgesDriverEntry extends AdditionalControlFlowEdge {
  OSFunctionCallEdgesDriverEntry() {
    exists(OsCalledFunction f | mkElement(this) = f.getControlFlowScope() |
      f.getName().matches("DriverEntry")
    )
  }

  override ControlFlowNode getAnEdgeTarget() {
    exists(OsCalledFunction f |
      result = f.getEntryPoint() and
      not f.getControlFlowScope() = mkElement(this) and
      f instanceof WdmAddDevice
    )
  }
}

/*
 * Flow allowed from AddDevice to dipatch routines
 */

class OSFunctionCallEdgesAddDevice extends AdditionalControlFlowEdge {
  OSFunctionCallEdgesAddDevice() {
    exists(OsCalledFunction f |
      mkElement(this) = f.getControlFlowScope() and
      f instanceof WdmAddDevice
    )
  }

  override ControlFlowNode getAnEdgeTarget() {
    exists(OsCalledFunction f |
      result = f.getEntryPoint() and
      not f.getControlFlowScope() = mkElement(this) and
      f instanceof WdmDriverDispatch
    )
  }
}

/*
 * Flow allowed from Dispatch to CompletionRoutine
 */

class OSFunctionCallEdgesDispatch extends AdditionalControlFlowEdge {
  OSFunctionCallEdgesDispatch() {
    exists(OsCalledFunction f |
      mkElement(this) = f.getControlFlowScope() and
      f instanceof WdmDriverDispatch
    )
  }

  override ControlFlowNode getAnEdgeTarget() {
    exists(OsCalledFunction f |
      result = f.getEntryPoint() and
      not f.getControlFlowScope() = mkElement(this) and
      f instanceof WdmDriverCompletionRoutine
      // TODO completion routine registered for specific IRP
    )
  }
}

/*
 * Flow allowed from dipatch routine OR AddDevice to DpcForIsr
 */

class OSFunctionCallEdgesDpcForIsr extends AdditionalControlFlowEdge {
  OSFunctionCallEdgesDpcForIsr() {
    exists(OsCalledFunction f |
      mkElement(this) = f.getControlFlowScope() and
      f instanceof WdmDriverDispatch
    )
  }

  override ControlFlowNode getAnEdgeTarget() {
    exists(OsCalledFunction f |
      mkElement(this) = f.getControlFlowScope() and
      f instanceof WdmDriverStartIo and
      result = f.getEntryPoint()
    )
    or
    exists(FunctionCall registerCall, int n |
      registerCall.getTarget().getName() = ["IoInitializeDpcRequest"] and
      registerCall.getArgument(n) instanceof FunctionAccess and
      result = registerCall.getArgument(n).(FunctionAccess).getTarget().getEntryPoint()
    )
  }
}

/*
 * Flow allowed from dipatch routine to StartIo routine
 */

class OSFunctionCallEdgesStartIO extends AdditionalControlFlowEdge {
  OSFunctionCallEdgesStartIO() {
    exists(OsCalledFunction f |
      mkElement(this) = f.getControlFlowScope() and
      f instanceof WdmDriverDispatch
    )
  }

  override ControlFlowNode getAnEdgeTarget() {
    exists(OsCalledFunction f |
      mkElement(this) = f.getControlFlowScope() and
      f instanceof WdmDriverStartIo and
      result = f.getEntryPoint()
    )
  }
}


/*
 * Flow allowed from dispatch routines to driver control functions
 */
//TODO controler not suppoerted for WDM?
class OSFunctionCallEdgesDriverControl extends AdditionalControlFlowEdge {
  OSFunctionCallEdgesDriverControl() {
    exists(OsCalledFunction f |
      mkElement(this) = f.getControlFlowScope() and
      f instanceof WdmDriverDispatch
    )
    or
    // Call might happen right away, so use enclosing function of call that registers the callback
    exists(FunctionCall registerCall |
      registerCall.getTarget().getName() = ["IoAllocateController"] and
      mkElement(this) =
        registerCall.getControlFlowScope() 
    )
  }

  override ControlFlowNode getAnEdgeTarget() {
    exists(FunctionCall registerCall, int n |
      registerCall.getTarget().getName() = ["IoAllocateController"] and
      registerCall.getArgument(n) instanceof FunctionAccess and
      result = registerCall.getArgument(n).(FunctionAccess).getTarget().getEntryPoint()
    )
  }
}

