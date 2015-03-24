## Sensu-Plugins-consul

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-consul.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-consul)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-consul.svg)](http://badge.fury.io/rb/sensu-plugins-consul)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-consul/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-consul)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-consul/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-consul)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-consul.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-consul)
## Functionality

## Files
 * bin/check-consul
 * bin/check-service-consul

## Usage

## Installation

Add the public key (if you haven’t already) as a trusted certificate

```
gem cert --add <(curl -Ls https://raw.githubusercontent.com/sensu-plugins/sensu-plugins.github.io/master/certs/sensu-plugins.pem)
gem install sensu-plugins-consul -P MediumSecurity
```

You can also download the key from /certs/ within each repository.

#### Rubygems

`gem install sensu-plugins-consul`

#### Bundler

Add *sensu-plugins-disk-checks* to your Gemfile and run `bundle install` or `bundle update`

#### Chef

Using the Sensu **sensu_gem** LWRP
```
sensu_gem 'sensu-plugins-consul' do
  options('--prerelease')
  version '0.0.1.alpha.4'
end
```

Using the Chef **gem_package** resource
```
gem_package 'sensu-plugins-consul' do
  options('--prerelease')
  version '0.0.1.alpha.4'
end
```

## Notes

[1]:[https://travis-ci.org/sensu-plugins/sensu-plugins-consul]
[2]:[http://badge.fury.io/rb/sensu-plugins-consul]
[3]:[https://codeclimate.com/github/sensu-plugins/sensu-plugins-consul]
[4]:[https://codeclimate.com/github/sensu-plugins/sensu-plugins-consul]
[5]:[https://gemnasium.com/sensu-plugins/sensu-plugins-consul]
