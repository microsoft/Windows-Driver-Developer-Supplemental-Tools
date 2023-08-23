// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/wdk-deprecated-api
 * @kind problem
 * @name Use of deprecated WDK API
 * @description Use of deprecated allocation APIs can result in non-zeroed memory being provided to the caller.
 * @platform Desktop
 * @security.severity Medium
 * @impact Attack Surface Reduction
 * @feature.area Multiple
 * @repro.text The following code locations contain calls to a deprecated WDK allocation API.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-D0001
 * @problem.severity warning
 * @precision high
 * @tags security
 *       wddst
 * @scope domainspecific
 * @query-version 1.3
 */

import cpp

/** Either a macro invocation of a deprecated allocation API, or a direct function call to a deprecated allocation API. */
abstract class WdkDeprecatedApiCall extends Element {
  /** Returns a message suggesting replacement APIs when calling a deprecated API. */
  abstract string getMessage();
}

/** A function call to a now-deprecated memory allocation API. */
class WdkDeprecatedApiFunctionCall extends FunctionCall, WdkDeprecatedApiCall {
  WdkDeprecatedApiFunctionCall() {
    getTarget().hasGlobalName("ExAllocatePoolWithTag") or
    getTarget().hasGlobalName("ExAllocatePool") or
    getTarget().hasGlobalName("ExAllocatePoolWithQuota") or
    getTarget().hasGlobalName("ExAllocatePoolWithQuotaTag") or
    getTarget().hasGlobalName("ExAllocatePoolWithTagPriority")
  }

  override string getMessage() {
    if getTarget().hasGlobalName("ExAllocatePoolWithTag")
    then
      result =
        "Using deprecated API '" + getTarget().getQualifiedName() +
          "'. Replacement function: ExAllocatePool2. For downlevel code, use ExAllocatePoolZero or ExAllocatePoolUninitialized. Do not use `POOL_FLAG_UNINITIALIZED` flag when fixing. For details, please visit https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-exallocatepool2"
    else
      if getTarget().hasGlobalName("ExAllocatePool")
      then
        result =
          "Using deprecated API '" + getTarget().getQualifiedName() +
            "'. Replacement function: ExAllocatePool2. For downlevel code, use ExAllocatePoolZero or ExAllocatePoolUninitialized. Do not use `POOL_FLAG_UNINITIALIZED` flag when fixing. For details, please visit https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-exallocatepool2"
      else
        if getTarget().hasGlobalName("ExAllocatePoolWithQuota")
        then
          result =
            "Using deprecated API '" + getTarget().getQualifiedName() +
              "'. Replacement function: ExAllocatePool2 with POOL_FLAG_USE_QUOTA flag. For downlevel code, use ExAllocatePoolWithQuotaZero or ExAllocatePoolWithQuotaUninitialized. Do not use `POOL_FLAG_UNINITIALIZED` flag when fixing. For details, please visit https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-exallocatepool2"
        else
          if getTarget().hasGlobalName("ExAllocatePoolWithQuotaTag")
          then
            result =
              "Using deprecated API '" + getTarget().getQualifiedName() +
                "'. Replacement function: ExAllocatePool2 with POOL_FLAG_USE_QUOTA flag. For downlevel code, use ExAllocatePoolWithQuotaZero or ExAllocatePoolWithQuotaUninitialized. Do not use `POOL_FLAG_UNINITIALIZED` flag when fixing. For details, please visit https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-exallocatepool2"
          else
            if getTarget().hasGlobalName("ExAllocatePoolWithTagPriority")
            then
              result =
                "Using deprecated API '" + getTarget().getQualifiedName() +
                  "'. Replacement function: ExAllocatePool3. For downlevel code, use ExAllocatePoolPriorityZero or ExAllocatePoolPriorityUninitialized. Do not use `POOL_FLAG_UNINITIALIZED` flag when fixing. For details, please visit https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-exallocatepool3"
            else result = "Using deprecated API '" + getTarget().getQualifiedName() + "'."
  }
}

/** A macro version of the deprecated allocation APIs. */
class WdkDeprecatedMacro extends Macro {
  WdkDeprecatedMacro() {
    this.getName()
        .matches([
            "ExAllocatePoolWithTag", "ExAllocatePool", "ExAllocatePoolWithQuota",
            "ExAllocatePoolWithQuotaTag", "ExAllocatePoolWithTagPriority"
          ])
  }

  /** A message suggesting replacement APIs when calling a deprecated API. */
  string message() {
    if this.getName().matches("ExAllocatePoolWithTag")
    then
      result =
        "Using deprecated API '" + this.getName() +
          "'. Replacement function: ExAllocatePool2. For downlevel code, use ExAllocatePoolZero or ExAllocatePoolUninitialized. Do not use `POOL_FLAG_UNINITIALIZED` flag when fixing. For details, please visit https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-exallocatepool2"
    else
      if this.getName().matches("ExAllocatePool")
      then
        result =
          "Using deprecated API '" + this.getName() +
            "'. Replacement function: ExAllocatePool2. For downlevel code, use ExAllocatePoolZero or ExAllocatePoolUninitialized. Do not use `POOL_FLAG_UNINITIALIZED` flag when fixing. For details, please visit https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-exallocatepool2"
      else
        if this.getName().matches("ExAllocatePoolWithQuota")
        then
          result =
            "Using deprecated API '" + this.getName() +
              "'. Replacement function: ExAllocatePool2 with POOL_FLAG_USE_QUOTA flag. For downlevel code, use ExAllocatePoolWithQuotaZero or ExAllocatePoolWithQuotaUninitialized. Do not use `POOL_FLAG_UNINITIALIZED` flag when fixing. For details, please visit https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-exallocatepool2"
        else
          if this.getName().matches("ExAllocatePoolWithQuotaTag")
          then
            result =
              "Using deprecated API '" + this.getName() +
                "'. Replacement function: ExAllocatePool2 with POOL_FLAG_USE_QUOTA flag. For downlevel code, use ExAllocatePoolWithQuotaZero or ExAllocatePoolWithQuotaUninitialized. Do not use `POOL_FLAG_UNINITIALIZED` flag when fixing. For details, please visit https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-exallocatepool2"
          else
            if this.getName().matches("ExAllocatePoolWithTagPriority")
            then
              result =
                "Using deprecated API '" + this.getName() +
                  "'. Replacement function: ExAllocatePool3. For downlevel code, use ExAllocatePoolPriorityZero or ExAllocatePoolPriorityUninitialized. Do not use `POOL_FLAG_UNINITIALIZED` flag when fixing. For details, please visit https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-exallocatepool3"
            else result = "Using deprecated API '" + this.getName() + "'."
  }
}

/** A macro invocation of a deprecated allocation API. */
class WdkDeprecatedApiMacroInvocation extends MacroInvocation, WdkDeprecatedApiCall {
  WdkDeprecatedApiMacroInvocation() { this.getMacro() instanceof WdkDeprecatedMacro }

  override string getMessage() { result = this.getMacro().(WdkDeprecatedMacro).message() }
}

from WdkDeprecatedApiCall call
where
  // To avoid result duplication, exclude calls that are the result of expanding a deprecated macro
  not (
    call instanceof WdkDeprecatedApiFunctionCall and
    exists(WdkDeprecatedApiMacroInvocation containingMi |
      containingMi.getAnExpandedElement() = call
    )
  )
select call, call.getMessage()
