
# Change Log
All notable changes to this project will be documented in this file.

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
