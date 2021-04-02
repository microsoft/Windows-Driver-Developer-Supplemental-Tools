// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

/**
 * @name Possible information leakage from uninitialized padding bytes.
 * @description A newly allocated struct or class that is initialized member-by-member may
 *              leak information if it includes padding bytes.
 * @kind problem
 * @problem.severity warning
 * @tags security
 *       external/cwe/cwe-200
 * @opaque-id SM02320
 * @microsoft.severity Important
 * @id cpp/paddingbyteinformationdisclosure
 */

import cpp
import microsoft.code.cpp.commons.MemoryAllocation
import semmle.code.cpp.padding.Padding

/**
 * A type which contains wasted space on one or more architectures.
 */
class WastedSpaceType extends PaddedType {
	WastedSpaceType() {
		// At least some wasted space
		(
			any(Architecture arch).wastedSpace(this.getUnspecifiedType()) > 0 or
			exists(Field f | f.getDeclaringType() = this and f.getType().getUnspecifiedType() instanceof WastedSpaceType)
		) and
		/*
		 * Assert that all members are declared in the same file, to avoid structs
		 * with linker-confused members.
		 */
		exists(File file |
			getFile() = file and
			forall(MemberVariable v | getAMember() = v | v.getLocation().getFile() = file)
		)
	}
}

/** Holds if there exists some padding between the first and second elements. */
predicate hasInitialPadding(PaddedType pt) {
	exists(Field firstField |
		pt.(Struct).getAMember(0) = firstField |
		// We want to see if the first non-struct field has alignment padding after it
		if firstField.getType().getUnderlyingType() instanceof Struct then
			// First field is a struct, consider padding within this struct
			hasInitialPadding(firstField.getType().getUnspecifiedType())
		else
			/*
			 * Look at the second field, and see how much waste there is between the first and second
			 * fields.
			 */
			exists(Field secondField, Architecture arch |
				not exists(pt.getABaseClass()) and
				/*
				 * There is padding between the first two fields if the second fields
				 * ends at a larger offset than where it would end if it came right
				 * after the first field.
				 */
				pt.fieldIndex(secondField) = 2 and
				pt.fieldEnd(2, arch) > pt.fieldEnd(1, arch) + pt.fieldSize(secondField, arch)
			)
	)
}

/** A buffer that is potentially leaked. */
abstract class LeakedBuffer extends Expr { }

/** An allocation that potentially escapes the enclosing function. */
class EscapingAllocation extends LeakedBuffer {
  EscapingAllocation() {
    this instanceof Allocation
    and
    (
      this instanceof StackAllocation implies
      exists(VariableAccess va |
        va = this.(StackAllocation).getAllocationVariable().getAnAccess() |
        // Returned directly
        exists(ReturnStmt ret | ret.getExpr() = va) or
        /*
         * Calls to the ProbeAndWrite functions - and variants - write data to user mode memory, which
         * can escape the current context.
         */
        exists(FunctionCall fc |
          fc.getTarget().getName().matches("%Probe%Write%") |
          fc.getArgument(1) = va) or
        /*
         * Calls to VmbChannelPacketComplete functions which write data to shared guest memory.
         */
        exists(FunctionCall fc |
          fc.getTarget().hasName("VmbChannelPacketComplete") |
          fc.getArgument(1).(AddressOfExpr).getAnOperand() = va)
      )
    )
  }
}

from LeakedBuffer buf, Variable v, WastedSpaceType wst
where v.getAnAssignedValue() = buf
  // On at least one architecture, there is some wasted space in the form of padding
  and v.getType().stripType() = wst
  // The variable is never the target of a memset/memcpy
  and not v.getAnAccess() =
      any(Call c | c.getTarget().getName().regexpMatch("mem(set|cpy)")).getArgument(0)
  // The variable is never freed
  and not v.getAnAccess() =
      any(Call c | c.getTarget().getName().regexpMatch("ExFree.*")).getArgument(0)
  // Ignore stack variables assigned aggregate literals which zero the allocated memory
  and not exists(AggregateLiteral al |
                  v.getAnAssignedValue() = al |
                  // = {}, which zeroes all bytes. Identified by the fact the aggregate has no children
                  not exists(al.getAChild()) or
                  /*
                   * = {0} which zeroes all the bytes except the padding between field 0 and field 1 (on the MS compiler)
                   */
                  (
                  	al.getNumChild() = 1 and
                  	// Looking for the child at depth 1 or depth 2, to have the value 0
                  	(al.getAChild().getValue() = "0" or al.getAChild().getAChild().getValue() = "0") and
                  	not hasInitialPadding(wst))
                 )
select buf, "Memory allocation of $@ includes uninitialized padding bytes.", wst, wst.toString()
