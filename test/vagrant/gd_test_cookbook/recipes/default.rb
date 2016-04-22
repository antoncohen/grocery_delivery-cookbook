#
# Cookbook Name:: gd_test_cookbook
# Spec:: default
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

require 'securerandom'

include_recipe 'chef-server'

directory '/etc/chef-server/validators' do
  owner 'root'
  group 'root'
  mode '0700'
  recursive true
end

validator = '/etc/chef-server/validators/exampleorg-validators.pem'
create_org = "chef-server-ctl org-create exampleorg 'Example Org' -f #{validator}"

execute 'create example org' do
  command create_org
  sensitive true
  not_if 'chef-server-ctl org-show exampleorg'
end

file validator do
  owner 'root'
  group 'root'
  mode '0600'
end

directory '/etc/grocery-delivery'

user_key = '/etc/grocery-delivery/grocery-delivery.pem'
create_user = 'chef-server-ctl user-create grocery-delivery Grocery Delivery chef-admin@example.com'
user_args = "-f #{user_key} -o exampleorg"

execute 'create grocery-delivery user' do
  command "#{create_user} #{SecureRandom.urlsafe_base64(rand(39..48))} #{user_args}"
  sensitive true
  not_if 'chef-server-ctl user-show grocery-delivery'
end

file user_key do
  owner 'root'
  group 'root'
  mode '0600'
end

repo_url = 'https://github.com/chef-training/chef-fundamentals-repo.git'
repo_path = '/var/chef/grocery_delivery_work/chef-fundamentals-repo'
server = 'https://127.0.0.1/organizations/exampleorg'

node.default['grocery_delivery']['manage_cron'] = false
node.default['grocery_delivery']['config']['repo_url'] = "'#{repo_url}'"
node.default['grocery_delivery']['config']['reponame'] = "'chef-fundamentals-repo'"
node.default['grocery_delivery']['knife_config']['chef_server_url'] = "'#{server}'"
node.default['grocery_delivery']['knife_config']['ssl_verify_mode'] = ':verify_none'
node.default['grocery_delivery']['knife_config']['chef_repo_path'] = "'#{repo_path}'"

include_recipe 'grocery_delivery'

# To upload repo run:
# /usr/local/bin/grocery-delivery -c /etc/grocery-delivery/config.rb -v
#
# To list uploaded cookbooks run:
# /opt/chef/bin/knife cookbook list -c /etc/grocery-delivery/knife.rb
