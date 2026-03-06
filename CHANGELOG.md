
# Change Log
All notable changes to this project will be documented in this file.

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
