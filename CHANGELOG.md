#Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]
- Added check to alert on consul cluster members, supports querying wan members @aianchici

## [0.0.7] - 2015-11-12
### Changed
- Consul checks with UNKNOWN status should fail gracefully

### Fixed
- Consul service check fixes

## [0.0.6] - 2015-09-29
### Changed
- Bug fixes for check-consul-servers.rb

## [0.0.5] - 2015-09-28
### Added
- Added check to alert on consul peer servers

## [0.0.4] - 2015-07-14
### Added
- Adding script to remove failed consul nodes prior to 72 hour consul window. 

## [0.0.3] - 2015-07-14
### Changed
- updated sensu-plugin gem to 1.2.0

### Fixed
- Added check to support removing of failed consul nodes from the cluster

## 0.0.1 - 2015-05-21

### Added
- initial release

## 0.0.2 - 2015-06-02

### Fixed
- added binstubs

### Changed
- removed cruft from /lib
