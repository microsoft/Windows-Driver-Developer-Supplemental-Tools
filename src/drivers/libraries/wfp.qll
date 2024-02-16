/**
 * Provides classes for identifying and reasoning about Microsoft Windows Filtering Platform Callout
 * (WFP) Annotation
 *
 * This version of this file has been updated to include fwpk.h as a valid WFP header.
 * It will be removed if and when that change is upstreamed to the main CodeQL repo.
 *
 */

 import cpp

 /**
 * A WFP macro defined in `fwpk.h` or a similar header file.
 */
class WfpMacro extends Macro {
    WfpMacro() {
      this.getFile().getBaseName() =
        [
          "fwpl.h", "Wfp_Annotations.h"
        ] and
        // Dialect for Windows 11 and above
        this.getName().matches("\\_%\\_")
    }
  }

  pragma[noinline]
  private predicate isTopLevelMacroAccess(MacroAccess ma) { not exists(ma.getParentInvocation()) }
  
  /**
   * An invocation of a WFP macro (excluding invocations inside other macros).
   */
  class WfpAnnotation extends MacroInvocation {
    WfpAnnotation() {
      this.getMacro() instanceof WfpMacro and
      isTopLevelMacroAccess(this)
    }
  
    /** Gets the `Declaration` annotated by `this`. */
    Declaration getDeclaration() {
      annotatesAt(this, result.getADeclarationEntry(), _, _) and
      not result instanceof Type // exclude typedefs
    }
  
    Declaration getTypedefDeclarations() {
      annotatesAt(this, result.getADeclarationEntry(), _, _) and
      result instanceof Type // include
    }
  
    /** Gets the `DeclarationEntry` annotated by `this`. */
    DeclarationEntry getDeclarationEntry() {
      annotatesAt(this, result, _, _) and
      not result instanceof TypeDeclarationEntry // exclude typedefs
    }
  }

/**
 * A Wfp macro indicating that the callout function is a stream layer function (inspection callout)
 */
class WfpStreamInspection extends WfpAnnotation {
    WfpStreamInspection() {
      this.getMacro().(WfpMacro).getName() = ["_Wfp_stream_inspection_classify_","_Wfp_stream_inspection_notify_"]
    }
  }

/**
 * A Wfp macro indicating that the callout function is a stream layer function (injection callout)
 */
class WfpStreamInjection extends WfpAnnotation {
    WfpStreamInjection() {
      this.getMacro().(WfpMacro).getName() = ["_Wfp_stream_injection_classify_"]
    }
  }

/**
 * A Wfp macro indicating that the callout function is a flow layer function (inspection callout)
 */
class WfpFlowInspection extends WfpAnnotation {
  WfpFlowInspection() {
      this.getMacro().(WfpMacro).getName() = ["_Wfp_flow_inspection_notify_", "_Wfp_flow_inspection_classify_"]
    }
  }

/**
 * A Wfp macro indicating that the callout function is a flow layer function (injection callout)
 */
class WfpFlowInjection extends WfpAnnotation {
  WfpFlowInjection() {
    this.getMacro().(WfpMacro).getName() = ["_Wfp_flow_injection_classify_"]
  }
}

/**
 * A Wfp macro indicating that the callout function is a transport layer function
 */
class WfpTransportInjection extends WfpAnnotation {
  WfpTransportInjection() {
      this.getMacro().(WfpMacro).getName() = ["_Wfp_transport_injection_classify_","_Wfp_transport_injection_classify_inline_"]
    }
  }

  /**
 * A Wfp macro indicating that the callout function is a transport layer function
 */
class WfpTransportInspection extends WfpAnnotation {
  WfpTransportInspection() {
      this.getMacro().(WfpMacro).getName() = ["_Wfp_Transport_inspection_classify_"]
    }
  }


  /**
 * A Wfp macro indicating that the callout function is a connect-redirect layer function
 */
class WfpConnectRedirect extends WfpAnnotation {
  WfpConnectRedirect() {
    this.getMacro().(WfpMacro).getName() = ["_Wfp_connect_redirect_classify_", "_Wfp_connect_redirect_inline_classify_"]
  }
}

///////////////////////////////////////////////////////////////////////////////
// Implementation details
/**
 * Holds if `a` annotates the declaration entry `d` and
 * its start position is the `idx`th position in `file` that holds a WFP element.
 */
