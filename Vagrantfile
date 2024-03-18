# -*- mode: ruby -*-
# vi: set ft=ruby :

SALT_VERSION = ENV['SALT_VERSION'] || '3006.7'

# Supported distributions/versions

BOXES = {
        'centos'   =>  {
          '7' => 'bento/centos-7.8',
          '8' => 'bento/almalinux-8.9',
          '9' => 'bento/almalinux-9.3',
          'default' => '9'
        },
        'ubuntu'   =>  {
          '2304' => 'bento/ubuntu-23.04',
          '2210' => 'bento/ubuntu-22.10',
          'default' => '2210'
        },
        # 'windows'  =>  {
        #   '2012' => 'devopsgroup-io/windows_server-2012r2-standard-amd64-nocm',
        #   'default' => '2012'
        # },
        'rhel'  =>  {
          '7' => 'generic/rhel7',
          '8' => 'generic/rhel8',
          'default' => '8'
        }
  }

# Default distribution is AlmaLinux version 9
# Use LINUX_DISTRO and LINUX_VERSION to override

LINUX_DISTRO = ENV['LINUX_DISTRO'] || ENV['LINUX_DISTRIBUTION'] || 'centos'
LINUX_VERSION = ENV['LINUX_VERSION'] || BOXES[LINUX_DISTRO]['default']

if not BOXES[LINUX_DISTRO].has_key?(LINUX_VERSION)
  puts "Invalid version '#{LINUX_VERSION}' for #{LINUX_DISTRO}!\n\nValid versions: #{BOXES[LINUX_DISTRO].keys}"
  Kernel.exit(1)
end

LINUX_BOX = BOXES[LINUX_DISTRO][LINUX_VERSION]
puts "Chose Linux image #{LINUX_BOX} from args LINUX_DISTRO=#{LINUX_DISTRO} LINUX_VERSION=#{LINUX_VERSION}"

LINUX_MINION_COUNT = ENV['LINUX_MINION_COUNT'] || '1'
LINUX_BOX_RAM = ENV['LINUX_BOX_RAM'] || '1024'


LINUX_SCRIPT = <<EOF
test -f /etc/sysconfig/network-scripts/ifcfg-enp0s8 && ifup enp0s8
if [[ $(hostname -s) == 'saltmaster' ]]; then
  mkdir -p /etc/salt
  echo -e 'roles:\n  - salt_master' > /etc/salt/grains
fi
EOF

Vagrant.configure('2') do |config|
  config.trigger.before :up do |trigger|
    trigger.name = "Create ./dist folder"
    trigger.info = "Running 'make' to create ./dist folder..."
    trigger.run = {inline: "make"}
  end
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
 saltmaster.vm.network 'private_network', ip: '192.168.56.4'
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
 linux.vm.network 'private_network', ip: "192.168.56.#{i+4}"
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
end
