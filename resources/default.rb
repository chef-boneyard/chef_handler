#
# Author:: Seth Chisamore <schisamo@chef.io>
# Cookbook Name:: chef_handler
# Resource:: default
#
# Copyright:: 2011-2016, Chef Software, Inc <legal@chef.io>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

property :class_name, String, name_property: true
property :source, String
property :arguments, [Array, Hash], default: []
property :type, Hash, default: { report: true, exception: true }

# supports means a different thing in chef-land so we renamed it but
# wanted to make sure we didn't break the world
alias_method :supports, :type

# This action needs to find an rb file that presumably contains the indicated class in it and the
# load that file. It then instantiates that class by name and registers it as a handler.
action :enable do
  class_name = new_resource.class_name
  new_resource.type.each do |type, enable|
    next unless enable

    unregister_handler(type, class_name)
  end

  handler = nil

  require new_resource.source unless new_resource.source.nil?

  _, klass = get_class(class_name)
  handler = klass.send(:new, *collect_args(new_resource.arguments))

  new_resource.type.each do |type, enable|
    next unless enable
    register_handler(type, handler)
  end
end

action :disable do
  new_resource.type.each_key do |type|
    unregister_handler(type, new_resource.class_name)
  end
end

action_class do
  include ::ChefHandler::Helpers

  def collect_args(resource_args = [])
    if resource_args.is_a? Array
      resource_args
    else
      [resource_args]
    end
  end
end
