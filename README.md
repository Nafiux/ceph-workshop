# ceph-workshop

Step-by-step instructions about how to deploy a [Ceph](https://ceph.io/) cluster.

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
* [Vagrant](https://www.vagrantup.com/) - Tested with 2.2.3 on Debian
* [Virtualbox](https://www.virtualbox.org/) - Tested with virtualbox-6.0 on Debian

# Getting started

It's assumed that **192.168.100.0/24** network is available in your local machine (not used) to be created and managed by VirtualBox.