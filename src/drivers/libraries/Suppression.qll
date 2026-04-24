// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
import cpp

/**
 * Gets the minimum start line of a non-suppression Locatable in `f` that is
 * strictly after `afterLine`. Pre-computing distinct lines avoids iterating
 * over every Locatable individually in the aggregate.
 */
pragma[nomagic]
private int nextNonSuppressionLine(File f, int afterLine) {
  afterLine = any(SuppressPragma sp | sp.getFile() = f).getLocation().getEndLine() and
  result =
    min(int line |
      exists(Locatable l |
        l.getFile() = f and
        not l instanceof CASuppression and
        line = l.getLocation().getStartLine() and
        line > afterLine
      )
    )
}

/**
 * Holds if `d` is a DisablePragma that falls within SuppressionPushPopSegment `s`.
 */
pragma[nomagic]
private predicate disableInSegment(DisablePragma d, SuppressionPushPopSegment s) {
  d.getFile() = s.getFile() and
  d.getLocation().getStartLine() >= s.getSegmentStartLine() and
  d.getLocation().getEndLine() <= s.getSegmentEndLine()
}

/**
 * Holds if `d` is a DisablePragma that is inside at least one push/pop segment.
 */
pragma[nomagic]
private predicate disableHasSegment(DisablePragma d) {
  exists(SuppressionPushPopSegment s | disableInSegment(d, s))
}

/**
 * Holds if a Location in file `f` spanning `startLine` to `endLine`
 * falls inside at least one push/pop segment.
 */
bindingset[f, startLine, endLine]
pragma[inline_late]
private predicate locationInAnySegment(File f, int startLine, int endLine) {
  exists(SuppressionPushPopSegment s |
    f = s.getFile() and
    startLine >= s.getSegmentStartLine() and
    endLine <= s.getSegmentEndLine()
  )
}

// Reference: https://learn.microsoft.com/en-us/cpp/preprocessor/warning?view=msvc-170
/**
 * Represents a Code Analysis-style suppression using #pragma commands.
 *
 * In this library we support two styles:
 * #pragma prefast (suppress:XXXX) which suppresses rule XXXX on the following line of code, and
 * #pragma prefast (disable:XXXX) which suppresses rule XXXX until the pragma stack is adjusted using #pragma (push/pop).
 *
 * More details can be found at https://learn.microsoft.com/en-us/cpp/preprocessor/warning?view=msvc-170.
 * Please note that at present, pragma commands combining disable and suppress commands in a single line are
 * not supported.
 */
abstract class CASuppression extends PreprocessorPragma {
  abstract predicate matchesRuleName(string name);

  /** Returns the rule name that was provided in the suppression. */
  abstract string getRuleName();

  /** Evaluates if the given location is suppressed by this suppression. */
  abstract predicate appliesToLocation(Location l);

  /**
   * Gets the scope of this suppression as a line range within a file.
   * This is used by `hasLocationInfo` to define where the suppression applies
   * without enumerating every Location in the database.
   */
  abstract predicate scopeCovers(File f, int startLine, int endLine);

  /** Returns the scope covered by this suppression. */
  CASuppressionScope getScope() { result = this }

