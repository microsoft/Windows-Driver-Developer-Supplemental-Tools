// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
import cpp

//Represents functions where a function has either PAGED_CODE or PAGED_CODE_LOCKED macro invocations
class PagedFunc extends Function {
  PagedFunc() {
    exists(MacroInvocation mi |
      mi.getEnclosingFunction() = this and
      mi.getMacroName() = ["PAGED_CODE", "PAGED_CODE_LOCKED"]
    )
  }
}

//Represents code_seg("PAGE") pragma
class CodeSegPragma extends PreprocessorPragma {
  CodeSegPragma() { this.getHead().matches("code\\_seg%(%\"PAGE\")") }
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
class FunctionWithPageReset extends Function {
  DefaultCodeSegPragma dcs;

  FunctionWithPageReset() {
    exists(CodeSegPragma csp, DefaultCodeSegPragma dcsp |
      this.getLocation().getStartLine() > csp.getLocation().getStartLine() and
      dcsp.getFile() = csp.getFile() and
      this.getFile() = csp.getFile() and
      dcsp.getLocation().getStartLine() < this.getLocation().getStartLine() and
      dcs = dcsp
    )
  }

  DefaultCodeSegPragma getCodeSeg() { result = dcs }
}

//Represents functions for whom code_seg("PAGE") is set
class FunctionWithPageSet extends Function {
  FunctionWithPageSet() {
    exists(CodeSegPragma csp |
      this.getLocation().getStartLine() > csp.getLocation().getStartLine() and
      this.getFile() = csp.getFile() and
      not exists(FunctionWithPageReset rf |
        rf.getFile() = csp.getFile() and
        rf = this and
        rf.getCodeSeg().getLocation().getStartLine() > csp.getLocation().getStartLine()
      )
    )
  }
}

//Represents a paged section
class PagedFunctionDeclaration extends Function {
  PagedFunctionDeclaration() {
    isPagedSegSetWithMacroAbove(this)
    or
    this instanceof FunctionWithPageSet
    or
    isAllocUsedToLocatePagedFunc(this)
  }
}

/**
 * --- AI-generated ---
 *
 * A `PAGED_CODE` or `PAGED_CODE_LOCKED` macro invocation that sits inside
 * a `PagedFunctionDeclaration`. Pre-filtering the population at the class
 * level (rather than as joined `where`-clause predicates) lets the optimizer
 * materialize a small relation and avoid the full
 * `MacroInvocation x MacroInvocation` Cartesian product on large corpora.
 *
 * Routed through `getStmt()` (which always binds for `PAGED_CODE` /
 * `PAGED_CODE_LOCKED`, since they expand to a stmt-form
 * `NT_ASSERT_ASSUME`) to avoid the expensive `getAnAffectedElement`
 * join used by the stock `MacroInvocation.getEnclosingFunction()`.
 */
class PagedCodeMacro extends MacroInvocation {
  PagedCodeMacro() {
    this.getMacroName() = ["PAGED_CODE", "PAGED_CODE_LOCKED"] and
    this.getStmt().getEnclosingFunction() instanceof PagedFunctionDeclaration
  }

  /**
   * --- AI-generated ---
   *
   * Gets the paged enclosing function for this macro invocation,
   * including template instantiations.
   *
   * NB: to compare two `PagedCodeMacro` invocations for "same
   * source-level function", also require `getFile()` agreement —
   * the extractor sometimes consolidates ODR-equivalent template
   * definitions across headers into a single `Function` entity, which
   * would otherwise allow a macro in one header to match an enclosing
   * function in another.
   */
  Function getEnclosingPagedFunction() { result = this.getStmt().getEnclosingFunction() }
}
