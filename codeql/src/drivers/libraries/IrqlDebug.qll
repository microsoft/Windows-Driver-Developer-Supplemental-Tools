import cpp
import drivers.libraries.Irql

/**
 * A debugging function used to print the rationale for why a given CFN has the IRQL value it does.
 */

string getIrqlDebugInfoAtCfn(ControlFlowNode cfn) {
  if cfn instanceof KeRaiseIrqlCall
  then result = "This is a KeRaiseIRQL call"
  else
    if cfn instanceof KeLowerIrqlCall
    then result = "This is a KeLowerIRQL call"
    else
      if cfn instanceof RestoresGlobalIrqlCall
      then result = "This is a RestoresGlobalIrqlCall"
      else
        if cfn instanceof IrqlRestoreCall
        then result = "This is an IrqlRestoreCall"
        else
          if
            cfn instanceof FunctionCall and
            cfn.(FunctionCall).getTarget() instanceof IrqlRaisesAnnotatedFunction
          then result = "This is a function call, and the target is annotated _irql_raises_"
          else
            if
              cfn instanceof FunctionCall and
              cfn.(FunctionCall).getTarget() instanceof IrqlRequiresSameAnnotatedFunction
            then result = "This is a function call, and the target is annotated _irql_same_"
            else
              if cfn instanceof FunctionCall
              then result = "This is a function call, and we took the result exiting the function"
              else
                if exists(ControlFlowNode cfn2 | cfn2 = cfn.getAPredecessor())
                then result = "This is the IRQL from the prior CFN in this function"
                else
                  if
                    exists(FunctionCall fc, ControlFlowNode cfn2 |
                      fc.getTarget() = cfn.getControlFlowScope() and
                      cfn2.getASuccessor() = fc
                    )
                  then
                    result =
                      "There is no preceding node.  This is the IRQL from a function call to this function. Calilng function: "
                        +
                        any(string s |
                          exists(ControlFlowNode call |
                            call.getASuccessor().(FunctionCall).getTarget() =
                              cfn.getControlFlowScope() and
                            s =
                              " (" + call.getControlFlowScope().getName() + ": " +
                                call.getControlFlowScope().getFile().getBaseName() + ") "
                          )
                        )
                  else
                    if
                      cfn.getControlFlowScope() instanceof IrqlRestrictsFunction and
                      getAllowableIrqlLevel(cfn.getControlFlowScope()) != -1
                    then
                      result =
                        "This function has no callers but is annotated to have IRQL restrictions on it, so we use those restrictions"
                    else result = "We could not find any usable IRQL info"
}
