/**
* @id cpp/likely-bugs/memory-management/v2/conditionally-uninitialized-variable
* @name Conditionally uninitialized variable
* @description When an initialization function is used to initialize a local variable,
*              but the returned status code is not checked, reading the variable may
*              result in undefined behaviour.
* @platform Desktop
* @security.severity Low
* @impact Insecure Coding Practice
* @feature.area Multiple 
* @repro.text The following code locations potentially contain uninitialized variables
* @owner.email pabrooke@microsoft.com
* @kind problem
* @problem.severity error
* @query-version 2.0
**/

import cpp
private import UninitializedVariables

from ConditionallyInitializedVariable v, ConditionalInitializationFunction f, ConditionalInitializationCall call, Evidence e
where exists(v.getARiskyAccess(f, call, e))
  and e = DefinitionInSnapshot()
select call, "$@: The status of this call to $@ is not checked, potentially leaving $@ uninitialized.",
    call.getEnclosingFunction(),
    call.getEnclosingFunction().toString(),
	f, f.getName(),
	v, v.getName()
