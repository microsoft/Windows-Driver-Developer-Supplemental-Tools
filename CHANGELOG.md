
# Change Log
All notable changes to this project will be documented in this file.

## [1.10.0] - 2026-05-12

### Added
- Added the following recommended rules to our Microsoft subfolder.  These rules are *not* part of our must-run set at this time.
     - NonConstantFormat.ql: Detects printf-like function calls where the format string argument does not originate from a string literal, which could lead to format string vulnerabilities.
     - ImproperNullTermination.ql: Detects uses of strings that may not be null-terminated being passed to string functions, which can cause buffer overflows or over-reads.
     - StrncpyFlippedArgs.ql: Detects calls to strncpy where the size argument is based on the source buffer size instead of the destination, potentially causing buffer overflows.
     - UnsafeUseOfStrcat.ql: Detects uses of strcat where the source string size is not checked before concatenation, which may result in buffer overflow.
     - ArithmeticUncontrolled.ql: Detects arithmetic operations on data from random number generators that lack validation, potentially causing integer overflows.
     - ArithmeticWithExtremeValues.ql: Detects arithmetic operations on variables assigned extreme values (INT_MAX, INT_MIN, etc.) that could cause overflow or underflow.

### Fixed
 - Reduced false positive rate for InvalidFunctionClassTypedef.ql, IrqlAnnotationIssue.ql, IrqlTooHigh.ql, IrqlTooLow.ql, IllegalFieldAccess2.ql, OpaqueMdlUse.ql, OpaqueMdlWrite.ql, and UnguardedNullReturnDereference.ql.  Thanks to zx2c4 for the contribution.
 - Significantly improved performance for DriverAlertSuppression.ql and MultiplePagedCode.ql.
 - Moderately improved performance and further reduced false positive rate for all IRQL queries.

## [1.9.0] - 2026-02-27

### Added
 - Added five new queries in the Microsoft subfolder.  These queries are now part of our recommended and must-run sets.
     - ConditionallyUninitializedVariableAutomation.ql: Flags calls to initialization functions whose return status is not checked, potentially leaving a local variable uninitialized.
     - UnprobedDereference.ql: Detects dereferences of user-provided pointers that haven't been probed first, which could cause access violations.
     - UserModeMemoryOutsideTry.ql: Finds reads of user-mode memory that occur outside a try/catch block, where unexpected exceptions from changed memory protections could crash the kernel.
     - UserModeMemoryReadMultipleTimes.ql: identifies double-fetch vulnerabilities where user-mode memory is read more than once without being copied to kernel memory first.
     - UnguardedNullReturnDereference.ql: Reports dereferences of return values from calls that may return NULL (e.g. heap allocations) without a preceding null check.

### Changed
 - Standardized the rule ID of UninitializedPtrField.ql to "cpp/microsoft/public/likely-bugs/uninitializedptrfield" and updated accuracy.
 - Standardized owner emails for all queries.

## [1.8.3] - 2026-02-25

### Changed
 - Updated the C/C++ CodeQL libraries we depend on to version 7.0.0.
 - Updated the cpp-queries pack we depend on to version 0.0.5.

## [1.8.2] - 2026-01-23

### Changed
 - IrqlSetTooHigh.ql and IrqlSetTooLow.ql now provide clearer explanations when a defect is found.
### Fixed
 - Fixed a bug where IrqlTooLow.ql could report potential false positives.

## [1.8.1] - 2025-12-04

### Fixed
 - Fixed a bug where CA suppressions for C28167 were not honored for the IrqlFunctionNotAnnotated query.

## [1.8.0] - 2025-07-17

### Added
 - CHANGELOG.md
### Changed
 - ExtendedDeprecatedApis.ql moved from recommended.qls to mustfix.qls
