# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'securerandom'
require 'yaml'

this_dir = File.dirname(__FILE__)
vagrant_dir = File.join(this_dir, 'test', 'vagrant')
vagrant_config = YAML.load_file(File.join(vagrant_dir, 'vagrant.yml'))
error = Vagrant::Errors::VagrantError

Vagrant.configure(2) do |config|
  # Enable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`.
  config.vm.box_check_update = true

  unless Vagrant.has_plugin? 'vagrant-omnibus'
    raise error.new, 'vagrant-omnibus required, run `vagrant plugin install vagrant-omnibus`'
  end
  config.omnibus.chef_version = :latest

  unless Vagrant.has_plugin? 'vagrant-berkshelf'
    raise error.new, 'vagrant-berkshelf, run `vagrant plugin install vagrant-berkshelf`'
  end
  config.berkshelf.enabled = true
  config.berkshelf.berksfile_path = File.join(vagrant_dir, 'Berksfile')

  machines = vagrant_config['machines']
  global_recipes = vagrant_config['recipes']
  vmware_providers = %w(vmware_desktop vmware_fusion vmware_workstation)
  default_providers = vmware_providers.dup << 'virtualbox'

  machines.each do |machine|
    name = machine['name']
    uuid = machine['uuid'] || SecureRandom.uuid
    box = machine['box']
    box_version = machine['box_version']
    box_name = machine['box_name']
    box_url = machine['box_url']
    providers = machine['providers'] || default_providers
    default = machine['default'] || false
    memory = machine['memory'] || '512'
    ports = machine['ports'] || []
    recipes = machine['recipes'] || global_recipes || []
    update_apt = machine['update_apt'] || false

    raise error.new, 'vagrant.yml machines must have a name' if name.nil?

    config.vm.define name, primary: default, autostart: default do |cfg|
      if box
        cfg.vm.box = box
        cfg.vm.box_version = box_version unless box_version.nil?
      elsif box_url && box_name
        cfg.vm.box = box_name
        cfg.vm.box_url = box_url
      else
        raise error.new, 'vagrant.yml must contain box or box_name and box_url'
      end

      (providers & vmware_providers).each do |pr|
        cfg.vm.provider pr.to_sym do |v|
          v.vmx['memsize'] = memory
        end
      end

      if providers.include? 'virtualbox'
        cfg.vm.provider :virtualbox do |v|
          v.memory = memory
        end
      end

      ports.each do |port|
        host_ip = port['host_ip'] || '127.0.0.1'
        host_port = port['host_port']
        guest_ip = port['guest_ip'] || '0.0.0.0'
        guest_port = port['guest_port']
        proto = port['protocol'] || 'tcp'
        cfg.vm.network :forwarded_port,
                       host_ip: host_ip,
                       host: host_port.to_i,
                       guest_ip: guest_ip,
                       guest: guest_port.to_i,
                       protocol: proto
      end

      # Run `apt-get update` on first boot only
      apt_get_update = <<-'SCRIPT'
        export DEBIAN_FRONTEND=noninteractive
        test -e /root/first_boot || { apt-get -y update && touch /root/first_boot; }
      SCRIPT

      cfg.vm.provision 'shell', inline: apt_get_update if update_apt

      cfg.vm.provision 'chef_zero' do |chef|
        chef.node_name = uuid
        chef.nodes_path = File.join(vagrant_dir, 'nodes')

        recipes.each do |recipe|
          chef.add_recipe recipe
        end
      end
    end
  end
end
