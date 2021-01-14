// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

/**
 * @name Use of deprecated WDK API
 * @description Use of deprecated WDK API detected. 
 * @platform Desktop
 * @security.severity Low
 * @impact Attack Surface Reduction
 * @feature.area Multiple
 * @repro.text The following code locations contain calls to a deprecated WDK API
 * @kind problem
 * @id cpp/windows/wdk/deprecated-api
 * @problem.severity warning
 * @query-version 1.1
 * @owner.email raulga@microsoft.com
 */

import cpp

class WdkDeprecatedApiFunctionCall extends FunctionCall {
    WdkDeprecatedApiFunctionCall() {
          getTarget().hasGlobalName("ExAllocatePoolWithTag")
       or getTarget().hasGlobalName("ExAllocatePool")
       or getTarget().hasGlobalName("ExAllocatePoolWithQuota")
       or getTarget().hasGlobalName("ExAllocatePoolWithQuotaTag")
       or getTarget().hasGlobalName("ExAllocatePoolWithTagPriority")
    }

    string message() {
       if (getTarget().hasGlobalName("ExAllocatePoolWithTag")) then(result = "Using deprecated API '" + getTarget().getQualifiedName() + "'. Replacement function: ExAllocatePool2. For downlevel code, use ExAllocatePoolZero or ExAllocatePoolUninitialized. For details, please visit https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-exallocatepool2")
       else if (getTarget().hasGlobalName("ExAllocatePool")) then(result = "Using deprecated API '" + getTarget().getQualifiedName() + "'. Replacement function: ExAllocatePool2. For downlevel code, use ExAllocatePoolZero or ExAllocatePoolUninitialized. For details, please visit https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-exallocatepool2")
       else if (getTarget().hasGlobalName("ExAllocatePoolWithQuota")) then(result = "Using deprecated API '" + getTarget().getQualifiedName() + "'. Replacement function: ExAllocatePool2 with POOL_FLAG_USE_QUOTA flag. For downlevel code, use ExAllocatePoolWithQuotaZero or ExAllocatePoolWithQuotaUninitialized. For details, please visit https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-exallocatepool2")
       else if (getTarget().hasGlobalName("ExAllocatePoolWithQuotaTag")) then(result = "Using deprecated API '" + getTarget().getQualifiedName() + "'. Replacement function: ExAllocatePool2 with POOL_FLAG_USE_QUOTA flag. For downlevel code, use ExAllocatePoolWithQuotaZero or ExAllocatePoolWithQuotaUninitialized. For details, please visit https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-exallocatepool2")
       else if (getTarget().hasGlobalName("ExAllocatePoolWithTagPriority")) then(result = "Using deprecated API '" + getTarget().getQualifiedName() + "'. Replacement function: ExAllocatePool3. For downlevel code, use ExAllocatePoolPriorityZero or ExAllocatePoolPriorityUninitialized. For details, please visit https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-exallocatepool3")
       else (result = "Using deprecated API '" + getTarget().getQualifiedName() + "'.")
    }
}

from WdkDeprecatedApiFunctionCall deprecatedCall
where not deprecatedCall.getLocation().getFile().toString().matches("%ex_x.h")
select deprecatedCall, deprecatedCall.message()
