# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 2.4.0"

require 'yaml'

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
DEBUG           = settings["debug"] || false

BOXES = {
  "nautilus"  => "ubuntu/bionic64",
  "octopus"   => "ubuntu/focal64",
  "pacific"   => "ubuntu/focal64",
  "quincy"    => "ubuntu/jammy64",
  "reef"      => "ubuntu/jammy64"
}

Vagrant.configure("2") do |config|

  config.vm.box_check_update = false
  config.vm.synced_folder ".", "/vagrant", disabled: false
    
  (1..OSD_COUNT).each do |i|
    config.vm.disk :disk, size: OSD_SIZE, name: "disk#{i}"
  end
 
  SERVERS.each do |server|

    ceph_release    = server["ceph_release"].downcase()
    server_hostname = server["hostname"]
    server_ip       = server["ip"]
    deploy_with     = server["deploy_with"] || "cephadm"

    (puts "Ceph '#{ceph_release}' release not supported."; abort) if not BOXES.has_key?(ceph_release)

    config.vm.define "#{server_hostname}" do |cephaio|

      cephaio.vm.hostname = "#{server_hostname}"
      cephaio.vm.box = BOXES[ceph_release]
      cephaio.vm.network "private_network", ip: "#{server_ip}"

      cephaio.vm.provider "virtualbox" do |vb|   
        vb.gui = false
        vb.name = "#{server_hostname}"
        vb.cpus = VM_CPU
        vb.memory = VM_MEM
        vb.linked_clone = true
        vb.check_guest_additions = false
      end

      cephaio.vm.provision "shell",
        inline: "echo provisioning #{server_hostname} with #{ceph_release} release @ #{server_ip}"

      cephaio.vm.provision "bootstrap", type: "ansible_local" do |ansible|
        ansible.playbook = "bootstrap.yml"
        ansible.extra_vars = { CEPH_RELEASE: "#{ceph_release}" }
        ansible.compatibility_mode = "2.0"

        if DEBUG then
          ansible.verbose = '-vvvv'
        end
      end

      if deploy_with == "ceph-ansible"
        cephaio.vm.provision "setup-ceph-ansible", type: "ansible_local" do |ansible|
          ansible.playbook = "setup-ceph-ansible.yml"
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
      else
        cephaio.vm.provision "setup-cephadm-ansible", type: "ansible_local" do |ansible|
          ansible.playbook = "setup-cephadm-ansible.yml"
          ansible.extra_vars = { CEPH_RELEASE: "#{ceph_release}" }
          ansible.compatibility_mode = "2.0"

          if DEBUG then
            ansible.verbose = '-vvvv'
          end
        end

        cephaio.vm.provision "cephadm-ansible", type: "ansible_local" do |ansible|
          ansible.provisioning_path = "/home/vagrant/cephadm-ansible"
          ansible.playbook = "cephadm-preflight.yml"
          ansible.inventory_path = "hosts"
          ansible.playbook_command = "/home/vagrant/venv/bin/ansible-playbook"
          ansible.extra_vars = {
            ceph_origin: "community",
            ceph_release: ceph_release
          }
          if DEBUG then
            ansible.verbose = '-vvvv'
          end
        end

        cephaio.vm.provision "shell", name: "cephadm-bootstrap",
          inline: "sudo cephadm bootstrap --mon-ip=#{server_ip} --initial-dashboard-password=STOR01COM --dashboard-password-noupdate --single-host-defaults"

      end

      cephaio.vm.provision "shell",
        inline: "for i in $(sudo rados lspools); do sudo ceph osd pool set $i crush_rule osd_replicated_rule; done; sudo ceph versions; sudo ceph osd tree"

    end
  end
end
