// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Connect Redirect Callouts
 * @description A callout should call FwpsRedirectHandleCreate0 only once and cache the handle and use it during classify.
 * @platform Desktop
 * @feature.area Multiple
 * @repro.text The following function does not call FwpsRedirectHandleCreate0 or calls it multiple times and does not cache the handle.
 * @kind problem
 * @id cpp/windows/wdk/kmdf/wfp/connect-reirect-handle-creation
 * @problem.severity warning
 * @precision low
 * @tags correctness
 * @query-version v1
 */

import cpp
import drivers.libraries.wfp

class RedirectCalloutFunction extends Function {
    WfpConnectRedirect scr;
    RedirectCalloutFunction() { this.getADeclarationEntry() = scr.getDeclarationEntry() }
}

// Returns TRUE if the callout function is marked as a connect redirect callout and 
// calls FwpsRedirectHandleCreate0 multiple times in the function.

from RedirectCalloutFunction waf
where
    exists(RedirectHandleCreateFunctionCall c | c.getNumberOfCalls() > 1)
select waf,
"A connect redirect callout " + waf.getName() + "calls FwpsRedirectHandleCreate0 multiple times this is a contract violation."