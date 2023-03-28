# Changelog
This file contains all the notable changes done to the Ballerina java.jdbc package through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

## [1.7.0] - 2023-02-20

### Added
- [Validate requestGeneratedKeys configuration per database](https://github.com/ballerina-platform/ballerina-standard-library/issues/3900)

### Changed
- [Remove SQL_901 diagnostic hint](https://github.com/ballerina-platform/ballerina-standard-library/issues/3609)
- [Enable non-Hikari logs](https://github.com/ballerina-platform/ballerina-standard-library/issues/3763)

## [1.6.1] - 2023-02-09

### Changed
- [Improve API docs based on Best practices](https://github.com/ballerina-platform/ballerina-standard-library/issues/3857)
- [Fix JDBC compiler plugins failure when the diagnostic code is null](https://github.com/ballerina-platform/ballerina-standard-library/issues/4054)

## [1.6.0] - 2022-11-29

### Changed
- [Fix Syntax error in Batch update API docs](https://github.com/ballerina-platform/ballerina-standard-library/issues/3441)
- [Updated API docs](https://github.com/ballerina-platform/ballerina-standard-library/issues/3463)

## [1.5.0] - 2022-09-08

### Changed
- Includes fixes from `sql:1.5.0`

## [1.4.1] - 2022-06-27

### Changed
- [Fix NullPointerException when retrieving record with default value](https://github.com/ballerina-platform/ballerina-standard-library/issues/2985)

## [1.4.0] - 2022-05-30

### Added
- [Improve DB columns to Ballerina record Mapping through Annotation](https://github.com/ballerina-platform/ballerina-standard-library/issues/2652)

### Changed
- [Improve API documentation to reflect query usages](https://github.com/ballerina-platform/ballerina-standard-library/issues/2524)
- [Fix incorrect code snippet in SQL api docs](https://github.com/ballerina-platform/ballerina-standard-library/issues/2931)

## [1.3.0] - 2022-01-29

### Changed
- [Fix Compiler plugin crash when variable is passed for `sql:ConnectionPool`](https://github.com/ballerina-platform/ballerina-standard-library/issues/2536)

## [1.2.1] - 2022-02-03

### Changed
- [Fix Compiler plugin crash when variable is passed for `sql:ConnectionPool`](https://github.com/ballerina-platform/ballerina-standard-library/issues/2536)

## [1.2.0] - 2021-12-13

### Changed
- Release module on top of Swan Lake Beta6 distribution

## [1.1.0] - 2021-11-20

### Added
- [Tooling support for JDBC client](https://github.com/ballerina-platform/ballerina-standard-library/issues/2280)

### Changed
- [Change queryRow return type to anydata](https://github.com/ballerina-platform/ballerina-standard-library/issues/2390)

## [1.0.0] - 2021-10-09

### Changed
- [Add completion type as nil in SQL query return stream type](https://github.com/ballerina-platform/ballerina-standard-library/issues/1654)

### Added
- [Add support for queryRow](https://github.com/ballerina-platform/ballerina-standard-library/issues/1604)
- [Add support for configuring the retrieval of auto generated keys on query execution](https://github.com/ballerina-platform/ballerina-standard-library/issues/1804)

## [0.6.0-beta.2] - 2021-06-22

### Changed
- [Change default rowType of the query remote method from `nil` to `<>`](https://github.com/ballerina-platform/ballerina-standard-library/issues/1445)
- [Remove support for string parameter in SQL APIs](https://github.com/ballerina-platform/ballerina-standard-library/issues/2010)

## [0.6.0-beta.1] - 2021-06-02

### Changed
- Make JDBC Client class isolated
