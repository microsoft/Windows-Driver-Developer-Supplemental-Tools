// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/file-functions-driver
 * @kind graph
 * @name file-functions-driver
 * @description file-functions
 * @query-version v1
 */

import cpp
import semmle.code.cpp.pointsto.CallGraph

class FuncOrMacro extends Element {
  FuncOrMacro() {
    (
      this instanceof Function
      or
      this instanceof Macro
    ) and
    (
      this.getLocation().getFile().toString().matches("%h") or
      this.getLocation().getFile().toString().matches("%hpp") or
      this.getLocation().getFile().toString().matches("%c") or
      this.getLocation().getFile().toString().matches("%cpp")
    )
  }

  string getResultName() {
    if this instanceof Macro
    then
      result =
        this.findRootCause().(Macro).getName().toString() + "__macro__" +
          this.(Macro).getName().toString()
    else
      if this instanceof Function
      then result = this.(Function).getADeclarationEntry().toString()
      else result = ""
  }

  string getResultFile() {
    if this instanceof Function
    then result = this.(Function).getADeclarationEntry().getFile().toString()
    else
      if this instanceof Macro
      then result = this.(Macro).getFile().toString()
      else result = ""
  }
}

from FuncOrMacro func
where
  not func.getFile().getAbsolutePath().matches("%Windows Kits%") and
  (
    (
      func.(Function).getADeclarationEntry().getFile().toString().matches("%.h") or
      func.(Function).getADeclarationEntry().getFile().toString().matches("%.cpp") or
      func.(Function).getADeclarationEntry().getFile().toString().matches("%.c") or
      func.(Function).getADeclarationEntry().getFile().toString().matches("%.hpp")
    )
    or
    (
      func.(Macro).getLocation().getFile().toString().matches("%.h") or
      func.(Macro).getLocation().getFile().toString().matches("%.cpp") or
      func.(Macro).getLocation().getFile().toString().matches("%.c") or
      func.(Macro).getLocation().getFile().toString().matches("%.hpp")
    )
  )
select func.getResultFile(), func.getResultName()
