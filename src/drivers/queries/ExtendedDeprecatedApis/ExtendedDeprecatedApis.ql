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
 * @query-version 1.2
 */

import cpp

class ExtendedDeprecatedApiCall extends FunctionCall {
  ExtendedDeprecatedApiCall() { this.getTarget() instanceof ExtendedDeprecatedApi }
}

class ExtendedDeprecatedApi extends Function {
  string name;

  ExtendedDeprecatedApi() {
    this.getName()
        .matches([
            "_fstrcat", "_fstrcpy", "_fstrncat", "_fstrncpy", "_ftccat", "_ftccpy", "_ftcscat",
            "_ftcscpy", "_getts", "_gettws", "_getws", "_mbccat", "_makepath", "_mbscat",
            "_snprintf", "_sntprintf", "_sntscanf", "_snwprintf", "_splitpath", "_stprintf",
            "_stscanf", "_tccat", "_tccpy", "_tcscat", "_tcscpy", "_tcsncat", "_tcsncpy",
            "_tmakepath", "_tscanf", "_tsplitpath", "_vsnprintf", "_vsntprintf", "_vsnwprintf",
            "_vstprintf", "_wmakepath", "_wsplitpath", "OemToCharW", "StrCat", "StrCatA",
            "StrCatBuff", "StrCatBuffA", "StrCatBuffW", "StrCatChainW", "StrCatN", "StrCatNA",
            "StrCatNW", "StrCatW", "StrCpy", "StrCpyA", "StrCpyN", "StrCpyNA", "StrCpyNW",
            "strcpyW", "StrCpyW", "StrNCat", "StrNCatA", "StrNCatW", "StrNCpy", "StrNCpyA",
            "StrNCpyW", "gets", "lstrcat", "lstrcatA", "lstrcatn", "lstrcatnA", "lstrcatnW",
            "lstrcatW", "lstrcpy", "lstrcpyA", "lstrcpyn", "lstrcpynA", "lstrcpynW", "lstrcpyW",
            "snscanf", "snwscanf", "sprintf", "sprintfA", "sprintfW", "lstrncat", "makepath",
            "nsprintf", "strcat", "strcatA", "strcatW", "strcpy", "strcpyA", "strncat", "strncpy",
            "swprintf", "ualstrcpyW", "vsnprintf", "vsprintf", "vswprintf", "wcscat", "wcscpy",
            "wcsncat", "wcsncpy", "wnsprintf", "wnsprintfA", "wsprintf", "wsprintfA", "wsprintfW",
            "wvnsprintf", "wvnsprintfA", "wvnsprintfW", "wvsprintf", "wvsprintfA", "wvsprintfW"
          ]) and
    name = this.getName()
  }
}

class ExtendedDeprecatedMacro extends Macro {
  string name;

  ExtendedDeprecatedMacro() {
    this.getName()
        .matches([
            "_fstrcat", "_fstrcpy", "_fstrncat", "_fstrncpy", "_ftccat", "_ftccpy", "_ftcscat",
            "_ftcscpy", "_getts", "_gettws", "_getws", "_mbccat", "_makepath", "_mbscat",
            "_snprintf", "_sntprintf", "_sntscanf", "_snwprintf", "_splitpath", "_stprintf",
            "_stscanf", "_tccat", "_tccpy", "_tcscat", "_tcscpy", "_tcsncat", "_tcsncpy",
            "_tmakepath", "_tscanf", "_tsplitpath", "_vsnprintf", "_vsntprintf", "_vsnwprintf",
            "_vstprintf", "_wmakepath", "_wsplitpath", "OemToCharW", "StrCat", "StrCatA",
            "StrCatBuff", "StrCatBuffA", "StrCatBuffW", "StrCatChainW", "StrCatN", "StrCatNA",
            "StrCatNW", "StrCatW", "StrCpy", "StrCpyA", "StrCpyN", "StrCpyNA", "StrCpyNW",
            "strcpyW", "StrCpyW", "StrNCat", "StrNCatA", "StrNCatW", "StrNCpy", "StrNCpyA",
            "StrNCpyW", "gets", "lstrcat", "lstrcatA", "lstrcatn", "lstrcatnA", "lstrcatnW",
            "lstrcatW", "lstrcpy", "lstrcpyA", "lstrcpyn", "lstrcpynA", "lstrcpynW", "lstrcpyW",
            "snscanf", "snwscanf", "sprintf", "sprintfA", "sprintfW", "lstrncat", "makepath",
            "nsprintf", "strcat", "strcatA", "strcatW", "strcpy", "strcpyA", "strncat", "strncpy",
            "swprintf", "ualstrcpyW", "vsnprintf", "vsprintf", "vswprintf", "wcscat", "wcscpy",
            "wcsncat", "wcsncpy", "wnsprintf", "wnsprintfA", "wsprintf", "wsprintfA", "wsprintfW",
            "wvnsprintf", "wvnsprintfA", "wvnsprintfW", "wvsprintf", "wvsprintfA", "wvsprintfW"
          ]) and
    name = this.getName()
  }
}

class ExtendedDeprecatedMacroInvocation extends MacroInvocation {
  ExtendedDeprecatedMacroInvocation() { this.getMacro() instanceof ExtendedDeprecatedMacro }
}

class ExtendedDeprecatedCall extends Element {
  string name;

  ExtendedDeprecatedCall() {
    name = this.(ExtendedDeprecatedMacroInvocation).getMacroName()
    or
    name = this.(ExtendedDeprecatedApiCall).getTarget().getName()
  }

  string getMessage() {
    result = "TODO: Display appropriate replacement guidance"
  }
}

from ExtendedDeprecatedCall deprecatedCall
where not deprecatedCall.getLocation().getFile().toString().matches("%ex_x.h")
select deprecatedCall, deprecatedCall.getFile().getBaseName()
