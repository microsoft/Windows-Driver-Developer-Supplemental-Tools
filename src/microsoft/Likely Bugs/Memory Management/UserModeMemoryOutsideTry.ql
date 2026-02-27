/**
 * @name User mode memory read outside a try block
 * @description Reading user memory outside a try/catch block is discouraged, as
 *              unexpected exceptions can occur if untrusted code changes memory
 *              protections.
 * @kind problem
 * @problem.severity warning
 * @tags security
 *       external/cwe/cwe-755
 * @id cpp/microsoft/public/likely-bugs/memory-management/usermodememoryoutsidetry
 */

import cpp
import microsoft.code.cpp.public.windows.kernel.SystemCalls
import microsoft.code.cpp.public.windows.kernel.MemoryOriginDereferences

/**
 * Ignore dereferencing accesses that occur within Microsoft try-except blocks.
 */
class InsideMicrosoftTry extends IgnoredAccess {
	InsideMicrosoftTry() {
		isInMicrosoftTry(this)
	}
}

from MemoryOrigin o, Expr e
where
  // Memory can be unmapped from user space
  o.originCanUnmap() and
	// e dereferences the pointer p, outside of a try block
	e = getANestedDereference(o) and
	// And the dereferencing expression is not contained in an undefined call
	(e.getParent() instanceof Call implies e.getParent().(Call).getTarget().hasDefinition())
select
	o,"$@: User mode memory dereferenced $@ outside of a try-catch.",  
	e.getEnclosingFunction() as enclosingFunction, enclosingFunction.toString(), e, "here"
