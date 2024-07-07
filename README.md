# Ceph All-in-One

## Description

## Getting started

### Dependencies

* Linux/Windows/Mac
* [Virtualbox](https://www.virtualbox.org/wiki/Downloads) 6.x/7.x
* [Vagrant](https://developer.hashicorp.com/vagrant/install) >= 2.4.0

### Installation

```git clone https://github.com/stor01com/ceph-aio-ansible.git```

### Quick start

```
git clone https://github.com/stor01com/ceph-aio-ansible.git
cd ceph-aio-ansible
vagrant up ceph-aio-pacific
vagrant ssh ceph-aio-pacific
```


### Configuration

Please see [vagrant.yml.sample](vagrant.yml.sample) for details.

### Usage

List all defined VMs and their status
```vagrant status [vm-name]```

```bash
$ vagrant status
Current machine states:

ceph-nautilus             not created (virtualbox)
ceph-octopus              not created (virtualbox)
ceph-pacific              not created (virtualbox)
ceph-quincy               not created (virtualbox)
ceph-reef                 not created (virtualbox)
...
```

Bring up all VMs defined in vagrant.yml file
```vagrant up```

Bring up a specific VM
```vagrant up [vm-name]```

Run a VM without provisioning
```vagrant up [vm-name] --no-provision```

Provision a VM with a specific provisioner
```vagrant up [vm-name] --provision-with [bootstrap,setup-cephadm-ansible,cephadm-ansible,cephadm-bootstrap]```

Reload (update hardware, add disks etc.) without provisioning a VM again
```vagrant reload --no-provision```

Destroy all or single VM. `-f` force.
```vagrant destroy [vm-name] [-f]```

Access VM via ssh
```vagrant ssh [vm-name]```

## Related

- [Vagrant documentation](https://developer.hashicorp.com/vagrant/docs)
- [ceph-ansible (Quincy branch)](https://github.com/ceph/ceph-ansible/tree/stable-7.0)
- [ceph-ansible docs](https://docs.ceph.com/projects/ceph-ansible/en/latest/)
- [cephadm-ansible](https://github.com/ceph/cephadm-ansible)
- [cephadm docs (latest)](https://docs.ceph.com/en/latest/cephadm/)

<!--
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo swapon --show
 -->
