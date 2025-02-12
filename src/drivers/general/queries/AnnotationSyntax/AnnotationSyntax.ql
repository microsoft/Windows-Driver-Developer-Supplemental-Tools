// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/annotation-syntax
 * @kind problem
 * @name Annotation syntax error
 * @description A syntax error in the annotations was found for the property in the function.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Annotations
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28266
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       ca_ported
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.libraries.SAL

from SALAnnotation sa
where
  // restoreIRQLGlobal was not on the whole function
  // saveIRQLGlobal was not on the whole function
  (
    sa.toString().matches("%restoresIRQLGlobal%") or //restoreIRQLGlobal //__drv_restoresIRQLGlobal //_IRQL_restores_global_
    sa.toString().matches("%_IRQL_saves_global_%") or //restoreIRQLGlobal //__drv_restoresIRQLGlobal //_IRQL_restores_global_
    sa.toString().matches("%savesIRQLGlobal%") or //saveIRQLGlobal //__drv_savesIRQLGlobal //_IRQL_saves_global_
    sa.toString().matches("%_IRQL_restores_global_%")
  ) and
  exists(SALParameter sp | sp.getAnnotation() = sa)
  or
  (
    sa.toString().matches("%_When_%") or
    sa.toString().matches("%drv_when%")
  ) and
  (
    //_Kernel_clear_do_init_ was not \"yes\" or \"no\"")
    exists(int i |
      sa.getUnexpandedArgument(i).toString().matches("%_Kernel_clear_do_init_%") and
      not sa.getUnexpandedArgument(i).toString().matches("_Kernel_clear_do_init_(%yes%)") and
      not sa.getUnexpandedArgument(i).toString().matches("_Kernel_clear_do_init_(%no%)")
    )
    or
    //__drv_dispatchType cannot be used with __drv_when
    exists(int i | sa.getUnexpandedArgument(i).toString().matches("%__drv_dispatchType%"))
  )
  or
  sa.toString().matches("%_Kernel_clear_do_init_%") and
  not sa.getUnexpandedArgument(0).toString().toLowerCase().matches("\"yes\"") and
  not sa.getUnexpandedArgument(0).toString().toLowerCase().matches("\"no\"")
  or
  //__drv_dispatch value out of range val > 63 || val < -1
  sa.toString().matches("%drv_dispatch%") and
  (
    sa.getUnexpandedArgument(0).toInt() > 63 or
    sa.getUnexpandedArgument(0).toInt() < -1
  )
select sa, "Possible annotation syntax error"
