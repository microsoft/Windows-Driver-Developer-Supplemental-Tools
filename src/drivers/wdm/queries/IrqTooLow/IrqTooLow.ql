// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name IrqTooLow
 * @kind problem
 * @description The function is not permitted to be called at the current IRQ level. The current level is too low.
 * @problem.severity error
 * @id cpp/portedqueries/irq-too-low
 * @platform Desktop
 * @repor.text The following line(s) potentially contains a function call that is supposed to be called at a lower Irql level.
 * @feature.area Multiple
 * @version 1.0
 */

import cpp
import drivers.libraries.Irql

from IrqlAnnotatedFunction iaf, CallsToIrqlAnnotatedFunction ciaf, int curr, int called
where
  ciaf.getEnclosingFunction() = iaf and
  iaf.getIrqlLevel() = curr and
  getActualIrqlFunc(ciaf).getIrqlLevel() = called and
  curr < called
select ciaf,
  "Irql was set to " + curr + " in " + iaf.getName() + " but " + ciaf.getTarget().getName() +
    "() in its call hierarchy requires " + called + " Irql level."
