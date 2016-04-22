#
# Cookbook Name:: grocery_delivery
# Recipe:: default
#
# Copyright 2016 Anton Cohen
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

include_recipe 'git' if node['grocery_delivery']['manage_git']

package 'ruby packages for grocery-delivery' do
  package_name lazy { node['grocery_delivery']['ruby_packages'] }
end if node['grocery_delivery']['manage_system_ruby']

if node['grocery_delivery']['manage_build_requirements']
  include_recipe 'build-essential'
  package 'build packages for grocery-delivery' do
    package_name lazy { node['grocery_delivery']['build_requirements'] }
  end
end

if node['grocery_delivery']['manage_package']
  case node['grocery_delivery']['package_provider']
  when 'system'
    package 'grocery-delivery package' do
      package_name lazy { node['grocery_delivery']['package_name'] }
      version lazy { node['grocery_delivery']['package_version'] }
    end
  else
    gem_package 'grocery-delivery package' do
      package_name lazy { node['grocery_delivery']['package_name'] }
      version lazy { node['grocery_delivery']['package_version'] }
    end
  end
end

directory 'grocery-delivery working directory' do
  path lazy { node['grocery_delivery']['working_directory']['path'] }
  owner lazy { node['grocery_delivery']['working_directory']['owner'] }
  group lazy { node['grocery_delivery']['working_directory']['group'] }
  mode lazy { node['grocery_delivery']['working_directory']['mode'] }
  recursive true
end if node['grocery_delivery']['manage_working_directory']

directory 'grocery-delivery config directory' do
  path lazy { node['grocery_delivery']['config_directory']['path'] }
  owner lazy { node['grocery_delivery']['config_directory']['owner'] }
  group lazy { node['grocery_delivery']['config_directory']['group'] }
  mode lazy { node['grocery_delivery']['config_directory']['mode'] }
  recursive true
end if node['grocery_delivery']['manage_config_directory']

ruby_block 'warn required config settings' do
  block do
    warning = "node['grocery_delivery']['config']['repo_url'] must be set"
    Chef::Log.warn(warning)
  end
  not_if { node['grocery_delivery']['config']['repo_url'].is_a?(String) }
end if node['grocery_delivery']['manage_config']

template 'grocery-delivery config' do
  path lazy { node['grocery_delivery']['config_file']['path'] }
  source 'config.rb.erb'
  owner lazy { node['grocery_delivery']['config_file']['owner'] }
  group lazy { node['grocery_delivery']['config_file']['group'] }
  mode lazy { node['grocery_delivery']['config_file']['mode'] }
end if node['grocery_delivery']['manage_config']

ruby_block 'warn required knife config settings' do
  block do
    warning = "node['grocery_delivery']['knife_config']['chef_server_url'] must be set"
    Chef::Log.warn(warning)
  end
  not_if { node['grocery_delivery']['knife_config']['chef_server_url'].is_a?(String) }
end if node['grocery_delivery']['manage_knife_config']

template 'grocery-delivery knife config' do
  path lazy { node['grocery_delivery']['knife_config_file']['path'] }
  source 'knife.rb.erb'
  owner lazy { node['grocery_delivery']['knife_config_file']['owner'] }
  group lazy { node['grocery_delivery']['knife_config_file']['group'] }
  mode lazy { node['grocery_delivery']['knife_config_file']['mode'] }
end if node['grocery_delivery']['manage_knife_config']

cron_d 'grocery-delivery' do
  minute lazy { node['grocery_delivery']['cron']['minute'] }
  hour lazy { node['grocery_delivery']['cron']['hour'] }
  day lazy { node['grocery_delivery']['cron']['day'] }
  month lazy { node['grocery_delivery']['cron']['month'] }
  weekday lazy { node['grocery_delivery']['cron']['weekday'] }
  user lazy { node['grocery_delivery']['cron']['user'] }
  command lazy { node['grocery_delivery']['cron']['command'] }
  mailto lazy { node['grocery_delivery']['cron']['mailto'] }
  path lazy { node['grocery_delivery']['cron']['path'] }
  home lazy { node['grocery_delivery']['cron']['home'] }
  environment lazy { node['grocery_delivery']['cron']['environment'] }
  mode lazy { node['grocery_delivery']['cron']['mode'] }
end if node['grocery_delivery']['manage_cron']
