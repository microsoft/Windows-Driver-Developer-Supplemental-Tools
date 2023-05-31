import cpp

// Reference: https://learn.microsoft.com/en-us/cpp/preprocessor/warning?view=msvc-170
//TODO: Support pragmas that combine disable, suppress, etc. in a single line
//TODO: Support LGTM-style comment suppression?
/** Represents a Code Analysis-style suppression using #pragma commands. */
abstract class CASuppression extends PreprocessorPragma {
  abstract predicate matchesRuleName(string name);

  /** Returns the rule name that was provided in the suppression. */
  abstract string getRuleName();

  /** Evaluates if the given location is suppressed by this suppression. */
  abstract predicate appliesToLocation(Location l);

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
    result = "lgtm[cpp/windows/drivers/queries/extended-deprecated-apis]"
    or
    this.getRuleName() = any(["__WARNING_UNHELPFUL_TAG", "28147"]) and
    result =
      any([
            "lgtm[cpp/windows/drivers/queries/default-pool-tag]",
            "lgtm[cpp/windows/drivers/queries/default-pool-tag-extended]"
          ]
      )
    or
    this.getRuleName() = any(["__WARNING_IRQL_NOT_SET", "28158"]) and
    result = "lgtm[cpp/drivers/irql-not-saved]"
    or
    this.getRuleName() = any(["__WARNING_IRQL_NOT_USED", "28157"]) and
    result = "lgtm[cpp/drivers/irql-not-used]"
    or
    this.getRuleName() = any(["__WARNING_POOL_TAG", "28134"]) and
    result = "lgtm[cpp/windows/drivers/queries/pool-tag-integral]"
    or
    this.getRuleName() = any(["__WARNING_STRSAFE_H", "28146"]) and
    result = "lgtm[cpp/portedqueries/str-safe]"
    or
    this.getRuleName() = any(["__WARNING_MUST_USE", "28193"]) and
    result = "lgtm[cpp/portedqueries/examined-value]"
    or
    this.getRuleName() = any(["__WARNING_IRQ_TOO_LOW", "28120"]) and
    result = "lgtm[cpp/portedqueries/irq-too-low]"
    or
    this.getRuleName() = any(["__WARNING_IRQ_TOO_HIGH", "28121"]) and
    result = "lgtm[cpp/portedqueries/irq-too-high]"
    or
    this.getRuleName() = any(["__WARNING_FUNCTION_ASSIGNMENT", "28128"]) and
    result = "lgtm[cpp/windows/drivers/queries/illegal-field-access]"
    or
    this.getRuleName() = any(["__WARNING_INACCESSIBLE_MEMBER", "28175"]) and
    result = "lgtm[cpp/windows/drivers/queries/illegal-field-access-2]"
    or
    this.getRuleName() = any(["__WARNING_READ_ONLY_MEMBER", "28176"]) and
    result = "lgtm[cpp/windows/drivers/queries/illegal-field-write]"
    or
    this.getRuleName() = any(["__WARNING_INIT_NOT_CLEARED", "28152"]) and
    result = "lgtm[cpp/windows/drivers/queries/init-not-cleared]"
    or
    this.getRuleName() = any(["__WARNING_KE_WAIT_LOCAL", "28135"]) and
    result = "lgtm[cpp/drivers/kewaitlocal-requires-kernel-mode]"
    or
    this.getRuleName() = any(["__WARNING_MULTIPLE_PAGED_CODE", "28171"]) and
    result = "lgtm[cpp/portedqueries/multiple-paged-code]"
    or
    this.getRuleName() = any(["__WARNING_NO_PAGED_CODE", "28170"]) and
    result = "lgtm[cpp/portedqueries/no-paged-code]"
    or
    this.getRuleName() = any(["__WARNING_NO_PAGING_SEGMENT", "28172"]) and
    result = "lgtm[cpp/portedqueries/no-paging-segment]"
    or
    this.getRuleName() = any(["__WARNING_OBJ_REFERENCE_MODE", "28126"]) and
    result = "lgtm[cpp/windows/drivers/queries/ob-reference-mode]"
    or
    this.getRuleName() = any(["__WARNING_MODIFYING_MDL", "28145"]) and
    result = "lgtm[cpp/windows/drivers/queries/opaquemdlwrite]"
    or
    this.getRuleName() = any(["__WARNING_PENDING_STATUS_ERROR", "28143"]) and
    result = "lgtm[cpp/portedqueries/pending-status-error]"
    or
    this.getRuleName() =
      any(["__WARNING_DISPATCH_MISMATCH", "28168", "__WARNING_DISPATCH_MISSING", "28169"]) and
    result = "lgtm[cpp/portedqueries/wrong-dispatch-table-assignment]"
    or
    result = "lgtm[" + this.getRuleName() + "]"
  }
}

