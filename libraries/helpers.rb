# Author:: Kartik Cating-Subramanian (<ksubramanian@chef.io>)
# Copyright:: Copyright (c) 2015 Chef, Inc.
# License:: Apache License, Version 2.0
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
module ChefHandler
  module Helpers
    def register_handler(handler_type, handler)
      # handler_type is a symbol such as :report or :exception.
      # handler is a freshly created object that is a Chef::Handler.
      Chef::Log.info("Enabling #{handler.class.class.name} as a #{handler_type} handler.")
      Chef::Config.send("#{handler_type.to_s}_handlers") << handler
    end

    def unregister_handler(handler_type, class_full_name)
      # handler_type is a symbol such as :report or :exception.
      # class_full_name is a string such as 'Chef::Handler::ErrorReport'.
      Chef::Log.info("Enabling #{class_full_name} as a #{handler_type} handler.")
      Chef::Config.send("#{handler_type.to_s}_handlers").delete_if { |v| v.class.name == class_full_name }
    end

    def get_class(class_full_name)
      ancestors = class_full_name.split('::')
      class_name = ancestors.pop

      # We need to search the ancestors only for the first/uppermost namespace of the class, so we
      # need to enable the #const_get inherit paramenter only when we are searching in Kernel scope
      # (see COOK-4117).
      parent = ancestors.inject(Kernel) { |scope, const_name| scope.const_get(const_name, scope === Kernel) }
      child = parent.const_get(class_name, parent === Kernel)
      return parent, child
    end

    def reload_class(class_full_name, file_name)
      # class_full_name should be fully qualified.  If a class with that name currently exists, its
      # definition is deleted from the enclosing module.
      # The class definition for the freshly loaded class is returned.
      begin
        parent, child = get_class(class_full_name)
      rescue
        Chef::Log.debug("#{class_full_name} was not previously loaded.")
      end

      if child then
        class_name = class_full_name.split('::').last
        child = nil
        parent = Object if parent === Kernel
        parent.send(:remove_const, class_name)
        GC.start
      end

      file_name << '.rb' unless file_name =~ /.*\.rb$/
      load file_name

      parent, child = get_class(class_full_name)
      return child
    end
  end
end
