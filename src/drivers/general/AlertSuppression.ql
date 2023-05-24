/**
 * @name Alert suppression
 * @description Generates information about alert suppressions.
 * @kind alert-suppression
 * @id cpp/alert-suppression
 */

private import drivers.libraries.Suppression
private import semmle.code.cpp.Element

from CASuppression cas, string text, string annotation, CASuppressionScope cass
where
  text = cas.toString() and // text of suppression comment (excluding delimiters)
  annotation = cas.makeLgtmName() // text of suppression annotation
  and cas.getScope() = cass // scope of suppression
select cas, text, annotation, cass