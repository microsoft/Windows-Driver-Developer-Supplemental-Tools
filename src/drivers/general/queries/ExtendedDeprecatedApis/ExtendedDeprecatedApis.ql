// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Use of deprecated function or macro (C28719, C28726, C28750)
 * @description Unsafe, deprecated APIs should not be used.  This is a port of Code Analysis checks C28719, C28726, and C28750.
 * @platform Desktop
 * @security.severity Low
 * @impact Attack Surface Reduction
 * @feature.area Multiple
 * @repro.text The following code locations contain calls to an unsafe, deprecated function or macro.
 * @kind problem
 * @id cpp/windows/drivers/queries/extended-deprecated-apis
 * @problem.severity warning
 * @precision high
 * @tags correctness
 * @query-version v1
 */

import cpp

class ExtendedDeprecatedApiCall extends FunctionCall {
  ExtendedDeprecatedApiCall() { this.getTarget() instanceof ExtendedDeprecatedApi }
}

predicate matchesBannedApi(string input) {
  // Functions marked deprecated in C28719
  input =
    any([
          "_fstrcat", "_fstrcpy", "_fstrncat", "_fstrncpy", "_ftccat", "_ftccpy", "_ftcscat",
          "_ftcscpy", "_getts", "_gettws", "_getws", "_mbccat", "_makepath", "_mbscat", "_snprintf",
          "_sntprintf", "_sntscanf", "_snwprintf", "_splitpath", "_stprintf", "_stscanf", "_tccat",
          "_tccpy", "_tcscat", "_tcscpy", "_tcsncat", "_tcsncpy", "_tmakepath", "_tscanf",
          "_tsplitpath", "_vsnprintf", "_vsntprintf", "_vsnwprintf", "_vstprintf", "_wmakepath",
          "_wsplitpath", "OemToCharW", "StrCat", "StrCatA", "StrCatBuff", "StrCatBuffA",
          "StrCatBuffW", "StrCatChainW", "StrCatN", "StrCatNA", "StrCatNW", "StrCatW", "StrCpy",
          "StrCpyA", "StrCpyN", "StrCpyNA", "StrCpyNW", "strcpyW", "StrCpyW", "StrNCat", "StrNCatA",
          "StrNCatW", "StrNCpy", "StrNCpyA", "StrNCpyW", "gets", "lstrcat", "lstrcatA", "lstrcatn",
          "lstrcatnA", "lstrcatnW", "lstrcatW", "lstrcpy", "lstrcpyA", "lstrcpyn", "lstrcpynA",
          "lstrcpynW", "lstrcpyW", "snscanf", "snwscanf", "sprintf", "sprintfA", "sprintfW",
          "lstrncat", "makepath", "nsprintf", "strcat", "strcatA", "strcatW", "strcpy", "strcpyA",
          "strncat", "strncpy", "swprintf", "ualstrcpyW", "vsnprintf", "vsprintf", "vswprintf",
          "wcscat", "wcscpy", "wcsncat", "wcsncpy", "wnsprintf", "wnsprintfA", "wsprintf",
          "wsprintfA", "wsprintfW", "wvnsprintf", "wvnsprintfA", "wvnsprintfW", "wvsprintf",
          "wvsprintfA", "wvsprintfW"
        ]
    )
  or
  // Functions marked deprecated in C28726
  input =
    any([
          "_itoa", "_i64toa", "_i64tow", "_mbccpy", "_mbscpy", "_mbsnbcpy", "_mbsnbcat", "_mbsncat",
          "_mbsncpy", "_mbstok", "_snscanf", "_snwscanf", "_ui64toa", "_ui64tow", "_ultoa",
          "CharToOemA", "CharToOemBuffA", "CharToOemBuffW", "CharToOemW", "OemToCharA",
          "OemToCharBuffA", "OemToCharBuffW", "scanf", "sscanf", "wmemcpy", "wnsprintfW", "wscanf"
        ]
    )
  or
  // Functions marked deprecated in C28750
  input = any(["lstrlen", "lstrlenA", "lstrlenW"])
}

class ExtendedDeprecatedApi extends Function {
  string name;

  ExtendedDeprecatedApi() {
    matchesBannedApi(this.getName()) and
    name = this.getName()
  }
}

class ExtendedDeprecatedMacro extends Macro {
  string name;

  ExtendedDeprecatedMacro() {
    matchesBannedApi(this.getName()) and
    name = this.getName()
  }
}

class ExtendedDeprecatedMacroInvocation extends MacroInvocation {
  ExtendedDeprecatedMacroInvocation() { this.getMacro() instanceof ExtendedDeprecatedMacro }
}

class ExtendedDeprecatedCall extends Element {
  string name;
  string replacement;

