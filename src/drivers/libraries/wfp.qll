// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

 import cpp
 import drivers.libraries.SAL

class WFPTypeDefinition extends MacroInvocation {
    string wfpAnnotationName;
    WFPTypeDefinition() {
      this.getMacroName().matches(["\\_Wfp_%\\_"]) and
      wfpAnnotationName = this.getMacroName()
    }

    string getWfpMacroName() { result = wfpAnnotationName }
}

// Stream annotation
class WfpStreamAnnotation extends MacroInvocation {
    string wfpAnnotationName;

    WfpStreamAnnotation() {
      this.getMacroName().matches(["__wfp_stream_inspection_notify", "__wfp_stream_inspection_classify", "__wfp_stream_injection_classify"]) and
      wfpAnnotationName = this.getMacroName() and
      exists(MacroInvocation mi | mi.getParentInvocation() = this)
    }
  
    string getWfpMacroName() { result = wfpAnnotationName }
}

// Stream Macro queries
class WFPCheckStreamNotify extends WfpStreamAnnotation {
    WFPCheckStreamNotify() {
        this.getWfpMacroName().matches(["__wfp_stream_inspection_notify"])
    }
}

// We might break this one into 2 depending on contract requirements
class WFPCheckStreamClassify extends WfpStreamAnnotation {
    WFPCheckStreamClassify(){
        this.getWfpMacroName().matches(["__wfp_stream_inspection_classify", "__wfp_stream_injection_classify"])
    }
}

// Transport annotation
class WfpTransportAnnotation extends SALAnnotation {
    string wfpAnnotationName;

    WfpTransportAnnotation() {
      this.getMacroName().matches(["__wfp_Transport_inspection_notify", "__wfp_transport_inspection_classify"]) and
      wfpAnnotationName = this.getMacroName() and
      exists(MacroInvocation mi | mi.getParentInvocation() = this)
    }
  
    string getWfpMacroName() { result = wfpAnnotationName }
}

class WFPCheckTransportNotify extends WfpTransportAnnotation {
    WFPCheckTransportNotify(){
        this.getWfpMacroName().matches(["__wfp_Transport_inspection_notify"])
    }
}

class WFPCheckTransportClassify extends WfpTransportAnnotation {
    WFPCheckTransportClassify(){
        this.getWfpMacroName().matches(["__wfp_transport_inspection_classify"])
    }
}

// Flow annotation
class WfpFlowAnnotation extends SALAnnotation {
    string wfpAnnotationName;

    WfpFlowAnnotation() {
      this.getMacroName().matches(["__wfp_flow_inspection_notify", "__wfp_flow_inspection_classify", "__wfp_flow_injection_classify"]) and
      wfpAnnotationName = this.getMacroName() and
      exists(MacroInvocation mi | mi.getParentInvocation() = this)
    }
  
    string getWfpMacroName() { result = wfpAnnotationName }
}

class WFPCheckFlowNotify extends WfpFlowAnnotation {
    WFPCheckFlowNotify(){
        this.getWfpMacroName().matches(["__wfp_flow_inspection_notify"])
    }
}

// May split this 
class WFPCheckFlowClassify extends WfpFlowAnnotation {
    WFPCheckFlowClassify(){
        this.getWfpMacroName().matches(["__wfp_flow_inspection_classify", "__wfp_flow_injection_classify"])
    }
}

// ALE annotation
class WfpAleAnnotation extends SALAnnotation {
    string wfpAnnotationName;

    WfpAleAnnotation() {
      this.getMacroName().matches(["__wfp_ale_inspection_notify", "__wfp_ale_inspection_classify"]) and
      wfpAnnotationName = this.getMacroName() and
      exists(MacroInvocation mi | mi.getParentInvocation() = this)
    }
  
    string getWfpMacroName() { result = wfpAnnotationName }
}

// ALE Macro queries
class WFPCheckAleNotify extends WfpAleAnnotation {
    WFPCheckAleNotify(){
        this.getWfpMacroName().matches(["__wfp_ale_inspection_notify"])
    }
}

class WFPCheckAleClassify extends WfpAleAnnotation {
    WFPCheckAleClassify(){
        this.getWfpMacroName().matches(["__wfp_ale_inspection_classify"])
    }
}

// Represents a WFP annotated function
class WfpAnnotatedFunction extends Function {
    string funcWfpAnnotationName;

