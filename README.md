# ceph-workshop

Step-by-step instructions to deploy a [Ceph](https://ceph.io/) cluster using [ceph-ansible](https://github.com/ceph/ceph-ansible) in a Virtual Environment.

For more information, please refer to the Infrastructure as a Service (IaaS) Special Interest Group (SIG) homepage: https://iaas.sig.nafiux.org/

## Objective

This project is aligned to the following [IaaS SIG](https://iaas.sig.nafiux.org/) objective:

**Develop technical competencies to deploy, maintain and operate a Storage solution.**

## Contribution guidelines

The following guidelines should be followed to contribute with this project:

* **Document everything.** The code should be easily readable for anyone, think about new volunteers that are learning this topic.
* **Use latest stable technologies as much as you can**. Technology landscape is always evolving, we should keep this project relevant by using up-to-date stable dependencies, as stated in the [official](https://docs.ceph.com/docs/master/start/os-recommendations/) documentation:

      For OS: As a general rule, we recommend deploying Ceph on newer releases of Linux. We also recommend deploying on releases with long-term support.

## Dependencies

* [ceph](https://ceph.io/get/) - Version: Nautilus (14.2.z)
* [ceph-ansible](https://github.com/ceph/ceph-ansible/tree/stable-4.0) - Version: stable-4.0 (which supports Ceph Nautilus)
* [Ansible](https://www.ansible.com/) - Version: 2.8.z (required by ceph-ansible stable-4.0), installation should be done with pip `pip install ansible==2.8.8` since Ansible version provided by yum isn't 2.8.z
* [Python](https://www.python.org/) - Version: 3 (latest version available on the OS)
* [CentOS 7](https://app.vagrantup.com/centos/boxes/7) - Supported by ceph nautilus
* [Vagrant](https://www.vagrantup.com/), plugins:
  * vagrant plugin install vagrant-proxyconf
* [Virtualbox](https://www.virtualbox.org/) Vagrant supports up-to 6.0.z (https://www.vagrantup.com/docs/virtualbox/), >= 6.1.z isn't supported.

# Getting started

It's assumed that **192.168.100.0/24** network is available in your local machine (not used) to be created and managed by VirtualBox.

Deploy the virtual environment:

    vagrant up

SSH to ceph-node1

    vagrant ssh ceph-node1

Change working directory to /vagrant

    cd /vagrant

Execute the steps (one-by-one) listed in the directory

    sudo ./001-ssh-config.sh
    sudo ./002-clone-ceph-ansible.sh
    ...

After the step `006-execute-ansible-playbook.sh`, you should have a healthy cluster with 1 node up and running:

      [vagrant@ceph-node1 ~]$ sudo ceph -s
      cluster:
      id:     06d67682-f3fc-49cd-a8ed-04061f4f442a
      health: HEALTH_OK
      
      services:
      mon: 1 daemons, quorum ceph-node1 (age 11h)
      mgr: ceph-node1(active, since 11h)
      osd: 3 osds: 3 up (since 11h), 3 in (since 11h)
      
      data:
      pools:   0 pools, 0 pgs
      objects: 0 objects, 0 B
      usage:   3.0 GiB used, 54 GiB / 57 GiB avail
      pgs:     

# Troubleshooting

## Debian 10 (buster)

Vagrant 2.2.6 should be manually installed due a bug (https://github.com/dotless-de/vagrant-vbguest/issues/292) in 2.2.3 provided by apt.
