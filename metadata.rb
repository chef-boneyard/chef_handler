name             "chef_handler"
maintainer       "Chef Software, Inc."
maintainer_email "cookbooks@chef.io"
license          "Apache 2.0"
description      "Distribute and enable Chef Exception and Report handlers"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.2.0"

recipe 'chef_handler', 'Deploys all handlers to the handler path early during the run.'
recipe 'chef_handler::json_file', 'Enables Chef::Handler::JsonFile to serialize run status data to /var/chef/reports.'
