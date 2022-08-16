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

//Evaluates to true if there is Macro Invocation above PagedFunc which expands to code_seg("PAGE")
predicate isPagedSegSetWithMacroAbove(Function f) {
  exists(MacroInvocation ma |
    ma.getMacro().getBody().matches("%code\\_seg(\"PAGE\")%") and
    ma.getLocation().getStartLine() <= f.getLocation().getStartLine() and
    f.getAnAttribute().getName() = "code_seg" and
    ma.getFile() = f.getFile()
  )
}

cached
class PageCodeSetFunctions extends Function {
  cached
  PageCodeSetFunctions() { codeSegStatus(this) = 1 }
}

//Identifies if there is a pragma for code_seg("PAGE") or code_seg()
int codeSegStatus(Function f) {
  if
    exists(CodeSegPragma csp, DefaultCodeSegPragma dcsp |
      f.getLocation().getStartLine() > csp.getLocation().getStartLine() and
      f.getFile() = csp.getFile() and
      dcsp.getFile() = f.getFile() and
      dcsp.getLocation().getStartLine() < f.getLocation().getStartLine()
    )
  then result = 2 //exists #pragma code_seg(), aka, reset
  else
    if
      exists(CodeSegPragma csp |
        f.getLocation().getStartLine() > csp.getLocation().getStartLine() and
        f.getFile() = csp.getFile()
      )
    then result = 1 //exists #pragma code_seg("PAGE"), aka, set
    else result = 0 //no code_seg prama for the function
}

//Represents a paged section
cached
class PagedFunctionDeclaration extends Function {
  cached
  PagedFunctionDeclaration() {
    isPagedSegSetWithMacroAbove(this)
    or
    codeSegStatus(this) = 1
    or
    isAllocUsedToLocatePagedFunc(this)
  }
}
