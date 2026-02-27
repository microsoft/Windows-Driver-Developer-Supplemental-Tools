/**
 * @name User provided pointer dereferenced without a probe.
 * @description If a user provided pointer is dereferenced without first being
 *              probed, it could point to kernel mode memory, opening up a
 *              serious security hole
 * @kind problem
 * @problem.severity error
 * @tags security
 *       external/cwe/cwe-668
 * @id cpp/microsoft/public/likely-bugs/memory-management/unprobeddereference
 */
import microsoft.code.cpp.windows.kernel.SystemCalls
import microsoft.code.cpp.windows.kernel.MemoryOriginDereferences
import microsoft.code.cpp.controlflow.Reachability

/**
 * A dereferencing access that should be ignored because it is either within a probe call, or is
 * preceded by one.
 */
class ProbedAccess extends IgnoredAccess {
	ProbedAccess() {
		exists(ProbeCallAccess probeAccess | probeAccess = this.getTarget().getAnAccess() and reaches(probeAccess, this)) or
		this instanceof ProbeCallAccess
	}
}

/**
 * A dereferencing access that should be ignored because it is either within a UMA call, or
 * preceded by one.
 */
class UMAGuardedAccess extends IgnoredAccess {
	UMAGuardedAccess() {
		exists(UMAAccess umaAccess | umaAccess = this.getTarget().getAnAccess() and reaches(umaAccess, this)) or
		this instanceof UMAAccess
	}
}

from MemoryOrigin o, VariableAccess va
where o.originCanUnmap() and
  va = getANestedDereference(o) and
	// And the dereferencing expression is not contained in an undefined call
	(va.getParent() instanceof Call implies va.getParent().(Call).getTarget().hasDefinition())
select va, "Variable dereferenced without probe accessing $@", o, o.toString()
