import cpp

class SuppressionPragma extends PreprocessorPragma {
  SuppressionPragma() { this.getHead().matches("warning(disable:%)") }
}

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

  predicate isInPushPopSegment(Location l) {
    l.getFile() = this.getFile() and
    l.getStartLine() >= start.getEndLine() and
    l.getEndLine() <= end.getStartLine()
  }
}

// Better way of doing it - can we store the locations with each pragma?

predicate hasSuppressionPragma(Function f) {
  exists(SuppressionPragma p |
    p.getFile() = f.getFile() and
    p.getLocation().getEndLine() >= f.getLocation().getStartLine() and
    (
      exists(SuppressionPushPopSegment spps |
        spps.isInPushPopSegment(f.getLocation()) and
        spps.isInPushPopSegment(p.getLocation())
      )
      /*
      or
      not exists(SuppressionPushPopSegment spps | spps.isInPushPopSegment(p.getLocation()))*/
    )
  )
}
