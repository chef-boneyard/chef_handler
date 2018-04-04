name 'chef_handler'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license 'Apache-2.0'
description 'Distribute and enable Chef Exception and Report handlers'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '3.0.3'

recipe 'chef_handler::json_file', 'Enables Chef::Handler::JsonFile to serialize run status data to /var/chef/reports.'

source_url 'https://github.com/chef-cookbooks/chef_handler'
issues_url 'https://github.com/chef-cookbooks/chef_handler/issues'
chef_version '>= 12.7' if respond_to?(:chef_version)

%w(ubuntu debian redhat centos fedora).each do |os|
  supports os
end
