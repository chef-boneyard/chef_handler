directory 'Handlers directory' do
  path node['chef_handler']['handler_path']
  group node['root_group']
  unless platform?('windows')
    owner 'root'
    mode '0755'
  end
  recursive true
  action :create
end

cookbook_file "#{node['chef_handler']['handler_path']}/my_handler.rb" do
  source 'my_handler.rb'
end

chef_handler 'MyCorp::MyHandler' do
  source "#{node['chef_handler']['handler_path']}/my_handler.rb"
  action [:enable, :disable]
end

chef_handler 'MyCorp::MyLibraryHandler' do
  action :enable
  supports exception: true
end
