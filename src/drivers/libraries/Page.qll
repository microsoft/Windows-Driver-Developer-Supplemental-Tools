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
 * `MacroInvocation × MacroInvocation` Cartesian product on large corpora.
 */
class PagedCodeMacro extends MacroInvocation {
  PagedCodeMacro() {
    this.getMacroName() = ["PAGED_CODE", "PAGED_CODE_LOCKED"]
  }

  /**
   * Gets the enclosing `PagedFunctionDeclaration` for this macro invocation,
   * if any. Excludes template instantiations: each function-template
   * instantiation produces its own AST and its own `MacroInvocation` records,
   * with line attribution that may shift by ±1 relative to the source-level
   * `PAGED_CODE()` call. Counting those instantiation-level MIs as separate
   * invocations causes false positives in templated headers. The source-level
   * (uninstantiated) function template still satisfies this predicate, so
   * real duplicate `PAGED_CODE`s in the source are still reported.
   *
   * Performance/correctness note: routed through `getStmt()` (which is built
   * on the cheap `getAnExpandedElement`/`inmacroexpansion` relation) rather
   * than the stock `MacroInvocation.getEnclosingFunction()` which uses
   * `getAnAffectedElement` (a much larger
   * `inmacroexpansion ∪ macrolocationbind` join that scales poorly on large
   * codebases and can cause analysis timeouts). `getStmt()` returns the
   * unique outermost `Stmt` produced by the macro expansion.
   * `PAGED_CODE`/`PAGED_CODE_LOCKED` always expand to a statement-form
   * `NT_ASSERT_ASSUME(...)`, so `getStmt()` is well-defined.
   */
  Function getEnclosingPagedFunction() {
    result = this.getStmt().getEnclosingFunction() and
    result instanceof PagedFunctionDeclaration and
    not result instanceof FunctionTemplateInstantiation
  }
}
