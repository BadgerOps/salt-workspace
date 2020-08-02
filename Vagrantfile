# -*- mode: ruby -*-
# vi: set ft=ruby :

SALT_VERSION = ENV['SALT_VERSION'] || '3000.3'

# Supported distributions/versions

BOXES = {'centos'   =>  {'6'    => 'bento/centos-6.8',   '7'    => 'bento/centos-7.3',  '8'    => 'bento/centos-8',  'default' => '7'},
         'ubuntu'   =>  {'1404' => 'bento/ubuntu-14.04', '1604' => 'bento/ubuntu-16.04', 'default' => '1604'},
         'windows'  =>  {'2012' => 'opentable/win-2012r2-standard-amd64-nocm',           'default' => '2012'}}

# Default distribution is CentOS version 7
# Use LINUX_DISTRO and LINUX_VERSION to override

LINUX_DISTRO = ENV['LINUX_DISTRO'] || ENV['LINUX_DISTRIBUTION'] || 'centos'
LINUX_VERSION = ENV['LINUX_VERSION'] || BOXES[LINUX_DISTRO]['default']

if not BOXES[LINUX_DISTRO].has_key?(LINUX_VERSION)
  puts "Invalid version '#{LINUX_VERSION}' for #{LINUX_DISTRO}!\n\nValid versions: #{BOXES[LINUX_DISTRO].keys}"
  Kernel.exit(1)
end

LINUX_BOX = BOXES[LINUX_DISTRO][LINUX_VERSION]
puts "Chose Linux image #{LINUX_BOX} from args LINUX_DISTRO=#{LINUX_DISTRO} LINUX_VERSION=#{LINUX_VERSION}"


# Default Windows distribution is 2012r2 standard
# Use WINDOWS_VERSION or WINDOWS_BOX to override #TODO: add win 2016 version when its available
WINDOWS_VERSION = ENV['WINDOWS_VERSION'] || BOXES['windows']['default']
WINDOWS_BOX = BOXES['windows'][WINDOWS_VERSION]

puts "Chose Windows image #{WINDOWS_BOX} from args WINDOWS_BOX=#{WINDOWS_BOX} WINDOWS_VERSION=#{WINDOWS_VERSION}"

LINUX_MINION_COUNT = ENV['LINUX_MINION_COUNT'] || '1'
LINUX_BOX_RAM = ENV['LINUX_BOX_RAM'] || '512'


LINUX_SCRIPT = <<EOF
test -f /etc/sysconfig/network-scripts/ifcfg-enp0s8 && ifup enp0s8
if [[ $(hostname -s) == 'saltmaster' ]]; then
  mkdir -p /etc/salt
  echo -e 'roles:\n  - salt_master' > /etc/salt/grains
fi
EOF

Vagrant.configure('2') do |config|
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end
  if Vagrant.has_plugin?("vagrant-hostmanager")
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = false
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  end
  config.vm.define 'saltmaster' do |saltmaster|
    saltmaster.vm.provider "virtualbox" do |v|
      v.memory = LINUX_BOX_RAM.to_i
      v.linked_clone = true
    end
    saltmaster.vm.box = LINUX_BOX
    saltmaster.vm.hostname = 'saltmaster'
    saltmaster.vm.network 'private_network', ip: '192.168.50.4'
    saltmaster.vm.synced_folder './dist', '/srv'
    saltmaster.vm.provision 'shell', inline: LINUX_SCRIPT
    saltmaster.vm.provision :salt do |salt|
      salt.install_master = true
      salt.run_highstate = false
      salt.masterless = false
      salt.install_type = 'stable'
      salt.install_args = SALT_VERSION
      salt.minion_config = 'config/minion'
      salt.master_config = 'config/master'
    end
  end
  (1..LINUX_MINION_COUNT.to_i).each do |i|
    config.vm.define "linux-#{i}" do |linux|
    linux.vm.provider "virtualbox" do |v|
      v.customize ['modifyvm', :id, '--natnet1', "10.#{i}.2.0/24"]
      v.memory = LINUX_BOX_RAM.to_i
      v.linked_clone = true
    end
    linux.vm.hostname = "linux-#{i}"
    linux.vm.box = LINUX_BOX
    linux.vm.network 'private_network', ip: "192.168.50.#{i+4}"
    linux.vm.provision 'shell', inline: LINUX_SCRIPT
    linux.vm.provision :salt do |salt|
      salt.install_master = false
      salt.run_highstate = false
      salt.masterless = false
      salt.install_type = 'stable'
      salt.install_args = SALT_VERSION
      salt.minion_config = 'config/minion'
    end
    end
  end
  config.vm.define 'windows', autostart: false do |windows|
    windows.vm.provider "virtualbox" do |v|
      v.linked_clone = true
    end
    windows.vm.box = WINDOWS_BOX
    windows.vm.hostname = 'windows'
    windows.vm.communicator = 'winrm'
    windows.winrm.username = 'Administrator'
    windows.winrm.password = 'vagrant'
    windows.vm.network 'private_network', ip: '192.168.50.6'
    windows.vm.network 'forwarded_port', host: 33389, guest: 3389
    windows.vm.provision :salt do |salt|
      salt.minion_config = 'config/minion'
      salt.masterless = false
      salt.run_highstate = true
      salt.version = SALT_VERSION
    end
  end
end