private predicate annotatesAt(WfpAnnotation a, DeclarationEntry d, File file, int idx) {
    annotatesAtPosition(a.(WfpElement).getStartPosition(), d, file, idx)
  }
  
  /**
   * Holds if `pos` is the `idx`th position in `file` that holds a Wfp element,
   * which annotates the declaration entry `d` (by occurring before it without
   * any other declaration entries in between).
   */
  // For performance reasons, do not mention the annotation itself here,
  // but compute with positions instead. This performs better on databases
  // with many annotations at the same position.
  private predicate annotatesAtPosition(WfpPosition pos, DeclarationEntry d, File file, int idx) {
    pos = wfpRelevantPositionAt(file, idx) and
    wfpAnnotationPos(pos) and
    (
      // Base case: `pos` right before `d`
      d.(WfpElement).getStartPosition() = wfpRelevantPositionAt(file, idx + 1)
      or
      // Recursive case: `pos` right before some annotation on `d`
      annotatesAtPosition(_, d, file, idx + 1)
    )
  }
  
/**
 * A Wfp element, that is, a Wfp annotation or a declaration entry
 * that may have Wfp annotations.
 */
library class WfpElement extends Element {
    WfpElement() {
      containsWfpAnnotation(this.(DeclarationEntry).getFile()) or
      this instanceof WfpAnnotation
    }
  
    predicate hasStartPosition(File file, int line, int col) {
      exists(Location loc | loc = this.getLocation() |
        file = loc.getFile() and
        line = loc.getStartLine() and
        col = loc.getStartColumn()
      )
    }
  
    predicate hasEndPosition(File file, int line, int col) {
      exists(Location loc |
        loc = this.(FunctionDeclarationEntry).getBlock().getLocation()
        or
        this =
          any(VariableDeclarationEntry vde |
            vde.isDefinition() and
            loc = vde.getVariable().getInitializer().getLocation()
          )
      |
        file = loc.getFile() and
        line = loc.getEndLine() and
        col = loc.getEndColumn()
      )
    }
  
    WfpPosition getStartPosition() {
      exists(File file, int line, int col |
        this.hasStartPosition(file, line, col) and
        result = MkWfpPosition(file, line, col)
      )
    }
  }
  
  /** Holds if `file` contains a Wfp annotation. */
  pragma[noinline]
  private predicate containsWfpAnnotation(File file) { any(WfpAnnotation a).getFile() = file }
  
  /**
   * A source-file position of a `WfpElement`. Unlike location, this denotes a
   * point in the file rather than a range.
   */
  private newtype WfpPosition =
    MkWfpPosition(File file, int line, int col) {
      exists(WfpElement e |
        e.hasStartPosition(file, line, col)
        or
        e.hasEndPosition(file, line, col)
      )
    }

/** Holds if `pos` is the start position of a SAL annotation. */
pragma[noinline]
private predicate wfpAnnotationPos(WfpPosition pos) {
  any(WfpAnnotation a).(WfpElement).getStartPosition() = pos
}

/**
 * Gets the `idx`th position in `file` that holds a Wfp element,
 * ordering positions lexicographically by their start line and start column.
 */
private WfpPosition wfpRelevantPositionAt(File file, int idx) {
  result =
    rank[idx](WfpPosition pos, int line, int col |
      pos = MkWfpPosition(file, line, col)
    |
      pos order by line, col
    )
}

class ActionTypeExpr extends AssignExpr{
  ActionTypeExpr(){
     this.getLValue().getType().getName().matches(["FWP_ACTION_TYPE"]) and 
     this.getRValue().getFullyConverted().getType().getName().matches(["FWP_ACTION_TYPE"])
  }
}

class RedirectHandleCreateFunctionCall extends MetricFunction {
  RedirectHandleCreateFunctionCall() {
          this.getQualifiedName().toString().matches(["FwpsRedirectHandleCreate%"])
  }
}

predicate isBlockExpression(ActionTypeExpr exp) {
  exp.getRValue().getFullyConverted().getFullyConverted().getValue().matches(["FWP_ACTION_BLOCK", "4097"])
}

class WriteActionFlagSet extends AssignExpr {
  WriteActionFlagSet(){
      this.getLValue().getType().getName().matches(["UINT32"]) and
      this.getRValue().getFullyConverted().getValue().toInt() = 1 //FWPS_RIGHT_ACTION_WRITE
  }
}