  /** Given the CA rule ID or warning from a suppression or disable pragma, creates an LGTM-style suppression. */
  string makeLgtmName() {
    this.getRuleName() =
      any([
            "__WARNING_BANNED_API_USAGE", "28719",
            "__WARNING_BANNED_LEGACY_INSTRUMENTATION_API_USAGE",
            "__WARNING_BANNED_CRIMSON_API_USAGE", "28735", "__WARNING_BANNED_API_USAGEL2", "28726",
            "__WARNING_BANNED_API_USAGE_LSTRLEN", "28750"
          ]
      ) and
    result = "lgtm[cpp/drivers/extended-deprecated-apis]"
    or
    this.getRuleName() = any(["__WARNING_UNHELPFUL_TAG", "28147"]) and
    result =
      any(["lgtm[cpp/drivers/default-pool-tag]", "lgtm[cpp/drivers/default-pool-tag-extended]"])
    or
    this.getRuleName() = any(["__WARNING_IRQL_NOT_SET", "28158"]) and
    result = "lgtm[cpp/drivers/irql-not-saved]"
    or
    this.getRuleName() = any(["__WARNING_IRQL_NOT_USED", "28157"]) and
    result = "lgtm[cpp/drivers/irql-not-used]"
    or
    this.getRuleName() = any(["__WARNING_POOL_TAG", "28134"]) and
    result = "lgtm[cpp/drivers/pool-tag-integral]"
    or
    this.getRuleName() = any(["__WARNING_STRSAFE_H", "28146"]) and
    result = "lgtm[cpp/drivers/str-safe]"
    or
    this.getRuleName() = any(["__WARNING_MUST_USE", "28193"]) and
    result = "lgtm[cpp/drivers/examined-value]"
    or
    this.getRuleName() = any(["__WARNING_IRQ_TOO_HIGH", "28121"]) and
    result = "lgtm[cpp/drivers/irql-too-high]"
    or
    this.getRuleName() = any(["__WARNING_IRQ_TOO_LOW", "28120"]) and
    result = "lgtm[cpp/drivers/irql-too-low]"
    or
    this.getRuleName() = any(["__WARNING_FUNCTION_ASSIGNMENT", "28128"]) and
    result = "lgtm[cpp/drivers/illegal-field-access]"
    or
    this.getRuleName() = any(["__WARNING_INACCESSIBLE_MEMBER", "28175"]) and
    result = "lgtm[cpp/drivers/illegal-field-access-2]"
    or
    this.getRuleName() = any(["__WARNING_READ_ONLY_MEMBER", "28176"]) and
    result = "lgtm[cpp/drivers/illegal-field-write]"
    or
    this.getRuleName() = any(["__WARNING_INIT_NOT_CLEARED", "28152"]) and
    result = "lgtm[cpp/drivers/init-not-cleared]"
    or
    this.getRuleName() = any(["__WARNING_KE_WAIT_LOCAL", "28135"]) and
    result = "lgtm[cpp/drivers/kewaitlocal-requires-kernel-mode]"
    or
    this.getRuleName() = any(["__WARNING_MULTIPLE_PAGED_CODE", "28171"]) and
    result = "lgtm[cpp/drivers/multiple-paged-code]"
    or
    this.getRuleName() = any(["__WARNING_NO_PAGED_CODE", "28170"]) and
    result = "lgtm[cpp/drivers/no-paged-code]"
    or
    this.getRuleName() = any(["__WARNING_NO_PAGING_SEGMENT", "28172"]) and
    result = "lgtm[cpp/drivers/no-paging-segment]"
    or
    this.getRuleName() = any(["__WARNING_OBJ_REFERENCE_MODE", "28126"]) and
    result = "lgtm[cpp/drivers/ob-reference-mode]"
    or
    this.getRuleName() = any(["__WARNING_MODIFYING_MDL", "28145"]) and
    result = "lgtm[cpp/drivers/opaque-mdl-write]"
    or
    this.getRuleName() = any(["__WARNING_PENDING_STATUS_ERROR", "28143"]) and
    result = "lgtm[cpp/drivers/pending-status-error]"
    or
    this.getRuleName() =
      any(["__WARNING_DISPATCH_MISMATCH", "28168", "__WARNING_DISPATCH_MISSING", "28169"]) and
    result = "lgtm[cpp/drivers/wrong-dispatch-table-assignment]"
    or
    this.getRuleName() = any(["__WARNING_IRQ_SET_TOO_HIGH", "28150"]) and
    result = "lgtm[cpp/drivers/irql-set-too-high]"
    or
    this.getRuleName() = any(["__WARNING_IRQ_SET_TOO_LOW", "28124"]) and
    result = "lgtm[cpp/drivers/irql-set-too-low]"
    or
    this.getRuleName() = any(["__WARNING_INTERLOCKEDDECREMENT_MISUSE1", "28616"]) and
    result = "lgtm[cpp/drivers/multithreaded-av-condition]"
    or
    this.getRuleName() = any(["__WARNING_PROTOTYPE_MISMATCH", "28127"]) and
    result = "lgtm[cpp/drivers/routine-function-type-not-expected]"
    or
    this.getRuleName() = any(["__WARNING_UNEXPECTED_IRQL_CHANGE", "28167"]) and
    result = "lgtm[cpp/drivers/irql-function-not-annotated]"
    or
    result = "lgtm[" + this.getRuleName() + "]"
  }
}

