/**
 * @name Driver alert suppression
 * @description Suppresses alerts in Windows Drivers based on Code Analysis syntax.
 * @kind alert-suppression
 * @id cpp/windows/drivers/driver-alert-suppression
 */

private import drivers.libraries.Suppression

from CASuppression cas, string text, string annotation, CASuppressionScope cass
where
  text = cas.toString() and // text of suppression comment (excluding delimiters)
  annotation = cas.makeLgtmName() // text of suppression annotation
  and cas.getScope() = cass // scope of suppression
select cas, text, annotation, cass