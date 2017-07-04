# chef_handler cookbook CHANGELOG

This file is used to list changes made in each version of the chef_handler cookbook.

## 3.0.2 (2017-07-04)

- Fix namespace collision with helper module

## 3.0.1 (2017-06-23)

- Make sure arguments can be a hash not just an array

## 3.0.0 (2017-06-20)

- Remove the ability to install handlers via the files directory in this cookbook. This is a very old pattern that Chef (Opscode) pushed in ~2009/~2010 which required you to fork the cookbook so you could add your own files locally. There's a resource now and handlers should be installed using that resource.
- Converted the handler LWRP to a custom resource, which makes Chef 12.7 the minimum version of chef-client supported
- Converted the 'supports' property to a new property called 'type', which prevents deprecation warnings for Chef 12 users. Calls to the existing property will continue to work, but documentation now points to the new property.

## 2.1.2 (2017-06-19)

- Use a SPDX standard license string
- Remove CloudkickHandler references from the readme
- Use default_action in the resource to resolve FC074
- Reduce handler location log level to debug

## 2.1.1 (2017-04-11)

- Fixed Chef 13 compatibility
- Add supported OS list to metadata

## 2.1.0 (2016-12-27)

- Support Chefspec 4.1+ matchers only
- Yank out converge_by to avoid bogus resource updates

## 2.0.0 (2016-09-16)
- Testing updates
- Require Chef 12.1

## v1.4.0 (2016-05-13)

- Allow defining handlers in a cookbook libraries and then enabling them with the chef_handler resource without actually providing a file as a source. This simplifies the delivery of the handler file itself. See the readme for an example.

## v1.3.0 (2016-02-16)

- Added state attributes to the custom resource
- Added source_url and issues_url to metadata.rb
- Replaced attributes for root user and group with the Ohai defined values to simplify the logic of the cookbook
- Added lint, unit, and itegration testing in Travis CI
- Added Test Kitchen testing of the recipes and the custom resource via a test cookbook
- Added Berksfile
- Added chefignore and .gitignore files
- Added .rubocop.yml config and resolve multiple issues
- Updated contributing and testing docs to the latest
- Added all testing dependencies to the Gemfile
- Added maintainers.md and maintainers.toml files
- Expanded the Rakefile for simplified testing

## v1.2.0 (2015-06-25)

- Move to support Chef 12+ only. Removes old 'handler class reload' behavior - it isn't necessary because chef-client forks and doesn't share a process between runs.

## v1.1.9 (2015-05-26)

- Bugfixes from 1.1.8 - loading without source is not allowed again. Class unloading is performed more carefully. Tests for resource providers.

## v1.1.8 (2015-05-14)

- Updated Contribution and Readme docs
- Fix ChefSpec matchers
- Allow handler to load classes when no source is provided.

## v1.1.6 (2014-04-09)

- [COOK-4494] - Add ChefSpec matchers

## v1.1.5 (2014-02-25)

- [COOK-4117] - use the correct scope when searching the children class name

## v1.1.4

- [COOK-2146] - style updates

## v1.1.2

- [COOK-1989] - fix scope for handler local variable to the enable block

## v1.1.0

- [COOK-1645] - properly delete old handlers
- [COOK-1322] - support platforms that use 'wheel' as root group'

## v1.0.8

- [COOK-1177] - doesn't work on windows due to use of unix specific attributes

## v1.0.6

- [COOK-1069] - typo in chef_handler readme

## v1.0.4

- [COOK-654] dont try and access a class before it has been loaded
- fix bad boolean check (if vs unless)

## v1.0.2

- [COOK-620] ensure handler code is reloaded during daemonized chef runs
