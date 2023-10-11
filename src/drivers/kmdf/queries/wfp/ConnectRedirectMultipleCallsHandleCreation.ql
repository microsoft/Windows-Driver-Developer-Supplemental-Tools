import cpp
import drivers.libraries.wfp

// CORRECT AND FUNCTIONING (mostly)- make this a runtime check seems more performance related

// Contract
// A callout should call FwpsRedirectHandleCreate0 only once and cache the handle and use it during classify.

// Returns TRUE if the callout function is marked as a connect redirect callout and 
// calls FwpsRedirectHandleCreate0 multiple times in the function.

// from RedirectionClassify waf
// where
//     isWfpConnectRedirectClassifyCall(waf) and 
//     exists(RedirectHandleCreateFunctionCall c | c.getNumberOfCalls() > 1)
// select waf,
// "A connect redirect callout " + waf.getName() + "calls FwpsRedirectHandleCreate0 multiple times this is a contract violation."