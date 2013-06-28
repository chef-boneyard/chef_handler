#
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: chef_handler
# Provider:: default
#
# Copyright:: 2011-2013, Opscode, Inc <legal@opscode.com>
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

def whyrun_supported?
  true
end

action :enable do
  require 'chef/digester'

  directory node["chef_handler"]["handler_copy_path"]

  source = @new_resource.source
  dest =  ::File.join(node["chef_handler"]["handler_copy_path"], @new_resource.class_name)

  #We have to use hand-made copy to avoid using execute with 
  #non windows compatible cp
  new_check = Chef::Digester.checksum_for_file(@new_resource.source)
  old_check = Chef::Digester.checksum_for_file(dest) if ::File.exists? dest
  r = ruby_block "cache the source file" do
    block do
      FileUtils.cp(source, dest)
    end
    not_if { new_check.eql? old_check }
  end

  #We have to test if class has been loaded to take care of chef restarts
  begin
    Module.const_get(klass)
  rescue NameError
    force_load = true
  end

  handler = nil
  if r.updated_by_last_action? || force_load
    converge_by("load #{@new_resource.source}") do
      begin
        Object.send(:remove_const, klass)
        GC.start
      rescue
        Chef::Log.debug("#{@new_resource.class_name} has not been loaded.")
      end
      file_name = @new_resource.source
      # use load instead of require to ensure the handler file
      # is reloaded into memory each chef run. fixes COOK-620
      file_name << ".rb" unless file_name =~ /.*\.rb$/
        load file_name
      handler = klass.send(:new, *collect_args(@new_resource.arguments))
    end
    @new_resource.supports.each do |type, enable|
      if enable
        # we have to re-enable the handler every chef run
        # to ensure daemonized Chef always has the latest
        # handler code.  TODO: add a :reload action
        converge_by("enable #{@new_resource} as a #{type} handler") do
          Chef::Log.info("Enabling #{@new_resource} as a #{type} handler")
          Chef::Config.send("#{type.to_s}_handlers").delete_if { |v| v.class.to_s.include? @new_resource.class_name.split('::', 3).last }
          Chef::Config.send("#{type.to_s}_handlers") << handler
        end
      end
    end
  end
end

action :disable do
  @new_resource.supports.each_key do |type|
    if enabled?(type)
      converge_by("disable #{@new_resource} as a #{type} handler") do
        Chef::Log.info("Disabling #{@new_resource} as a #{type} handler")
        Chef::Config.send("#{type.to_s}_handlers").delete_if { |v| v.class.to_s.include? @new_resource.class_name.split('::', 3).last }
      end
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::ChefHandler.new(@new_resource.name)
  @current_resource.class_name(@new_resource.class_name)
  @current_resource.source(@new_resource.source)
  @current_resource
end

private

def enabled?(type)
  Chef::Config.send("#{type.to_s}_handlers").select do |handler|
    handler.class.to_s.include? @new_resource.class_name
  end.size >= 1
end

def collect_args(resource_args = [])
  if resource_args.is_a? Array
    resource_args
  else
    [resource_args]
  end
end

def klass
  @klass ||= begin
    @new_resource.class_name.split('::').inject(Kernel) { |scope, const_name| scope.const_get(const_name) }
  end
end
