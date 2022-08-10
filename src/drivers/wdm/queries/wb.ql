/**
 * @name template
 * @kind problem
 * @description template
 * @problem.severity warning
 * @id cpp/portedqueries/template
 */

import cpp
import Windows.wdk.wdm.WdmDrivers

from DispatchRoutineAssignment da
select da, da.getTarget().getName()

// from FunctionAccess fa
// where fa.getTarget() instanceof WdmDriverEntry
// select fa, fa.getTarget().getName()

// from WdmDriverEntry wde
// select wde, wde.getLocation().getStartLine().toString()

// from Function f where f.getName() = "DriverEntry"
// select f, ""
