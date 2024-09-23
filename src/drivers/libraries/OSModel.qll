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