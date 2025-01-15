// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/driver-isolation-zw-violation-2
 * @kind problem
 * @name Driver Isolation Zw Violation 2
 * @description Driver isolation violation if there is a Zw* registry function call with OBJECT_ATTRIBUTES parameter passed to it with
 *  RootDirectory=NULL and invalid OBJECT_ATTRIBUTES->ObjectName, or RootDirectory=NULL and valid OBJECT_ATTRIBUTES->ObjectName but with write access.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-D0010
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */

import drivers.libraries.DriverIsolation

/*
 * InitializeObjectAttributes: For second param (PUNICODE_STRING), if fully qualified object name passed, then RootDirectory is NULL.
 * If relative path name to the object directory specified by RootDirectory (not null)
 */

/*
 * OBJECT_ATTRIBUTES->RootDirectory is NULL
 */

from RegistryIsolationFunctionCall f, DataFlow::Node source, DataFlow::Node sink, string message
where
  IsolationDataFlowNullRootDir::flow(source, sink) and
  (
    // violation if RootDirectory=NULL and writes, even if ObjectName is valid. (Reads are OK)
    allowedPath(source.asIndirectExpr()) and
    not pathWriteException(source.asIndirectExpr()) and // this path allowed for now
    zwWrite(f) and // null RootDirectory, valid ObjectName, write
    message =
      f.getTarget().toString() +
        " call has parameter of type OBJECT_ATTRIBUTES with NULL RootDirectory field uses a valid path $@ for ObjectName field, "
        + "but is a Driver Isolation Violation due to having write access "
    or
    // All other paths are violations for both read and write
    not allowedPath(source.asIndirectExpr()) and
    zwCall(f) and // null RootDirectory, invalid ObjectName
    message =
      f.getTarget().toString() +
        " call has parameter of type OBJECT_ATTRIBUTES with NULL RootDirectory field uses an invalid path $@ for ObjectName field "
  ) and
  sink.asIndirectArgument().getParent*() = f
select f, message, source, source.asIndirectExpr().toString()
