#Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]
### Added
- Add consul maintenance check @okushchenko

## [1.2.0] - 2017-01-26
### Added
- `check-consul-service-health` and `check-service-consul` now accept a --tags filter (@wg-tsuereth)

### Fixed
- check-service-consul should look for 'critical' instead of 'failing' (@mattcl)

## [1.1.0] - 2016-08-03
### Added
- check-consul-service-health and check-service-consul now accept a --fail-if-not-found argument @wg-tsuereth

## [1.0.0] - 2016-06-28
### Fixed
- Fixed check-consul-service-health and check-service-consul --all argument @wg-tsuereth

### Added
- check-consul-service-health and check-service-consul now accept a --consul argument to specify a server @wg-tsuereth
- Support for Ruby 2.3.0

### Removed
- Support for Ruby 1.9.3

## [0.1.7] - 2016-04-03
### Added
- check-consul-service-health will check the health of a specific service (Yieldbot)
- check-consul-kv-ttl will check Consul KV namespace for timed out global operations (Yieldbot)
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

## [0.0.2] - 2015-06-02
### Fixed
- added binstubs

### Changed
- removed cruft from /lib

## [0.0.1] - 2015-05-21

### Added
- initial release

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/1.2.0...HEAD
[1.2.0]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/0.1.7...1.0.0
[0.1.7]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/0.0.7...0.1.7
[0.0.7]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/0.0.6...0.0.7
[0.0.6]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/0.0.5...0.0.6
[0.0.5]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/0.0.4...0.0.5
[0.0.4]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/0.0.1...0.0.2
