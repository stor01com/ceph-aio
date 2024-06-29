# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 2.4.0"

require 'yaml'
require 'ipaddr'

# Load settings from vagrant.yml or vagrant.yml.sample
if File.file?("vagrant.yml")
  settings = YAML.load_file("vagrant.yml")
else 
  settings = YAML.load_file("vagrant.yml.sample")
end

SERVERS         = settings["servers"] 
VM_CPU          = settings["vm_cpu"]
VM_MEM          = settings["vm_mem"]
OSD_COUNT       = settings["osd_count"]
OSD_SIZE        = settings["osd_size"]
NET             = settings["net"]
START_IP        = settings["start_ip"]
DEBUG           = settings["debug"] || false

BOXES = {
  "nautilus"  => "ubuntu/bionic64",
  "octopus"   => "ubuntu/focal64",
  "pacific"   => "ubuntu/focal64",
  "quincy"    => "ubuntu/focal64"
}

Vagrant.configure("2") do |config|

  config.vm.box_check_update = false
  config.vm.synced_folder ".", "/vagrant", disabled: false
    
  (1..OSD_COUNT).each do |i|
    config.vm.disk :disk, size: OSD_SIZE, name: "disk#{i}"
  end
 
  net = IPAddr.new(NET)
  ip = START_IP

  SERVERS.each do |server|

    ceph_release    = server["ceph_release"].downcase()
    server_hostname = server["hostname"]

    (puts "Ceph '#{ceph_release}' release not supported."; abort) if not BOXES.has_key?(ceph_release)

    (puts "IP #{ip} out of network scope (#{net}/#{net.prefix()})"; abort) if net.include?(ip) == false
    
    config.vm.define "#{server_hostname}" do |cephaio|

      cephaio.vm.hostname = "#{server_hostname}"
      cephaio.vm.box = BOXES[ceph_release]
      cephaio.vm.network "private_network", ip: ip

      cephaio.vm.provider "virtualbox" do |vb|   
        vb.gui = false
        vb.name = "#{server_hostname}"
        vb.cpus = VM_CPU
        vb.memory = VM_MEM
        vb.linked_clone = true
        vb.check_guest_additions = false
      end

      ip = ip.succ()

      cephaio.vm.provision "shell",
        inline: "echo provisioning #{ceph_release}"

      cephaio.vm.provision "bootstrap", type: "ansible_local" do |ansible|
        ansible.playbook = "bootstrap.yml"
        ansible.extra_vars = { CEPH_RELEASE: "#{ceph_release}" }
        ansible.compatibility_mode = "2.0"

        if DEBUG then
          ansible.verbose = '-vvvv'
        end
      end

      cephaio.vm.provision "setup", type: "ansible_local" do |ansible|
        ansible.playbook = "setup.yml"
        ansible.extra_vars = { CEPH_RELEASE: "#{ceph_release}" }
        ansible.compatibility_mode = "2.0"

        if DEBUG then
          ansible.verbose = '-vvvv'
        end
      end

      cephaio.vm.provision "ceph-ansible", type: "ansible_local" do |ansible|
        ansible.provisioning_path = "/home/vagrant/ceph-ansible"
        ansible.playbook = "site.yml.sample"
        ansible.inventory_path = "hosts"
        ansible.playbook_command = "/home/vagrant/venv/bin/ansible-playbook"

        if DEBUG then
          ansible.verbose = '-vvvv'
        end
      end

      cephaio.vm.provision "shell",
        inline: "for i in $(sudo rados lspools); do sudo ceph osd pool set $i crush_rule osd_replicated_rule; done; sudo ceph versions; sudo ceph osd tree"

    end
  end
end
