// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Connect Redirect Inline Callout cannot set reauth
 * @description Checks that an Inline Connect Redirect Callout does not ask for reauthorization
 * @platform Desktop
 * @feature.area Multiple
 * @repro.text The following function asks for reauthorization and is an inline callout this is a contract violation
 * @kind problem
 * @id cpp/windows/wdk/kmdf/wfp/inline-connect-redirect
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @query-version v1
 */

 import cpp
 import drivers.libraries.wfp

// Contract
// Inline callout shouldn’t ask for re-authorization i.e., 
// shouldn’t set FWPS_CLASSIFY_FLAG_REAUTHORIZE_IF_MODIFIED_BY_OTHERS

// Returns TRUE if the callout function is a inline callout in 
// the connect redirect layers and sets the 
// FWPS_CLASSIFY_FLAG_REAUTHORIZE_IF_MODIFIED_BY_OTHERS flag

class WfpConnectRedirectInline extends WfpAnnotation {
  WfpConnectRedirectInline() {
    this.getMacro().(WfpMacro).getName() = ["_Wfp_connect_redirect_inline_classify_"]
  }
}

class ConnectRedirectClassifyFunction extends Function {
    WfpConnectRedirectInline src;
    ConnectRedirectClassifyFunction() { this.getADeclarationEntry() = src.getDeclarationEntry()}
}

class ClassifyReauthorizeFlag extends AssignExpr {
    ClassifyReauthorizeFlag(){
        this.getLValue().getType().getName().matches(["UINT32"]) and
        this.getRValue().getFullyConverted().getType().getName().matches(["FWPS_CLASSIFY_FLAG_REAUTHORIZE_IF_MODIFIED_BY_OTHERS"])
    }
}

from ConnectRedirectClassifyFunction waf
where
    exists(ClassifyReauthorizeFlag flag)
select waf,
"A connect redirect callout " + waf.getName() + " is marked inline and sets FWPS_CLASSIFY_FLAG_REAUTHORIZE_IF_MODIFIED_BY_OTHERS. This is a contract violation."