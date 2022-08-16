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
  DefaultCodeSegPragma() { this.getHead().matches("code\\_seg()") }
}

//Represents alloc_text pragma
class AllocSegPragma extends PreprocessorPragma {
  AllocSegPragma() {
    this.getHead().matches("alloc\\_text%PAGE%") or
    this.getHead().matches("NDIS\\_PAGEABLE\\_FUNCTION%") or
    this.getHead().matches("NDIS\\_PAGABLE\\_FUNCTION%")
  }
}

//Evaluates to true if a PagedFunc was placed in a PAGE section using alloc_text pragma
predicate isAllocUsedToLocatePagedFunc(Function pf) {
  exists(AllocSegPragma asp |
    asp.getHead().matches("%" + pf.getName() + ")") and
    asp.getFile() = pf.getFile()
  )
}

cached
class PagedSegMacro extends MacroInvocation {
  cached
  PagedSegMacro() { this.getMacro().getBody().matches("%code\\_seg(\"PAGE\")%") }
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

//Evaluates to true if there is a code_seg("PAGE") pragma above the given PagedFunc
predicate isPageCodeSectionSetAbove(Function f) {
  exists(CodeSegPragma csp, int diff |
    (f.getLocation().getStartLine() - csp.getLocation().getStartLine()) = diff and
    diff < 4 and
    diff > 0 and
    csp.getFile() = f.getFile() and
    not isThereAPageReset(f, csp)
  )
}

//Evaluates to true if there is a code_seg("PAGE") pragma above the given PagedFunc
//Similar to the above, but tweaked a litttle bit as to handle for code_seg usage inconsistencies in codebases.
predicate isPageCodeSectionSetAbove2(Function f) {
  exists(CodeSegPragma csp |
    f.getLocation().getStartLine() > csp.getLocation().getStartLine() and
    f.getFile() = csp.getFile()
  )
}

//Evaluates to true if there's a change to default code segment, with pragma code_seg().
predicate isThereAPageReset(Function f, CodeSegPragma csp) {
  exists(DefaultCodeSegPragma dcsp |
    dcsp.getFile() = f.getFile() and
    dcsp.getLocation().getStartLine() > csp.getLocation().getStartLine()
  )
}

//Represents a paged section
cached
class PagedFunctionDeclaration extends Function {
  cached
  PagedFunctionDeclaration() {
    isPagedSegSetWithMacroAbove(this)
    or
    isPageCodeSectionSetAbove(this)
    or
    isAllocUsedToLocatePagedFunc(this)
  }
}
