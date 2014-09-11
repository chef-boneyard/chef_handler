chef_gem "chef-handler-graphite"

argument_array = [
  :metric_key => "chef.client.#{node['hostname']}",
  :graphite_host => "graphite.service.altiscale.com",
  :graphite_port => 2003
]

chef_handler "GraphiteReporting" do
  source "#{Gem::Specification.find_by_name('chef-handler-graphite').lib_dirs_glob}/chef-handler-graphite.rb"
  arguments argument_array
  action :nothing
end.run_action(:enable)