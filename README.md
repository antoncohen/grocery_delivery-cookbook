# grocery_delivery cookbook

grocery_delivery is a Chef cookbook to install and configure [Grocery Delivery](https://github.com/facebook/grocery-delivery), a tool for keeping your Chef Server in-sync with version control.

## Usage

In a typical configuration this recipe should be included on a Chef backend server.

```ruby
# The ['config'] and ['knife_config'] attributes are hashes of strings of Ruby code
node.default['grocery_delivery']['config']['repo_url'] = "'git@git.example.com:chef-repo.git'"
node.default['grocery_delivery']['knife_config']['chef_server_url'] = "'https://127.0.0.1/organizations/exampleorg'"
node.default['grocery_delivery']['knife_config']['ssl_verify_mode'] = ':verify_none'

include_recipe 'grocery_delivery'
```

## Settings

The default settings used by this cookbook are different than the default settings are `grocery-delivery`, mainly to make the defaults saner for non-Facebook installations. For example this cookbook defaults to using `git` instead of `svn`.

All functionally of this cookbook can be disabled with `manage_*` attributes, allowing custom functionality. For example set `['manage_cron'] = false` to use your in-house cron cookbook to manage cron.

```ruby
default['grocery_delivery']['manage_git'] = true
default['grocery_delivery']['manage_system_ruby'] = true
default['grocery_delivery']['manage_build_requirements'] = true
default['grocery_delivery']['manage_package'] = true
default['grocery_delivery']['manage_working_directory'] = true
default['grocery_delivery']['manage_config_directory'] = true
default['grocery_delivery']['manage_config'] = true
default['grocery_delivery']['manage_knife_config'] = true
default['grocery_delivery']['manage_cron'] = true
```

See attributes/default.rb for a full list of attributes.

### Required Settings

The two required settings, for which there are no sane defaults are:

* `node['grocery_delivery']['config']['repo_url']`
* `node['grocery_delivery']['knife_config']['chef_server_url']`

**Credentials are also required.** This cookbook does not manage version control credentials (e.g., SSH key for `git`) or Chef credentials (e.g., user/client key). To use Git over SSH, write a private key to `/root/.ssh/<file name>` and create a `/root/.ssh/config` similar to:

```
Host github.com
    IdentityFile ~/.ssh/<file name>
    StrictHostKeyChecking no
```

## Full Example

Full working example (used by Vagrant):

```ruby
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
```

## Vagrant

A Vagrantfile is included that configures a full Chef Server with Grocery Delivery. The recipe used is at test/vagrant/gd_test_cookbook/recipes/default.rb.

There are two Vagrant nodes available, `trusty` (default) and `centos7`.

* `vagrant up` # Boot Ubuntu 14.04
* `vagrant provision trusty` # Run Chef on trusty
* `vagrant ssh trusty` # To SSH to trusty
* `vagrant up centos7` # Boot CentOS 7
* `vagrant halt trusty` # Shutdown Ubuntu 14.04
* `vagrant destroy centos7` # Delete CentOS 7


Useful commands within the VM:

* `/usr/local/bin/grocery-delivery -c /etc/grocery-delivery/config.rb -v` # Upload to the Chef Server
* `/opt/chef/bin/knife cookbook list -c /etc/grocery-delivery/knife.rb` # List cookbooks after uploading