  ExtendedDeprecatedCall() {
    (
      name = this.(ExtendedDeprecatedMacroInvocation).getMacroName()
      or
      name = this.(ExtendedDeprecatedApiCall).getTarget().getName()
    ) and
    (
      (
        name.matches("_fstrcat") and replacement = "None"
        or
        name.matches("_fstrcpy") and replacement = "None"
        or
        name.matches("_fstrncat") and replacement = "None"
        or
        name.matches("_fstrncpy") and replacement = "None"
        or
        name.matches("_ftccat") and replacement = "None"
        or
        name.matches("_ftccpy") and replacement = "None"
        or
        name.matches("_ftcscat") and replacement = "None"
        or
        name.matches("_ftcscpy") and replacement = "None"
        or
        name.matches("_getts") and
        replacement = "StringCbGets, StringCbGetsEx, StringCchGets, StringCchGetsEx, gets_s"
        or
        name.matches("_gettws") and replacement = "gets_s"
        or
        name.matches("_getws") and replacement = "_getws_s"
        or
        name.matches("_mbccat") and replacement = "None"
        or
        name.matches("_makepath") and replacement = "_makepath_s"
        or
        name.matches("_mbscat") and replacement = "_mbscat_s"
        or
        name.matches("_snprintf") and replacement = "_snprintf_s"
        or
        name.matches("_sntprintf") and replacement = "None"
        or
        name.matches("_sntscanf") and replacement = "None"
        or
        name.matches("_snwprintf") and
        replacement =
          "_snwprintf_s, StringCbPrintf, StringCbPrintf_l, StringCbPrintf_lEx, StringCbPrintfEx, StringCchPrintf, StringCchPrintfEx"
        or
        name.matches("_splitpath") and replacement = "_splitpath_s"
        or
        name.matches("_stprintf") and
        replacement =
          "StringCbPrintf, StringCbPrintf_l, StringCbPrintf_lEx, StringCbPrintfEx, StringCchPrintf, StringCchPrintfEx"
        or
        name.matches("_stscanf") and replacement = "None"
        or
        name.matches("_tccat") and replacement = "None"
        or
        name.matches("_tccpy") and replacement = "None"
        or
        name.matches("_tcscat") and replacement = "None"
        or
        name.matches("_tcscpy") and
        replacement = "StringCbCopy, StringCbCopyEx, StringCchCopy, StringCchCopyEx"
        or
        name.matches("_tcsncat") and replacement = "None"
        or
        name.matches("_tcsncpy") and
        replacement = "StringCbCopyN, StringCbCopyNEx, StringCchCopyN, StringCchCopyNEx"
        or
        name.matches("_tmakepath") and replacement = "None"
        or
        name.matches("_tscanf") and replacement = "None"
        or
        name.matches("_tsplitpath") and replacement = "None"
        or
        name.matches("_vsnprintf") and
        replacement =
          "_vsnprintf_s, StringCchVPrintf, StringCchVPrintf_l, StringCchVPrintf_lEx, StringCchVPrintfEx"
        or
        name.matches("_vsntprintf") and
        replacement =
          "StringCbVPrintf, StringCbVPrintf_l, StringCbVPrintf_lEx, StringCbVPrintfEx, StringCchVPrintf, StringCchVPrintf_l, StringCchVPrintf_lEx, StringCchVPrintfEx"
        or
        name.matches("_vsnwprintf") and
        replacement =
          "_vsnwprintf_s, StringCbVPrintf, StringCbVPrintf_l, StringCbVPrintf_lEx, StringCbVPrintfEx"
        or
        name.matches("_vstprintf") and
        replacement =
          "StringCbVPrintf, StringCbVPrintf_l, StringCbVPrintf_lEx, StringCbVPrinfEx, StringCchVPrintf, StringCchVPrintf_l, StringCchVPrintf_lEx, StringCchVPrintfEx"
        or
        name.matches("_wmakepath") and replacement = "_wmakepath_s"
        or
        name.matches("_wsplitpath") and replacement = "_wsplitpath_s"
        or
        name.matches("OemToCharW") and replacement = "None"
        or
        name.matches("StrCat") and
        replacement = "StringCbCat, StringCbCatEx, StringCchCat, StringCchCatEx"
        or
        name.matches("StrCatA") and replacement = "None"
        or
        name.matches("StrCatBuff") and
        replacement = "StringCbCat, StringCbCatEx, StringCchCat, StringCchCatEx"
        or
        name.matches("StrCatBuffA") and replacement = "None"
        or
        name.matches("StrCatBuffW") and replacement = "None"
        or
        name.matches("StrCatChainW") and replacement = "None"
        or
        name.matches("StrCatN") and replacement = "None"
        or
        name.matches("StrCatNA") and replacement = "None"
        or
        name.matches("StrCatNW") and replacement = "None"
        or
        name.matches("StrCatW") and replacement = "None"
        or
        name.matches("StrCpy") and
        replacement = "StringCbCopy, StringCbCopyEx, StringCchCopy, StringCchCopyEx"
        or
        name.matches("StrCpyA") and replacement = "None"
        or
        name.matches("StrCpyN") and replacement = "None"
        or
        name.matches("StrCpyNA") and replacement = "None"
        or
        name.matches("StrCpyNW") and replacement = "None"
        or
        name.matches("strcpyW") and replacement = "None"
        or
        name.matches("StrCpyW") and replacement = "None"
        or
        name.matches("StrNCat") and
        replacement = "StringCbCatN, StringCbCatNEx, StringCchCatN, StringCchCatNEx"
        or
        name.matches("StrNCatA") and replacement = "None"
        or
        name.matches("StrNCatW") and replacement = "None"
        or
        name.matches("StrNCpy") and replacement = "None"
        or
        name.matches("StrNCpyA") and replacement = "None"
        or
        name.matches("StrNCpyW") and replacement = "None"
        or
        name.matches("gets") and
        replacement = "gets_s, fgets, StringCbGets, StringCbGetsEx, StringCchGets, StringCchGetsEx"
        or
        name.matches("lstrcat") and
        replacement = "StringCbCat, StringCbCatEx, StringCchCat, StringCchCatEx"
        or
        name.matches("lstrcatA") and replacement = "None"
        or
        name.matches("lstrcatn") and replacement = "None"
        or
        name.matches("lstrcatnA") and replacement = "None"
        or
        name.matches("lstrcatnW") and replacement = "None"
        or
        name.matches("lstrcatW") and replacement = "None"
        or
        name.matches("lstrcpy") and
        replacement = "StringCbCopy, StringCbCopyEx, StringCchCopy, StringCchCopyEx"
        or
        name.matches("lstrcpyA") and replacement = "None"
        or
        name.matches("lstrcpyn") and replacement = "None"
        or
        name.matches("lstrcpynA") and replacement = "None"
        or
        name.matches("lstrcpynW") and replacement = "None"
        or
        name.matches("lstrcpyW") and replacement = "None"
        or
        name.matches("snscanf") and replacement = "None"
        or
        name.matches("snwscanf") and replacement = "None"
        or
        name.matches("sprintf") and replacement = "sprintf_s"
        or
        name.matches("sprintfA") and replacement = "None"
        or
        name.matches("sprintfW") and replacement = "None"
        or
        name.matches("lstrncat") and replacement = "None"
        or
        name.matches("makepath") and replacement = "None"
        or
        name.matches("nsprintf") and replacement = "None"
        or
        name.matches("strcat") and
        replacement = "strcat_s, StringCbCat, StringCbCatEx, StringCchCat, StringCchCatEx, strlcat"
        or
        name.matches("strcatA") and replacement = "None"
        or
        name.matches("strcatW") and replacement = "None"
        or
        name.matches("strcpy") and
        replacement =
          "strcpy_s, StringCbCopy, StringCbCopyEx, StringCchCopy, StringCchCopyEx, strlcpy"
        or
        name.matches("strcpyA") and replacement = "None"
        or
        name.matches("strncat") and
        replacement =
          "strncat_s, StringCbCatN, StringCbCatNEx, StringCchCatN, StringCchCatNEx, strlcat"
        or
        name.matches("strncpy") and
        replacement =
          "strncpy_s, StringCbCopyN, StringCbCopyNEx, StringCchCopyN, StringCchCopyNEx, strlcpy"
        or
        name.matches("swprintf") and
        replacement =
          "swprintf_s StringCbPrintf, StringCbPrintf_l, StringCbPrintf_lEx, StringCbPrintf, StringCbPrintfEx"
        or
        name.matches("ualstrcpyW") and replacement = "None"
        or
        name.matches("vsnprintf") and
        replacement =
          "vsnprintf_s, StringCbVPrintf, StringCbVPrintf_l, StringCbVPrintf_lEx, StringCbVPrintfEx, StringCchVPrintf, StringCchVPrintf_l, StringCchVPrintf_lEx, StringCchVPrintfEx"
        or
        name.matches("vsprintf") and
        replacement =
          "vsprintf_s, StringCbVPrintf, StringCbVPrintf_l, StringCbVPrintf_lEx, StringCbVPrintfEx, StringCchVPrintf, StringCchVPrintf_l, StringCchVPrintf_lEx, StringCchVPrintfEx, vasprintf"
        or
        name.matches("vswprintf") and replacement = "vswprintf_s"
        or
        name.matches("wcscat") and
        replacement = "wcscat_s, StringCbCat, StringCbCatEx, StringCchCat, StringCchCatEx, wcslcat"
        or
        name.matches("wcscpy") and
        replacement =
          "wcscpy_s, StringCbCopy, StringCbCopyEx, StringCchCopy, StringCchCopyEx, wcslcpy"
        or
        name.matches("wcsncat") and replacement = "wcsncat_s, wcslcat"
        or
        name.matches("wcsncpy") and
        replacement =
          "wcsncpy_s, StringCbCopyN, StringCbCopyNEx, StringCchCopyN, StringCchCopyNEx, wcslcpy"
        or
        name.matches("wnsprintf") and
        replacement =
          "StringCbPrintf, StringCbPrintf_l, StringCbPrintf_lEx, StringCbPrintfEx, StringCchPrintf, StringCchPrintfEx"
        or
        name.matches("wnsprintfA") and replacement = "None"
        or
        name.matches("wsprintf") and replacement = "None"
        or
        name.matches("wsprintfA") and replacement = "None"
        or
        name.matches("wsprintfW") and replacement = "None"
        or
        name.matches("wvnsprintf") and
        replacement =
          "StringCbVPrintf, StringCbVPrintf_l, StringCbVPrintf_lEx, StringCbVPrintfEx, StringCchVPrintf, StringCchVPrintf_l, StringCchVPrintf_lEx, StringCchVPrintfEx"
        or
        name.matches("wvnsprintfA") and replacement = "None"
        or
        name.matches("wvnsprintfW") and replacement = "None"
        or
        name.matches("wvsprintf") and
        replacement =
          "StringCbVPrintf, StringCbVPrintf_l, StringCbVPrintf_lEx, StringCbVPrintfEx, StringCchVPrintf, StringCchVPrintf_l, StringCchVPrintf_lEx, StringCchVPrintfEx"
        or
        name.matches("wvsprintfA") and replacement = "None"
        or
        name.matches("wvsprintfW") and replacement = "None"
      )
      or
      // Functions marked deprecated in C28726
      (
        name.matches("_itoa") and replacement = "_itoa_s"
        or
        name.matches("_i64toa") and replacement = "_i64toa_s"
        or
        name.matches("_i64tow") and replacement = "_i64tow_s"
        or
        name.matches("_mbccpy") and replacement = "_mbccpy_s"
        or
        name.matches("_mbscpy") and replacement = "_mbscpy_s"
        or
        name.matches("_mbsnbcpy") and replacement = "_mbsnbcpy_s"
        or
        name.matches("_mbsnbcat") and replacement = "_mbsnbcat_s"
        or
        name.matches("_mbsncat") and replacement = "_mbsncat_s"
        or
        name.matches("_mbsncpy") and replacement = "_mbsncpy_s"
        or
        name.matches("_mbstok") and replacement = "_mbstok_s"
        or
        name.matches("_snscanf") and replacement = "_snscanf_s"
        or
        name.matches("_snwscanf") and replacement = "_snwscanf_s"
        or
        name.matches("_ui64toa") and replacement = "ui64toa_s"
        or
        name.matches("_ui64tow") and replacement = "_ui64tow_s"
        or
        name.matches("_ultoa") and replacement = "_ultoa_s"
        or
        name.matches("CharToOemA") and replacement = "None"
        or
        name.matches("CharToOemBuffA") and replacement = "None"
        or
        name.matches("CharToOemBuffW") and replacement = "None"
        or
        name.matches("CharToOemW") and replacement = "None"
        or
        name.matches("OemToCharA") and replacement = "None"
        or
        name.matches("OemToCharBuffA") and replacement = "None"
        or
        name.matches("OemToCharBuffW") and replacement = "None"
        or
        name.matches("scanf") and replacement = "scanf_s"
        or
        name.matches("sscanf") and replacement = "sscanf_s"
        or
        name.matches("wmemcpy") and replacement = "wmemcpy_s"
        or
        name.matches("wnsprintfW") and replacement = "None"
        or
        name.matches("wscanf") and replacement = "wscanf_s"
      )
      or
      // Functions marked deprecated in C28750
      (
        name.matches("lstrlen") and replacement = "_tcslen"
        or
        name.matches("lstrlenA") and replacement = "strlen"
        or
        name.matches("lstrlenW") and replacement = "wcslen"
      )
    )
  }

  string getMessage() {
    if replacement.matches("None")
    then
      result =
        name +
          " is insecure and has been marked deprecated.  Please investigate a safe replacement."
    else
      result =
        name +
          " is insecure and has been marked deprecated.  Replace it with one of the following safe replacements: "
          + replacement + "."
  }
}

from ExtendedDeprecatedCall deprecatedCall
where not deprecatedCall.getLocation().getFile().toString().matches("%Windows Kits%Include%.h")
select deprecatedCall, deprecatedCall.getMessage()
