/**
 * Provides a reachability predicate API.
 */
import cpp

/**
 * Holds if `a` has `b` as a successor.
 */
cached
predicate reaches(ControlFlowNode a, ControlFlowNode b) {
  b = a.getASuccessor+()
}
