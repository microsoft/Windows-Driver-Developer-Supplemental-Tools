import cpp

// Reference: https://learn.microsoft.com/en-us/cpp/preprocessor/warning?view=msvc-170
//TODO: Support pragmas that combine disable, suppress, etc. in a single line
//TODO: Support LGTM-style comment suppression?
//TODO: Improve performance
abstract class CASuppression extends PreprocessorPragma {
  abstract predicate matchesRuleName(string name);

  abstract string getRuleName();

  abstract predicate appliesToLocation(Location l);

  CASuppressionScope getScope() { result = this }

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
      // Gotta handle the case where multiple suppressions are stacked.
      // There's something here with an n-1, recursion situation I feel...
    )
  }
}

class SuppressPragma extends CASuppression {
  string suppressedRule;

  //TODO: Support #pragma warning(suppress:28104 28161 6001 6101) - i.e. multiple suppresses in one line
  // Would an any() construct work here? Like any (string s, int i | .regexcapture(i))
  SuppressPragma() {
    suppressedRule =
      any(string s |
        exists(int n |
          s =
            this.getHead()
                .regexpCapture("prefast\\(\\s*suppress\\s*:\\s*([\\d\\w]+)[\\s\\d\\w\\W]*\\)", n)
          or
          suppressedRule =
            this.getHead()
                .regexpCapture("warning\\(\\s*suppress\\s*:\\s*([\\d\\w]+)[\\s\\d\\w\\W]*\\)", n)
        )
      )
  }

  pragma[inline]
  override predicate matchesRuleName(string name) { name = suppressedRule }

  pragma[inline]
  override string getRuleName() { result = suppressedRule }

  override predicate appliesToLocation(Location l) {
    this.getFile() = l.getFile() and
    this.getLocation().getEndLine() + 1 = l.getStartLine()
  }
}

class DisablePragma extends CASuppression {
  string disabledRule;

  DisablePragma() {
    disabledRule =
      this.getHead().regexpCapture("warning\\s*\\(\\s*disable\\s*:\\s*([\\d\\w]+)\\s*\\)", 1) or
    disabledRule =
      this.getHead().regexpCapture("prefast\\s*\\(\\s*disable\\s*:\\s*([\\d\\w]+)\\s*\\)", 1)
  }

  pragma[inline]
  override predicate matchesRuleName(string name) { name = disabledRule }

  pragma[inline]
  override string getRuleName() { result = disabledRule }

  pragma[inline]
  override predicate appliesToLocation(Location l) {
    this.getFile() = l.getFile() and
    this.getLocation().getEndLine() >= l.getStartLine() and
    exists(SuppressionPushPopSegment spps |
      spps.getADisablePragma() = this and
      spps.isInPushPopSegment(l)
    )
  }
}

//TODO: Support prefast(push) and prefast(pop) (and distinguish between warning/prefast?)
class SuppressionPushPragma extends PreprocessorPragma {
  SuppressionPushPragma() { this.getHead().matches("warning(push)") }
}

class SuppressionPopPragma extends PreprocessorPragma {
  SuppressionPopPragma() { this.getHead().matches("warning(pop)") }
}

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
    not exists(SuppressionPopPragma closerPop |
      closerPop.getFile() = push.getFile() and
      closerPop.getLocation().getStartLine() >= push.getLocation().getEndLine() and
      closerPop.getLocation().getEndLine() < pop.getLocation().getStartLine()
    )
  }

  pragma[inline]
  predicate isInPushPopSegment(Location l) {
    l.getFile() = this.getFile() and
    l.getStartLine() >= start.getEndLine() and
    l.getEndLine() <= end.getStartLine()
  }

  cached
  DisablePragma getADisablePragma() {
    result = any(DisablePragma p | this.isInPushPopSegment(p.getLocation()))
  }
}

predicate fastHasSpecificSuppressionPragma(Location l, string rule) {
  // Is the rule suppressed by a one-line suppression?
  exists(SuppressPragma p |
    p.getFile() = l.getFile() and
    p.matchesRuleName(rule) and
    p.getLocation().getEndLine() + 1 = l.getStartLine()
  )
  or
  // Is the rule suppressed by a disable statement?
  fastHasSpecificSuppressionPragma_aux(any(DisablePragma p |
      l.getFile() = p.getFile() and p.matchesRuleName(rule)
    ), l)
}

predicate fastHasSpecificSuppressionPragma_aux(DisablePragma p, Location l) {
  p.getLocation().getEndLine() <= l.getStartLine() and
  (
    exists(SuppressionPushPopSegment spps |
      spps.getFile() = p.getFile() and
      spps.isInPushPopSegment(l) and
      spps.getADisablePragma() = p
    )
    or
    noContainingPushPopSegment(p)
  )
}

pragma[noinline]
predicate noContainingPushPopSegment(DisablePragma p) {
  not any(SuppressionPushPopSegment spps | spps.getFile() = p.getFile()).getADisablePragma() = p
}
