/**
 * @name Driver alert suppression
 * @description Suppresses alerts in Windows Drivers based on Code Analysis syntax.
 * @kind alert-suppression
 * @id cpp/windows/drivers/driver-alert-suppression
 * 
 * This query is a suppression query designed to identify existing PREFast-style suppressions
 * in Windows driver code and honor them through LGTM's suppression system.  It cannot be run
 * on its own.  Instead, it should be run alongside other queries; when the code has a valid
 * suppression for a given result, the output of the run will indicate that the result was 
 * suppressed in the SARIF file.
 * 
 * Note that at this time, these suppressions are *not* taken into consideration during
 * WHCP certification by the Static Tools Logo test.
 */

private import drivers.libraries.Suppression

from CASuppression cas, string text, string annotation, CASuppressionScope scope
where
  text = cas.toString() and // text of suppression comment (excluding delimiters)
  annotation = cas.makeLgtmName() // annotation converted to "lgtm[rule-name]" format
  and cas.getScope() = scope // scope of suppression
select cas, text, annotation, scope