// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
import cpp

//Represents functions where a function has either PAGED_CODE or PAGED_CODE_LOCKED macro invocations
cached
class PagedFunc extends Function {
  cached
  PagedFunc() {
    exists(MacroInvocation mi |
      mi.getEnclosingFunction() = this and
      mi.getMacroName() = ["PAGED_CODE", "PAGED_CODE_LOCKED"]
    )
  }
}

//Represents code_seg("PAGE") pragma
class CodeSegPragma extends PreprocessorPragma {
  CodeSegPragma() { this.getHead().matches("code\\_seg(\"PAGE\")") }
}

//Represents a code_seg() pragma
class DefaultCodeSegPragma extends PreprocessorPragma {
  DefaultCodeSegPragma() {
    this.getHead().matches("code\\_seg()")
    or
    this.getHead().matches("code\\_seg(\"INIT\")")
  }
}

//Represents alloc_text pragma
class AllocSegPragma extends PreprocessorPragma {
  AllocSegPragma() {
    this.getHead().matches("alloc\\_text%(%PAGE%") or
    this.getHead().matches("NDIS\\_PAGEABLE\\_FUNCTION%") or
    this.getHead().matches("NDIS\\_PAGABLE\\_FUNCTION%")
  }
}

//Evaluates to true if a PagedFunc was placed in a PAGE section using alloc_text pragma
predicate isAllocUsedToLocatePagedFunc(Function pf) {
  exists(AllocSegPragma asp |
    asp.getHead().matches("%" + pf.getName() + [" )", ")"]) and
    asp.getFile() = pf.getFile()
  )
}

//Evaluates to true if there is Macro Invocation above PagedFunc which expands to code_seg("PAGE")
predicate isPagedSegSetWithMacroAbove(Function f) {
  exists(MacroInvocation ma |
    ma.getMacro().getBody().matches("%code\\_seg(\"PAGE\")%") and
    ma.getLocation().getStartLine() <= f.getLocation().getStartLine() and
    f.getAnAttribute().getName() = "code_seg" and
    ma.getFile() = f.getFile()
  )
}

//Represents functions for whom code_seg() is set
cached
class Resett extends Function {
  DefaultCodeSegPragma dcs;

  cached
  Resett() {
    exists(CodeSegPragma csp, DefaultCodeSegPragma dcsp |
      this.getLocation().getStartLine() > csp.getLocation().getStartLine() and
      dcsp.getFile() = csp.getFile() and
      this.getFile() = csp.getFile() and
      dcsp.getLocation().getStartLine() < this.getLocation().getStartLine() and
      dcs = dcsp
    )
  }

  cached
  DefaultCodeSegPragma getCodeSeg() { result = dcs }
}

//Represents functions for whom code_seg("PAGE") is set
cached
class Sett extends Function {
  cached
  Sett() {
    exists(CodeSegPragma csp |
      this.getLocation().getStartLine() > csp.getLocation().getStartLine() and
      this.getFile() = csp.getFile() and
      not exists(Resett rf |
        rf.getFile() = csp.getFile() and
        rf = this and
        rf.getCodeSeg().getLocation().getStartLine() > csp.getLocation().getStartLine()
      )
    )
  }
}

//Represents a paged section
cached
class PagedFunctionDeclaration extends Function {
  cached
  PagedFunctionDeclaration() {
    isPagedSegSetWithMacroAbove(this)
    or
    this instanceof Sett
    or
    isAllocUsedToLocatePagedFunc(this)
  }
}
