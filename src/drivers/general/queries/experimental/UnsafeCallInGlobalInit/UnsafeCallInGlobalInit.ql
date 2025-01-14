// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/unsafe-call-in-global-init
 * @kind problem
 * @name TODO
 * @description When using a DLL, it is frequently the case that any
 *  static construtors are called from DllMain.
 *  There are a number of constraints that apply to calling
 *  other functions from DllMain.  In particular, it is
 *  possible to create memory leaks if the DLL is loaded
 *  and unloaded dynamically.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28637
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.libraries.DriverIsolation

from Function f, string msg
where
  f.getName().matches("DllMain") and
  exists(FunctionCall fc |
    fc.getEnclosingFunction() = f and
    (
      fc.getTarget()
          .getName()
          .matches([
              "LoadLibrary", "LoadLibraryEx", "GetStringTypeA", "GetStringTypeEx", "GetStringTypeW",
              "CoInitializeEx", "CreateProcess", "ExitThread", "CreateThread", "ShGetFolderPathW"
            ]) or
      fc instanceof RegistryIsolationFunctionCall
    ) and
    msg = "Unsafe call in DllMain."
  )
  or
  exists(Initializer i |
    f.getName().matches("DllMain") and
    i.getExpr().getEnclosingFunction() = f and
    not i.getDeclaration().isStatic() and
    i.getExpr().toString().toLowerCase().matches("null") and
    msg = "Potential unsafe initialization in DllMain."
  )
select f, msg + " Review Dynamic-Link Library Best Practices."
