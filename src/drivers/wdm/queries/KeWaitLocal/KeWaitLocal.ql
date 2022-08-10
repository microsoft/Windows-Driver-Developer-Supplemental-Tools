/**
 * @name KeWaitLocal
 * @kind problem
 * @description If the first argument to KeWaitForSingleObject is a local variable, the Mode parameter must be KernelMode
 * @problem.severity warning
 * @id cpp/portedqueries/ke-wait-local
 * @version 1.0
 */

import cpp

//Represents KeWaitForSingleObject calls where AccessMode is NOT KernelMode
class KeWaitForSingleObjectCall extends FunctionCall {
    KeWaitForSingleObjectCall() {
      getTarget().getName() = "KeWaitForSingleObject" 
      //the 0 below is enum value for KernelMode
      and not getArgument(2).getValue().toInt() = 0
    }
  }
  
  //This class is represents all local variable definitions
  //It represents both function parameters and definitions inside a block
  class MLocalVariable extends Variable {
    MLocalVariable() { this instanceof LocalVariable }
  }
  
  from VariableAccess va, MLocalVariable mlv, KeWaitForSingleObjectCall kwso
  where
    va.getTarget() = mlv and 
    va.getParent().getEnclosingElement() = kwso
  select va,
    "KeWaitForSingleObject should have a KernelMode AccessMode when the first argument is local"
  
