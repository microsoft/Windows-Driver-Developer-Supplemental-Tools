/**
 * @name template
 * @kind problem
 * @description template
 * @problem.severity warning
 * @id cpp/portedqueries/template
 */

import cpp
import Windows.wdk.wdm.SAL

class ReturnMustBeCheckedFunction extends Function {
  SALCheckReturn scr;

  ReturnMustBeCheckedFunction() { this.getADeclarationEntry() = scr.getDeclarationEntry() }
}

class ReturnMustBeCheckedFunctionCall extends FunctionCall {
  SALCheckReturn scr;

  ReturnMustBeCheckedFunctionCall() { this.getTarget() instanceof ReturnMustBeCheckedFunction }
}

//AssignExpr sources we want -- assignments where the right value is a call to
//a function whose return value should be checked.
predicate isSource(AssignExpr ae) {
  exists(VariableAccess va, Options ops |
    ae.getLValue() = va and
    ae.getRValue().(FunctionCall).getTarget() instanceof ReturnMustBeCheckedFunction and
    not ops.okToIgnoreReturnValue(ae.getRValue().(FunctionCall)) and
    not ae.getRValue().(FunctionCall).getTarget().getName().matches("%wcsto%")
  )
}

class MustBeCheckedExpr extends AssignExpr {
  private VariableAccess va;

  MustBeCheckedExpr() { isSource(this) }

  VariableAccess getVAccess() { result = this.getLValue() }
}

class ComparedMustChecks extends MustBeCheckedExpr {
  ComparedMustChecks() {
    exists(VariableAccess va_c |
      this.getLocation().getStartLine() < va_c.getLocation().getStartLine() and
      this.getVAccess().getTarget().getName() = va_c.getTarget().getName() and
      (
        va_c.getParent() instanceof ComparisonOperation
        or
        va_c.getEnclosingStmt() instanceof ConditionalStmt
        or
        va_c.getEnclosingStmt() instanceof Loop
      )
      // and
      // not exists(ExprStmt es |
      //   this.getASuccessor*() = es and
      //   va_c.getAPredecessor*() = es and
      //   es.getExpr().(AssignExpr).getLValue().(VariableAccess).getTarget().getName() =
      //     this.getVAccess().getTarget().getName()
      // )
    )
  }

  //for testing
  VariableAccess getVarAccess() { result = this.getVAccess() }

  //for testing
  int getLSL() { result = this.getVAccess().getLocation().getStartLine() }
}

predicate unAssignedUncheckedCalls(ExprStmt es) {
  es.getExpr() instanceof ReturnMustBeCheckedFunctionCall
}

cached
class UncomparedResults extends ExprStmt {
  cached
  UncomparedResults() {
    this.getExpr() instanceof MustBeCheckedExpr and
    not this.getExpr() instanceof ComparedMustChecks
    or
    unAssignedUncheckedCalls(this)
  }

  cached
  VariableAccess getVarAccess() { result = this.getExpr().(AssignExpr).getLValue() }

  //for testing
  cached
  int getLSL() { result = this.getExpr().getLocation().getStartLine() }
}

class NotCheckInsideFunction extends UncomparedResults {
  NotCheckInsideFunction() {
    not exists(FunctionCall fc |
      this.getLocation().getStartLine() < fc.getLocation().getStartLine() and
      // this.getAssignExpr().getEnclosingBlock() = fc.getEnclosingBlock() and
      this.getVarAccess().getTarget().getName() = fc.getArgument(0).toString() and
      fc.getTarget()
          .getName()
          .matches(["HRESULT\\_FROM\\_WIN32%", "CHECK\\_HR%", "operator%", "PrintError%", "printf"])
    )
  }

  cached
  VariableAccess getVAccess() { result = this.getVarAccess() }

  //for testing
  cached
  FunctionCall getF() { result = this.getExpr() }

  //for testing
  cached
  override int getLSL() { result = this.getExpr().getLocation().getStartLine() }
}

cached
class UN extends AssignExpr {
  ExprStmt ess;

  cached
  UN() {
    exists(VariableAccess va, VariableAccess va2, IfStmt ifs |
      this.getLValue() = va and
      this.getRValue().(FunctionCall) instanceof ReturnMustBeCheckedFunctionCall and
      this.getRValue().(FunctionCall).getTarget().getName() = "IoRegisterDeviceInterface" and //delete this
      this.getLocation().getStartLine() < ifs.getLocation().getStartLine() and
      this.getEnclosingBlock() = ifs.getEnclosingBlock() and
      exists(ExprStmt es |
        es = ess and
        this.getATrueSuccessor() = es and
        ifs.getAPredecessor() = es and
        es.getExpr().(AssignExpr).getLValue().(VariableAccess).getTarget().getName() =
          va.getTarget().getName()
      ) and
      va2.getEnclosingStmt() = ifs and
      va.getTarget().getName() = va2.getTarget().getName()
    )
  }

  cached
  ExprStmt getExprStm() { result = ess }
}

from ExprStmt es, ReturnMustBeCheckedFunctionCall rfc
where
  es.getExpr().(AssignExpr).getRValue().(FunctionCall) = rfc and
  rfc.getTarget().getName() = "IoRegisterDeviceInterface" and //to be deleted
  exists(FunctionCall fc, IfStmt ifs |
    fc.getTarget().getLocation().getStartLine() > es.getLocation().getStartLine() and
    fc.getTarget().getName().matches(["IF_FAILED_ACTION_JUMP"])
    or
    es.getLocation().getStartLine() < ifs.getLocation().getStartLine()
  )
// es.getEnclosingBlock().getAStmt() = ex2 and
// ex2.getExpr().(AssignExpr).getLValue().(VariableAccess).getTarget().getName() =
//   es.getExpr().(AssignExpr).getLValue().(VariableAccess).getTarget().getName() and
// not exists(IfStmt ifs |
//   ifs.getLocation().getStartLine() < ex2.getLocation().getStartLine() and
//   ifs.getLocation().getStartLine() > es.getLocation().getStartLine()
// ) and
// not exists(Function f |
//   f.getLocation().getStartLine() < ex2.getLocation().getStartLine() and
//   f.getLocation().getStartLine() > es.getLocation().getStartLine() and
//   f.getName().matches(["IF_FAILED_ACTION_JUMP"])
// )
select es, ""
