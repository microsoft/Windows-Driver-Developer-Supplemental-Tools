import cpp
import RoleTypes
/*
Functions called by the OS and not directly from the driver code
*/
class OsCalledFunction extends Function {
    OsCalledFunction() {
        this.getName().matches("OsCalledFunction")
        or
        this instanceof RoleTypeFunction
    }
}

class OSFunctionCallEdges extends AdditionalControlFlowEdge {
    OSFunctionCallEdges() { exists(OsCalledFunction f | mkElement(this) = f.getControlFlowScope()) }
  
    override ControlFlowNode getAnEdgeTarget() {
      exists(OsCalledFunction f |
        result = f.getEntryPoint() and
        not f.getControlFlowScope() = mkElement(this) and 
        not f.getName().matches("DriverEntry") and // driver entry called first, so don't want it to be a target of an edge
        not f instanceof WdmAddDevice // Add called first, so don't want it to be a target of an edge
      )
    }
  }

  