// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irp-stack-entry-copy
 * @name Unicode String Not Freed
 * @description C28114: Copying a whole IRP stack entry leaves certain fields initialized that should be cleared or updated.
 * @platform Desktop
 * @security.severity Medium
 * @feature.area Multiple
 * @impact Exploitable Design
 * @repro.text
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-D0006
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */

import cpp

class PIO_STACK_LOCATION extends TypedefType {
  PIO_STACK_LOCATION() {
    this instanceof TypedefType and
    this.getName() = "PIO_STACK_LOCATION"
  }
}

from FunctionCall mem_copy_func, Expr io_stack_param, string size
where
  (
    mem_copy_func.getTarget().getName() = "RtlMoveMemory" or
    mem_copy_func.getTarget().getName() = "RtlCopyMemory" or
    mem_copy_func.getTarget().getName() = "RtlCopyBytes" or
    mem_copy_func.getTarget().getName() = "RtlCopyMemory32" or
    mem_copy_func.getTarget().getName() = "memmove" or
    mem_copy_func.getTarget().getName() = "memcpy"
  ) and
  // All of these memory copy functions have source as the second parameter and size as the third parameter
  io_stack_param = mem_copy_func.getArgument(1) and
  io_stack_param.getType() instanceof PIO_STACK_LOCATION and
  size = mem_copy_func.getArgument(2).getValue() and
  size = "36" // Size of the IRP stack entry in bytes in decimal form. (0x24 hex)
select mem_copy_func, "Possible copy of a whole IRP stack entry $@ at $@", io_stack_param,
  io_stack_param.toString(), mem_copy_func, mem_copy_func.toString()
