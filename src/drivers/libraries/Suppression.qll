import cpp

// Reference: https://learn.microsoft.com/en-us/cpp/preprocessor/warning?view=msvc-170

//TODO: Support pragmas that combine disable, suppress, etc. in a single line
//TODO: Support LGTM-style comment suppression?
//TODO: Improve performance

class SuppressPragma extends PreprocessorPragma {
  string suppressedRule;

  //TODO: Support #pragma warning(suppress:28104 28161 6001 6101) - i.e. multiple suppresses in one line
  SuppressPragma() {
    suppressedRule =
      this.getHead()
          .regexpCapture("prefast\\(\\s*suppress\\s*:\\s*([\\d\\w]+)[\\s\\d\\w\\W]*\\)", 1) or
    suppressedRule =
      this.getHead()
          .regexpCapture("warning\\(\\s*suppress\\s*:\\s*([\\d\\w]+)[\\s\\d\\w\\W]*\\)", 1)
  }

  pragma[inline]
  predicate matchesRuleName(string name) { name = suppressedRule }

  pragma[inline]
  string getRuleName() { result = suppressedRule }
}

class DisablePragma extends PreprocessorPragma {
  string disabledRule;

  DisablePragma() {
    disabledRule =
      this.getHead().regexpCapture("warning\\s*\\(\\s*disable\\s*:\\s*([\\d\\w]+)\\s*\\)", 1) or
    disabledRule =
      this.getHead().regexpCapture("prefast\\s*\\(\\s*disable\\s*:\\s*([\\d\\w]+)\\s*\\)", 1)
  }

  pragma[inline]
  predicate matchesRuleName(string name) { name = disabledRule }

  pragma[inline]
  string getRuleName() { result = disabledRule }

  pragma[inline]
  predicate appliesToLocation(Location l) {
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
