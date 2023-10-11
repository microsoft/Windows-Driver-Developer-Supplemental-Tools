import cpp
import drivers.libraries.wfp

// CORRECT AND FUNCTIONING

// MIGHT also be applicable to STREAM double check this

// Contract
// If a callout pends a classify by calling FwpsPendClassify0, the callout must set action to 
// FWP_ACTION_BLOCK and clear the FWPS_RIGHT_ACTION_WRITE right flag. This is to let other 
// (lower weight) callouts know that they shouldn’t take any action while the classify is pending

// Return TRUE if a connect/redirect layer was tagged and FwpsPendClassify is called and
// FWP_ACTION_BLOCK or FWPS_RIGHT_ACTION_WRITE right flag is NOT set. 

predicate matchesPendClassifyApi(string input) {
    input = any(["FwpsPendClassify", "FwpsPendClassify0"])
 }

 class FwpsPendClassifyApi extends Function {
    string name;
    FwpsPendClassifyApi() {
        matchesPendClassifyApi(this.getName()) and
        name = this.getName()
    }
 }

 class FwpsPendClassifyApiCall extends FunctionCall {
    FwpsPendClassifyApiCall(){ this.getTarget() instanceof FwpsPendClassifyApi}
 }

 class FwpsPendClassifyCall extends Element {
    string name;
    FwpsPendClassifyCall() {
        name = this.(FwpsPendClassifyApiCall).getTarget().getName()
    }
 }


from RedirectionClassify waf
where
    isWfpConnectRedirectClassifyCall(waf) and 
    exists(FwpsPendClassifyCall pend) and 
    (not exists(ActionTypeExprBlock exp) or
    not exists(WriteActionFlagSet flag))

select waf,
    "A connect redirect callout " + waf.getName() + "called FwpsPendClassify0 and does not FWP_ACTION BLOCK or  FWPS_RIGHT_ACTION_WRITE flag."