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
 * A `PAGED_CODE` or `PAGED_CODE_LOCKED` macro invocation that sits inside
 * a `PagedFunctionDeclaration`. Pre-filtering the population at the class
 * level (rather than as joined `where`-clause predicates) lets the optimizer
 * materialize a small relation and avoid the full
 * `MacroInvocation x MacroInvocation` Cartesian product on large corpora.
 */
class PagedCodeMacro extends MacroInvocation {
  PagedCodeMacro() {
    this.getMacroName() = ["PAGED_CODE", "PAGED_CODE_LOCKED"]
  }

  /**
   * Gets a paged enclosing function for this macro invocation, including
   * `FunctionTemplateInstantiation` results when the macro lives inside a
   * templated function body. Each instantiation is a distinct `Function`,
   * so two `PagedCodeMacro` invocations are guaranteed to "share" one of
   * these results only when they are inside the same instantiation body
   * (not merely two ODR-equivalent template entities that the extractor
   * may consolidate).
   *
   * Routed through `getStmt()` rather than the stock
   * `MacroInvocation.getEnclosingFunction()` to avoid the expensive
   * `getAnAffectedElement` join on large codebases. `PAGED_CODE` /
   * `PAGED_CODE_LOCKED` always expand to a statement-form
   * `NT_ASSERT_ASSUME(...)`, so `getStmt()` is well-defined.
   *
   * NB: callers that need to compare two macro invocations for "same
   * source-level function" must also require the macros and the
   * enclosing function to agree on `getFile()`. The cpp extractor
   * sometimes consolidates two ODR-equivalent template definitions in
   * different headers into a single `TemplateFunction` /
   * `FunctionTemplateInstantiation` entity, which would otherwise allow
   * a macro in one header to match an enclosing function in another.
   */
  Function getEnclosingPagedFunction() {
    result = this.getStmt().getEnclosingFunction() and
    result instanceof PagedFunctionDeclaration
  }
}