/** Represents the scope covered by a given CA supression. */
class CASuppressionScope extends ElementBase instanceof CASuppression {
  /**
   * Defines the location range covered by this suppression scope.
   * Instead of iterating all Location objects, this uses pre-computed scope bounds
   * to return the bounding box of the suppression region directly.
   */
  predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    exists(File f |
      super.scopeCovers(f, startline, endline) and
      filepath = f.getAbsolutePath() and
      startcolumn = 1 and
      endcolumn = 1
    )
  }
}

/**
 * Represents a #pragma warning(suppress:) statement, which suppresses a given warning on the following
 * line of actual code.
 */
class SuppressPragma extends CASuppression {
  string suppressedRule;

  /**
   * The characteristic predicate for a SuppressPragma relies on a regex that matches comments of the form:
   * [prefast/warning](suppress:[rule IDs]{, "comment"}) where the {} contents are fully optional.
   * Note that rule IDs can be in the form of raw numbers, or strings that may connect with dashes or underscores,
   * and multiple rule IDs may be specified in a single suppression.
   */
  SuppressPragma() {
    suppressedRule =
      any(string s |
        s =
          this.getHead()
              .regexpCapture("(prefast|warning)\\(\\s*suppress\\s*:\\s*([\\d\\w\\s\\\\\\p{Pd}\\p{Pc}/]+)+(,?([\\s\\w\\d\\W\\p{P}]))*\\)",
                2)
              .splitAt(" ")
      )
  }

  pragma[inline]
  override predicate matchesRuleName(string name) { name = suppressedRule }

  pragma[inline]
  override string getRuleName() { result = suppressedRule }

  pragma[nomagic]
  override predicate appliesToLocation(Location l) {
    this.getFile() = l.getFile() and
    this.getLocation().getEndLine() + this.getMinimumLocationOffset() = l.getStartLine()
  }

  /** The scope of a suppress pragma is just the single next code line. */
  pragma[nomagic]
  override predicate scopeCovers(File f, int startLine, int endLine) {
    f = this.getFile() and
    startLine = this.getLocation().getEndLine() + this.getMinimumLocationOffset() and
    endLine = startLine
  }

  /** Finds the offset (in line count) to the closest non-pragma element after this suppression. */
  pragma[nomagic]
  int getMinimumLocationOffset() {
    exists(int nextLine |
      nextLine = nextNonSuppressionLine(this.getFile(), this.getLocation().getEndLine()) and
      result = nextLine - this.getLocation().getEndLine()
    )
  }
}

/**
 * Represents a #pragma warning(disable:) statement, which suppresses the given warning indefinitely
 * until the pragma state is pushed or popped, or until an enable statement is used (enable not yet implemented).
 */
class DisablePragma extends CASuppression {
  string disabledRule;

  DisablePragma() {
    disabledRule =
      any(string s |
        s =
          this.getHead()
              .regexpCapture("(prefast|warning)\\(\\s*disable\\s*:\\s*([\\d\\w\\s\\\\\\p{Pd}\\p{Pc}/]+)+(,?([\\s\\w\\d\\W\\p{P}]))*\\)",
                2)
              .splitAt(" ")
      )
  }

