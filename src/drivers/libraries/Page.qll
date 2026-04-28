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
   * Gets the source-level enclosing `PagedFunctionDeclaration` for this
   * macro invocation, deduplicating across template instantiations so
   * that each source-level function template body produces a single
   * match key regardless of how many instantiations the extractor
   * produced.
   *
   * Three cases:
   *  - **Non-templated function.** `getStmt().getEnclosingFunction()`
   *    returns a unique non-instantiation `Function`, which is itself
   *    the source-level entity.
   *  - **C++ function template instantiations.** The cpp extractor
   *    populates `getStmt()` with one expanded `Stmt` per instantiation;
   *    each instantiation's enclosing function is a distinct
   *    `FunctionTemplateInstantiation`. We project all of these back
   *    to their underlying `TemplateFunction` via `getTemplate()`, so
   *    a single source-level template collapses to one match key.
   *    `PagedFunctionDeclaration`-ness is checked on the instantiation
   *    (which has a concrete file location for the page-segment
   *    heuristics to work against) rather than on the template entity.
   *  - **Specialisations and non-template-paged functions** are excluded
   *    by the `PagedFunctionDeclaration` requirement.
   *
   * The macro is routed through `getStmt()` rather than the stock
   * `MacroInvocation.getEnclosingFunction()` because the latter is built
   * on `getAnAffectedElement` (an expensive `inmacroexpansion ∪
   * macrolocationbind` join that scales poorly on large codebases).
   * `getStmt()` uses only the cheap `inmacroexpansion` relation.
   * `PAGED_CODE` / `PAGED_CODE_LOCKED` always expand to a statement-form
   * `NT_ASSERT_ASSUME(...)`, so `getStmt()` is well-defined.
   */
  Function getEnclosingPagedFunction() {
    exists(Function rawEnclosing |
      rawEnclosing = this.getStmt().getEnclosingFunction() and
      rawEnclosing instanceof PagedFunctionDeclaration
    |
      not rawEnclosing instanceof FunctionTemplateInstantiation and
      result = rawEnclosing
      or
      rawEnclosing instanceof FunctionTemplateInstantiation and
      result = rawEnclosing.(FunctionTemplateInstantiation).getTemplate()
    )
  }
}
