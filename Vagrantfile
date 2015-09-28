# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
vagrantrc = YAML.load_file('vagrantrc.yml') rescue {}

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

unless Vagrant.has_plugin?("vagrant-hostmanager")
  puts "You do not appear to have the `vagrant-hostmanager` plugin installed.\nPlease run `vagrant plugin install vagrant-hostmanager` and try again.\n\n"
  exit 1
end


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "grahamb/ubuntu-trusty64-uid501"

  network_type = 'dhcp' unless vagrantrc[:ip_address]
  if network_type == 'dhcp'
    config.vm.network :private_network, type: 'dhcp'
  else
    config.vm.network :private_network, ip: vagrantrc[:ip_address]
  end

  config.vm.hostname = vagrantrc[:hostname] || "canvas.dev"
  files_domain = "files.#{config.vm.hostname}"

  config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
    if vm.id
      `VBoxManage guestproperty get #{vm.id} "/VirtualBox/GuestInfo/Net/1/V4/IP"`.split()[1]
    end
  end
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.aliases = [ "files.#{config.vm.hostname}" ]

  config.vm.synced_folder ".", "/vagrant", type: :nfs
  vagrantrc[:mount_directories].to_a.each do |d|
    local_path_exists = File.exists? d[:local_path]
    config.vm.synced_folder d[:local_path], d[:mount_at], type: :nfs if local_path_exists
  end

  config.vm.provider "virtualbox" do |v|

    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

    host = RbConfig::CONFIG['host_os']

    # Give VM 1/4 system memory & access to all cpu cores on the host
    if host =~ /darwin/
      cpus = `sysctl -n hw.ncpu`.to_i
      # sysctl returns Bytes and we need to convert to MB
      # host_mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024
    elsif host =~ /linux/
      cpus = `nproc`.to_i
      # meminfo shows KB and we need to convert to MB
      # host_mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024
    else # sorry Windows folks, I can't help you
      cpus = 2
      mem = 2048
    end

    v.customize ["modifyvm", :id, "--memory", 4096]
    v.customize ["modifyvm", :id, "--cpus", cpus]
  end

  config.vm.provision :shell, :inline => vagrantrc[:pre_provision_script], run: 'always' if vagrantrc[:pre_provision_script]

  config.vm.provision "ansible" do |ansible|
    ansible.verbose  = "vvv"
    ansible.playbook = "provision/vagrant.yml"
  end

  config.vm.provision :shell, :inline => "sudo service canvas_init restart && sudo service apache2 restart", run: "always"
  config.vm.provision :shell, :inline => vagrantrc[:post_provision_script], run: 'always' if vagrantrc[:post_provision_script]

end