    WfpAnnotatedFunction() {
        exists(WFPTypeDefinition wfpa, FunctionDeclarationEntry fde |
            fde = this.getADeclarationEntry() and
            funcWfpAnnotationName = wfpa.getWfpMacroName())
    }

    string getFuncWfpAnnotationName() { result = funcWfpAnnotationName }
}

// Predicates for WFP functions
predicate isWfpCall(Function f) {
    f instanceof WfpAnnotatedFunction
}

// Evaluates to TRUE if the function is a Stream inspection notify function
predicate isWfpStreamInspectionNotifyCall(WfpAnnotatedFunction f){
    isWfpCall(f) and
    f.getFuncWfpAnnotationName().matches(["_Wfp_stream_inspection_notify_"])
}

// Evaluates to TRUE if the function is a Stream Injection classify function
predicate isWfpStreamInjectionClassifyCall(WfpAnnotatedFunction f){
    isWfpCall(f) and
    f.getFuncWfpAnnotationName().matches(["_Wfp_stream_injection_classify_"])
}

// Evaluates to TRUE if the function is a Stream Inspection classify function
predicate isWfpStreamInspectionClassifyCall(WfpAnnotatedFunction f){
    isWfpCall(f) and
    f.getFuncWfpAnnotationName().matches(["_Wfp_stream_inspection_classify_"])
}

// Evaluates to TRUE if the function is a Flow inspection notify function
predicate isWfpFlowInspectionNotifyCall(WfpAnnotatedFunction f){
    isWfpCall(f) and
    f.getFuncWfpAnnotationName().matches(["_Wfp_flow_inspection_notify_"])
}

// Evaluates to TRUE if the function is a Flow Inspection classify function
predicate isWfpFlowInspectionClassifyCall(WfpAnnotatedFunction f){
    isWfpCall(f) and
    f.getFuncWfpAnnotationName().matches(["_Wfp_flow_inspection_classify_"])
}

// Evalutes to TRUE if the function Flow Injection classify function
predicate isWfpFlowInjectionClassifyCall(WfpAnnotatedFunction f){
    isWfpCall(f) and
    f.getFuncWfpAnnotationName().matches(["_Wfp_flow_injection_classify_"])
}

// Evaluates to TRUE if the function is a Transport Inspection Classify function
predicate isWfpTransportInspectionClassifyCall(WfpAnnotatedFunction f){
    isWfpCall(f) and
    f.getFuncWfpAnnotationName().matches(["_Wfp_Transport_inspection_classify_"])
}

// Evaluates to TRUE if the function is a Transport Injection classify function
predicate isWfpTransportInjectionClassifyCall(WfpAnnotatedFunction f){
    isWfpCall(f) and
    f.getFuncWfpAnnotationName().matches(["_Wfp_transport_injection_classify_"])
}

predicate isWfpTransportInjectionInlineClassifyCall(WfpAnnotatedFunction f){
    isWfpCall(f) and
    f.getFuncWfpAnnotationName().matches(["_Wfp_transport_injection_classify_inline_"])
}

// Evaluates to TRUE if the function is a ALE inspection notify function
predicate isWfpAleInspectionNotifyCall(WfpAnnotatedFunction f){
    isWfpCall(f) and
    f.getFuncWfpAnnotationName().matches(["_Wfp_ale_inspection_notify_"])
}

// Evaluates to TRUE if the function is a ALE inspection classify function
predicate isWfpAleInspectionClassifyCall(WfpAnnotatedFunction f){
    isWfpCall(f) and
    f.getFuncWfpAnnotationName().matches(["_Wfp_ale_inspection_classify_"])
}

// Evaluates to TRUE if the function is marked as an inline classify function in the 
// connect redirect layers
predicate isWfpInlineConnectRedirectClassifyCall(WfpAnnotatedFunction f){
    isWfpCall(f) and
    f.getFuncWfpAnnotationName().matches(["_Wfp_connect_redirect_inline_classify_"])
}


predicate isWfpConnectRedirectClassifyCall(WfpAnnotatedFunction f){
    isWfpCall(f) and
    (f.getFuncWfpAnnotationName().matches(["_Wfp_connect_redirect_classify_"]) or 
    isWfpInlineConnectRedirectClassifyCall(f))
}

// predicate to find the classify out structure.
class ClassifyOut extends Struct {
    ClassifyOut() {
        this.getName().matches("FWPS_CLASSIFY_OUT")
    }
}

