# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed [here](https://github.com/sensu-plugins/community/blob/master/HOW_WE_CHANGELOG.md)

## [Unreleased]
### Fixed
- `check-consul-leader.rb`: Timeout option must be an integer (@scalp42)

## [2.1.0] - 2018-03-29
### Added
- `check-consul-quorum.rb`: Check how many servers can be lost while maintaining quorum (@roboticcheese)
- `check-consul-stale-peers.rb`: Check for stale peers in the raft configuration (@roboticcheese)

## [2.0.1] - 2018-03-27
### Security
- updated yard dependency to `~> 0.9.11` per: https://nvd.nist.gov/vuln/detail/CVE-2017-17042 (@majormoses)

### Changed
- appeased the cops (@majormoses)

## [2.0.0] - 2018-03-07
### Security
- updated rubocop dependency to `~> 0.51.0` per: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-8418. (@majormoses)

### Breaking Changes
- removed ruby `< 2.1` support (@majormoses)

### Changed
- appeased the cops (@majormoses)

## [1.6.1] - 2018-03-02
### Fixed
- Bug fix for `check-consul-servers` so timeout option works (@joshbenner)

## [1.6.0] - 2017-09-30
### Added
- `check-consul-leader`, `check-consul-members`, and `check-consul-servers` now accept `--insecure`, `--capath`, `--timeout` arguments (@akatch)

### Changed
- update Changelog guideline location (@majormoses)

## [1.5.0] - 2017-08-09
### Added
- `check-consul-failures` now accepts `--keep-failures` and `--critical` arguments (@psyhomb)

## [1.4.1] 2017-08-06
### Fixed
- Bug fix for `check-consul-service-health` [#26](https://github.com/sensu-plugins/sensu-plugins-consul/pull/26) (@psyhomb)

### Added
- ruby 2.4.1 testing (@majormoses)

## [1.4.0] 2017-08-05
### Added
- `check-consul-service-health` now accept a `--node` argument that will check all autodiscovered consul services running on the specified node (@psyhomb)

## [1.3.0] 2017-05-05
### Added
- `check-consul-failures`, `check-consul-leader`, `check-consul-members`, and `check-consul-servers` now accept a --scheme parameter (@akatch)
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

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/2.1.0...HEAD
[2.1.0]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/2.0.1...2.1.0
[2.0.1]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/1.6.1...2.0.0
[1.6.1]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/1.6.0...1.6.1
[1.6.0]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/1.5.0...1.6.0
[1.5.0]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/1.4.1...1.5.0
[1.4.1]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/1.4.0...1.4.1
[1.4.0]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/1.3.0...1.4.0
[1.3.0]: https://github.com/sensu-plugins/sensu-plugins-consul/compare/2.1.0...1.3.0
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