/** Represents the scope covered by a given CA supression. */
class CASuppressionScope extends ElementBase instanceof CASuppression {
  predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    exists(Location l |
      l.getFile().getAbsolutePath() = filepath and
      l.getStartLine() = startline and
      l.getStartColumn() = startcolumn and
      l.getEndLine() = endline and
      l.getEndColumn() = endcolumn and
      super.appliesToLocation(l)
    )
  }
}

/**
 * Represents a #pragma warning(suppress:) statement, which suppresses a given warning on the following
 * line of actual code.
 */
class SuppressPragma extends CASuppression {
  string suppressedRule;

  SuppressPragma() {
    suppressedRule =
      any(string s |
          s =
            this.getHead()
                .regexpCapture("prefast\\(\\s*suppress\\s*:\\s*([\\d\\w\\s]+)+\\)", 1)
                .splitAt(" ")
          or
          s =
            this.getHead()
                .regexpCapture("warning\\(\\s*suppress\\s*:\\s*([\\d\\w\\s]+)+\\)", 1)
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

  /** Finds the offset (in line count) to the closest non-pragma element after this suppression. */
  pragma[nomagic]
  cached int getMinimumLocationOffset() {
    result =
      min(int i |
        i > 0 and
        exists(Locatable l |
          l.getFile() = this.getFile() and
          l.getLocation().getStartLine() > this.getLocation().getEndLine() and
          not l instanceof CASuppression and
          this.getLocation().getEndLine() + i = l.getLocation().getStartLine()
        )
      )
  }
}

/**
 * Represents a #pragma warning(disable:) statement, which suppresses the given warning indefinitely
 * until the pragma state is pushed or popped, or until an enable statement is used (enable not yet implemented).
 */
class DisablePragma extends CASuppression {
  string disabledRule;

  // TODO: Support #pragma warning(disable:28104 28161 6001 6101) - i.e. multiple rules disabled in one line
  DisablePragma() {
    disabledRule = any(string s |
      s =
        this.getHead()
            .regexpCapture("prefast\\(\\s*disable\\s*:\\s*([\\d\\w\\s]+)+\\)", 1)
            .splitAt(" ")
      or
      s =
        this.getHead()
            .regexpCapture("warning\\(\\s*disable\\s*:\\s*([\\d\\w\\s]+)+\\)", 1)
            .splitAt(" ")
    )
  }

  pragma[inline]
  override predicate matchesRuleName(string name) { name = disabledRule }

  pragma[inline]
  override string getRuleName() { result = disabledRule }

  pragma[inline]
  override predicate appliesToLocation(Location l) {
    this.getFile() = l.getFile() and
    this.getLocation().getEndLine() <= l.getStartLine() and
    // If we're in a pragma push/pop, ensure the disable is too
    exists(SuppressionPushPopSegment spps |
      spps.getADisablePragma() = this and
      spps.isInPushPopSegment(l)
    )
    // TODO: Handle case where the disable is outside push/pop
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

  /** Determines if a given location is in this push/pop segment. */
  pragma[inline]
  predicate isInPushPopSegment(Location l) {
    l.getFile() = this.getFile() and
    l.getStartLine() >= start.getEndLine() and
    l.getEndLine() <= end.getStartLine()
  }

  /** Returns a disable pragma within this push/pop segment. */
  cached
  DisablePragma getADisablePragma() {
    result = any(DisablePragma p | this.isInPushPopSegment(p.getLocation()))
  }
}
