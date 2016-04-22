#
# Cookbook Name:: grocery_delivery
# Attributes:: default
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

default['grocery_delivery']['manage_git'] = true
default['grocery_delivery']['manage_system_ruby'] = true
default['grocery_delivery']['manage_build_requirements'] = true
default['grocery_delivery']['manage_package'] = true
default['grocery_delivery']['manage_working_directory'] = true
default['grocery_delivery']['manage_config_directory'] = true
default['grocery_delivery']['manage_config'] = true
default['grocery_delivery']['manage_knife_config'] = true
default['grocery_delivery']['manage_cron'] = true

case node['platform_family']
when 'debian'
  default['grocery_delivery']['ruby_packages'] = %w(ruby ruby-dev)
else
  # RHEL-based
  default['grocery_delivery']['ruby_packages'] = %w(ruby ruby-devel)
end

case node['platform_family']
when 'debian'
  default['grocery_delivery']['build_requirements'] = %w(cmake pkg-config)
else
  # RHEL-based
  default['grocery_delivery']['build_requirements'] = %w(cmake pkgconfig)
end

# package_provider choices: 'gem_package' or 'system'
default['grocery_delivery']['package_provider'] = 'gem_package'
default['grocery_delivery']['package_name'] = 'grocery_delivery'
default['grocery_delivery']['package_version'] = nil

default['grocery_delivery']['working_directory']['path'] = '/var/chef/grocery_delivery_work'
default['grocery_delivery']['working_directory']['owner'] = 'root'
default['grocery_delivery']['working_directory']['group'] = 'root'
default['grocery_delivery']['working_directory']['mode'] = '0755'

default['grocery_delivery']['config_directory']['path'] = '/etc/grocery-delivery'
default['grocery_delivery']['config_directory']['owner'] = 'root'
default['grocery_delivery']['config_directory']['group'] = 'root'
default['grocery_delivery']['config_directory']['mode'] = '0755'

default['grocery_delivery']['config_file']['path'] = '/etc/grocery-delivery/config.rb'
default['grocery_delivery']['config_file']['owner'] = 'root'
default['grocery_delivery']['config_file']['group'] = 'root'
default['grocery_delivery']['config_file']['mode'] = '0644'

default['grocery_delivery']['knife_config_file']['path'] = '/etc/grocery-delivery/knife.rb'
default['grocery_delivery']['knife_config_file']['owner'] = 'root'
default['grocery_delivery']['knife_config_file']['group'] = 'root'
default['grocery_delivery']['knife_config_file']['mode'] = '0644'

cron_cmd = '/usr/local/bin/grocery-delivery -c /etc/grocery-delivery/config.rb > /dev/null 2>&1'
default['grocery_delivery']['cron']['minute'] = '*'
default['grocery_delivery']['cron']['hour'] = '*'
default['grocery_delivery']['cron']['day'] = '*'
default['grocery_delivery']['cron']['month'] = '*'
default['grocery_delivery']['cron']['weekday'] = '*'
default['grocery_delivery']['cron']['user'] = 'root'
default['grocery_delivery']['cron']['command'] = cron_cmd
default['grocery_delivery']['cron']['mailto'] = nil
default['grocery_delivery']['cron']['path'] = nil
default['grocery_delivery']['cron']['home'] = nil
default['grocery_delivery']['cron']['environment'] = {}
default['grocery_delivery']['cron']['mode'] = '0644'

default['grocery_delivery']['config_header'] = '# Managed by Chef'
default['grocery_delivery']['config'] = {
  'stdout' => false,
  'dry_run' => false,
  'verbosity' => false,
  'timestamp' => false,
  'config_file' => "'/etc/grocery-delivery/config.rb'",
  'pidfile' => "'/var/run/grocery_delivery.pid'",
  'lockfile' => "'/var/lock/grocery_delivery'",
  'master_path' => "'/var/chef/grocery_delivery_work'",
  'repo_url' => false,
  'reponame' => "'chef-repo'",
  'cookbook_paths' => "['cookbooks']",
  'role_path' => "['roles']",
  'databag_path' => "'data_bags'",
  'rev_checkpoint' => "'gd_revision'",
  'knife_config' => "'/etc/grocery-delivery/knife.rb'",
  'knife_bin' => "'/opt/chef/bin/knife'",
  'vcs_type' => "'git'",
  'vcs_path' => false,
  'plugin_path' => "'/etc/grocery-delivery/plugin.rb'",
  'berks' => false,
  'berks_bin' => false,
  'berks_config' => false
}

default['grocery_delivery']['knife_config_header'] = '# Managed by Chef'
default['grocery_delivery']['knife_config'] = {
  'chef_server_url' => false,
  'chef_repo_path' => "['/var/chef/grocery_delivery_work/chef-repo']",
  'node_name' => "'grocery-delivery'",
  'client_key' => "'/etc/grocery-delivery/grocery-delivery.pem'"
}
