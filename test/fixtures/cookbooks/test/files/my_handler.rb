require 'chef'
require 'chef/handler'

module MyCorp
  class MyHandler < Chef::Handler
    def report
      puts "The run status was: #{run_status.respond_to?(:updated_resources) ? run_status.updated_resources.length : 0}"
      puts "The total resource count was: #{run_status.respond_to?(:all_resources) ? run_status.all_resources.length : 0}"
      puts "The elapsed time was: #{run_status.elapsed_time}"
    end
  end
end