  pragma[inline]
  override predicate matchesRuleName(string name) { name = disabledRule }

  pragma[inline]
  override string getRuleName() { result = disabledRule }

  pragma[nomagic]
  override predicate appliesToLocation(Location l) {
    this.getFile() = l.getFile() and
    this.getLocation().getEndLine() <= l.getStartLine() and
    // If we're in a pragma push/pop, ensure the disable is too
    (
      exists(SuppressionPushPopSegment spps |
        disableInSegment(this, spps) and
        spps.isInPushPopSegment(l)
      )
      or
      not disableHasSegment(this) and
      not locationInAnySegment(l.getFile(), l.getStartLine(), l.getEndLine())
    )
  }

  /**
   * The scope of a disable pragma: from the disable line to either the end of the
   * enclosing push/pop segment, or the end of the file.
   * Returns a single bounding range rather than enumerating every Location.
   */
  pragma[nomagic]
  override predicate scopeCovers(File f, int startLine, int endLine) {
    f = this.getFile() and
    startLine = this.getLocation().getEndLine() and
    (
      // If in a push/pop segment, scope ends at the segment end
      exists(SuppressionPushPopSegment spps |
        disableInSegment(this, spps) and
        endLine = spps.getSegmentEndLine()
      )
      or
      // If not in any segment, scope covers to end of file
      not disableHasSegment(this) and
      endLine = max(int line | exists(Location l | l.getFile() = f and line = l.getEndLine()))
    )
  }
}

/** Represents a pragma push statement. */
class SuppressionPushPragma extends PreprocessorPragma {
  boolean isWarning;

  SuppressionPushPragma() {
    this.getHead().regexpMatch("warning\\s*\\(\\s*push\\s*\\)") and isWarning = true
    or
    this.getHead().regexpMatch("prefast\\s*\\(\\s*push\\s*\\)") and isWarning = false
  }

  boolean getIsWarning() { result = isWarning }
}

/** Represents a pragma pop statement. */
class SuppressionPopPragma extends PreprocessorPragma {
  boolean isWarning;

  SuppressionPopPragma() {
    this.getHead().regexpMatch("warning\\s*\\(\\s*pop\\s*\\)") and isWarning = true
    or
    this.getHead().regexpMatch("prefast\\s*\\(\\s*pop\\s*\\)") and isWarning = false
  }

  boolean getIsWarning() { result = isWarning }
}

/** Represents an area surrounded by pragma push/pops. */
class SuppressionPushPopSegment extends Location {
  SuppressionPushPragma push;
  SuppressionPopPragma pop;
  Location start;
  Location end;

  SuppressionPushPopSegment() {
    start = this and
    push.getLocation() = start and
    pop.getLocation() = end and
    pop.getFile() = push.getFile() and
    pop.getLocation().getStartLine() >= push.getLocation().getEndLine() and
    pop.getIsWarning() = push.getIsWarning() and
    not exists(SuppressionPopPragma closerPop |
      closerPop.getFile() = push.getFile() and
      closerPop.getLocation().getStartLine() >= push.getLocation().getEndLine() and
      closerPop.getLocation().getEndLine() < pop.getLocation().getStartLine() and
      closerPop.getIsWarning() = push.getIsWarning()
    )
  }

  /** Gets the end line of the push (start of the segment content). */
  int getSegmentStartLine() { result = start.getEndLine() }

  /** Gets the start line of the pop (end of the segment content). */
  int getSegmentEndLine() { result = end.getStartLine() }

  /** Determines if a given location is in this push/pop segment. */
  pragma[nomagic]
  predicate isInPushPopSegment(Location l) {
    l.getFile() = this.getFile() and
    l.getStartLine() >= start.getEndLine() and
    l.getEndLine() <= end.getStartLine()
  }

  /** Returns a disable pragma within this push/pop segment. */
  DisablePragma getADisablePragma() {
    disableInSegment(result, this)
  }
}