class WfpAction extends Struct {
    WfpAction() {
      this.getName().matches("FWP_ACTION_TYPE")
    }
  }

class ActionTypeAccess extends Assignment {
    FieldAccess accessedField;

    ActionTypeAccess() {
        this.getLValue() = accessedField and 
        accessedField.getTarget().getDeclaringType().toString().matches("FWP_ACTION_TYPE")
    }
}

// predicates for finding specific API calls
predicate matchesStreamContinueApiCall(string input) {
    input = any(["FwpsStreamContinue0", "FwpsStreamContinue"])
}

predicate matchesStreamInjectApiCall(string input) {
    input = any(["FwpsStreamInjectAsync0", "FwpsStreamInjectAsync"])
} 

class ExtendedStreamContinueCall extends FunctionCall {
    ExtendedStreamContinueCall() {this.getTarget() instanceof StreamContinue}
}

class StreamContinue extends Function {
    string name;

    StreamContinue() {
        matchesStreamContinueApiCall(this.getName()) and
        name = this.getName()
    }
}

class StreamInject extends WfpAnnotatedFunction {
    string name;
    LocalScopeVariable par;
  
    StreamInject() {
        name = this.getName() and 
        exists(LocalScopeVariable p |
        p.getType().getName().matches("FWPS_CLASSIFY_OUT%")  and
        par = p) and 
        isWfpStreamInjectionClassifyCall(this)
    }
}

class RedirectHandleCreateFunctionCall extends MetricFunction {
    RedirectHandleCreateFunctionCall() {
            this.getQualifiedName().toString().matches(["FwpsRedirectHandleCreate%"])
    }
}

  predicate doesStreamInjectAsyncCallExist()
{
    exists(FunctionCall c |
        c.toString().matches(["FwpsStreamInjectAsync%"]))
}

// Transport Injection stuff
class InlineTransportInjection extends WfpAnnotatedFunction {
    string name;
  
    InlineTransportInjection() {
        name = this.getName() and 
        isWfpTransportInspectionClassifyCall(this)
    }
}

// Transport Injection stuff
class TransportInjection extends WfpAnnotatedFunction {
    string name;
  
   TransportInjection() {
        name = this.getName() and 
        isWfpTransportInjectionClassifyCall(this)
    }
}

class ActionTypeExpr extends AssignExpr{
    ActionTypeExpr(){
        this.getLValue().getType().getName().matches(["FWP_ACTION_TYPE"]) and 
        this.getRValue().getType().getName().matches(["FWP_ACTION_TYPE"])
    }
  }

  class FlowEstablished extends WfpAnnotatedFunction {
    string name;
    LocalScopeVariable par;
  
    FlowEstablished() {
        name = this.getName() and 
        exists(LocalScopeVariable p |
        p.getType().getName().matches("FWPS_CLASSIFY_OUT%")  and
        par = p) and 
        isWfpFlowInspectionClassifyCall(this)
    }
}

class RedirectionClassify extends WfpAnnotatedFunction
{
    string name;

    RedirectionClassify() {
        name = this.getName() and
        isWfpConnectRedirectClassifyCall(this)
    }
}

class InlineRedirectionClassify extends WfpAnnotatedFunction
{
    string name;

    InlineRedirectionClassify() {
        name = this.getName() and
        isWfpInlineConnectRedirectClassifyCall(this)
    }
}

class ActionTypeExprBlock extends AssignExpr{
    ActionTypeExprBlock(){
        this.getLValue().getType().getName().matches(["FWP_ACTION_TYPE"]) and 
        this.getRValue().getFullyConverted().getValue().toInt() = 4097 //FWP_ACTION_BLOCK
    }
  }

class WriteActionFlagSet extends AssignExpr {
    WriteActionFlagSet(){
        this.getLValue().getType().getName().matches(["UINT32"]) and
        this.getRValue().getFullyConverted().getValue().toInt() = 1 //FWPS_RIGHT_ACTION_WRITE
    }
}

class ClassifyReauthorizeFlag extends AssignExpr {
    ClassifyReauthorizeFlag(){
        this.getLValue().getType().getName().matches(["UINT32"]) and
        this.getRValue().getFullyConverted().getType().getName().matches(["FWPS_CLASSIFY_FLAG_REAUTHORIZE_IF_MODIFIED_BY_OTHERS"])
    }
}