// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irql-not-used
 * @name IRQL not restored
 * @description Any parameter annotated \_IRQL\_restores\_ must be read and used to restore the IRQL value.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text This function has a parameter annotated \_IRQL\_restores\_, but does not have a code path where this parameter is read and used to restore the IRQL.
 * @owner.email sdat@microsoft.com
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       wddst
 * @query-version v1
 */

import cpp
import drivers.libraries.Irql

/** Represents a call to a function that has IRQL annotations restricting the range of IRQLs it can run at. */
class IrqlRestrainedCall extends FunctionCall {
  IrqlRestrainedCall() { this.getTarget() instanceof IrqlAnnotatedFunction }

  int getIrqlLevel() { result = this.getTarget().(IrqlAnnotatedFunction).getIrqlLevel() }

  string getFuncIrqlAnnotation() {
    result = this.getTarget().(IrqlAnnotatedFunction).getFuncIrqlAnnotation()
  }
}

/**
 * Attempt to find the range of valid IRQL values when **exiting** a given function.
 * TODO: Make a version of this focused on calls that we can recursively call to track the IRQL.
 * TODO: Cases where annotated min and max
 * BUG: Returning 15 unexpectedly in places.
 */
int getPotentialIrql(IrqlAnnotatedFunction irqlFunc) {
  if irqlFunc instanceof IrqlRaisesAnnotatedFunction
  then result = irqlFunc.getIrqlLevel()
  else
    if
      irqlFunc instanceof IrqlRequiresAnnotatedFunction and
      irqlFunc instanceof IrqlRequiresSameAnnotatedFunction
    then result = irqlFunc.getIrqlLevel()
    else
      if
        irqlFunc instanceof IrqlMaxAnnotatedFunction and
        irqlFunc instanceof IrqlMinAnnotatedFunction
      then
        result =
          any([irqlFunc.(IrqlMinAnnotatedFunction).getIrqlLevel() .. irqlFunc
                    .(IrqlMaxAnnotatedFunction)
                    .getIrqlLevel()]
          )
      else
        if irqlFunc instanceof IrqlMaxAnnotatedFunction
        then result = any([0 .. irqlFunc.getIrqlLevel()])
        else
          if irqlFunc instanceof IrqlMinAnnotatedFunction
          then result = any([irqlFunc.getIrqlLevel() .. 15])
          else
            // Below is never reached, and is invalid if it is
            result = -1
}

/** Given a IrqlRestrainedCall, gets the most recent prior call in the block. */
IrqlRestrainedCall getPrecedingCallInSameBasicBlock(IrqlRestrainedCall irc) {
  result =
    irc.getBasicBlock()
        .getNode(max(int precPos |
            exists(IrqlRestrainedCall prec, int callPos |
              irc.getBasicBlock().getNode(precPos) = prec and
              irc.getBasicBlock().getNode(callPos) = irc and
              precPos < callPos
            )
          ))
}

/** Get the most recent basic block(s) before a given block that also adjust the IRQL. */
BasicBlock getPrecedingBasicBlocksWithIrqlCalls(BasicBlock inBlock) {
  result =
    any(BasicBlock bb |
      bb.getANode() instanceof IrqlRestrainedCall and
      bb.getASuccessor+() = inBlock and
      not exists(BasicBlock otherBlock |
        bb.getASuccessor+() = otherBlock and
        otherBlock.getASuccessor+() = otherBlock and
        otherBlock.getANode() instanceof IrqlRestrainedCall
      )
    )
}

/** Given a basic block, return the last irql-restrained call in that block. */
IrqlRestrainedCall lastIrqlCallInBlock(BasicBlock inBlock) {
  result = inBlock.getNode(max(int i | inBlock.getNode(i) instanceof IrqlRestrainedCall))
}

/** Given a irql-restrained call, return the most recent set of irql restrictions prior to it. */
int getAMostRecentIrql(IrqlRestrainedCall irc) {
  if
    exists(IrqlRestrainedCall previousCall, int precPos, int callPos |
      irc.getBasicBlock().contains(previousCall) and
      irc != previousCall and
      irc.getBasicBlock().getNode(precPos) = previousCall and
      irc.getBasicBlock().getNode(callPos) = irc
    )
  then result = getPotentialIrql(getPrecedingCallInSameBasicBlock(irc).getTarget())
  else
    // look for most recent basic block(s) with Irql calls
    if
      exists(BasicBlock previousIrqlBlock, IrqlRestrainedCall previousCall |
        irc.getBasicBlock().getAPredecessor+() = previousIrqlBlock and
        previousCall.getBasicBlock() = previousIrqlBlock
      )
    then
      // Can we use the same algorithm as the intra-block search?
      // Foreach preceding block that has an IrqlCall, use its values iff not exists
      // some other block s.t. there is a path from the preceding block to the other block to our block.
      result =
        (
          any(IrqlRestrainedCall previousCall |
            previousCall =
              lastIrqlCallInBlock(getPrecedingBasicBlocksWithIrqlCalls(irc.getBasicBlock()))
          )
        ).getIrqlLevel()
    else
      // Else look at function signature overall
      if irc.getEnclosingFunction() instanceof IrqlAnnotatedFunction
      then result = getPotentialIrql(irc.getEnclosingFunction())
      else
        // Else invalid
        result = -1
}

// TODO: Track IRQL recursively
/*
 * from IrqlRestrainedCall irc, int previousLevel
 * where
 *  irc.getTarget() instanceof IrqlMinAnnotatedFunction and
 *  previousLevel != -1 and
 *  previousLevel = max(int i | i = getAMostRecentIrql(irc)) and
 *  irc.getTarget().(IrqlMinAnnotatedFunction).getIrqlLevel() > previousLevel
 * select irc, "IRQL is potentially too low at call $@ - min " + irc.getIrqlLevel() + ", found " + previousLevel, irc, irc.toString()
 */

// TODO: Track IRQL recursively
from IrqlRestrainedCall irc, int previousLevel
where
  irc.getTarget() instanceof IrqlMaxAnnotatedFunction and
  previousLevel != -1 and
  previousLevel = min(int i | i = getAMostRecentIrql(irc)) and
  irc.getTarget().(IrqlMaxAnnotatedFunction).getIrqlLevel() < previousLevel
select irc,
  "IRQL is too high at call $@ - max " + irc.getIrqlLevel() + ", found " + previousLevel,
  irc, irc.toString()
