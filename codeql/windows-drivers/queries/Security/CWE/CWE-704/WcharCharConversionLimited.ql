/**
 * @name Cast from char* to wchar_t* (ignore PUCHAR casts)
 * @description Casting a byte string to a wide-character string is likely
 *              to yield a string that is incorrectly terminated or aligned.
 *              This can lead to undefined behavior, including buffer overruns.
 *              This query is a specilized version of `cpp/incorrect-string-type-conversion` that ignores casting to `PUCHAR`
 * @kind problem
 * @id cpp/incorrect-string-type-conversion-isgnore-puchar-casts
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @tags security
 *       external/cwe/cwe-704
 */

import cpp

class WideCharPointerType extends PointerType {
  WideCharPointerType() { this.getBaseType() instanceof WideCharType }
}

from Expr e1, Cast e2
where
  e2 = e1.getConversion() and
  exists(WideCharPointerType w, CharPointerType c |
    w = e2.getUnspecifiedType().(PointerType) and
    c = e1.getUnspecifiedType().(PointerType) and
    not c.getBaseType() instanceof UnsignedCharType // Eliminate False Postives caused by PUCHAR used as a generic byte stream
  )
select e1,
  "Conversion from " + e1.getType().toString() + " to " + e2.getType().toString() +
    ". Use of invalid string can lead to undefined behavior."
