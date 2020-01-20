#!/bin/bash
. utils.sh ; check_if_root

echo "
---
#True causes error https://github.com/ceph/ceph-ansible/commit/93826e061d3d025fa631d726ada1c7a7d77c12b1
dashboard_enabled: False

fetch_directory: ~/ceph-ansible-keys
ceph_origin: repository
ceph_repository: community
ceph_stable_release: nautilus
monitor_interface: eth1
public_network: 192.168.100.0/24
cluster_network: 192.168.100.0/24
devices:
  - /dev/sdb
  - /dev/sdc
  - /dev/sdd
" > ceph-ansible/group_vars/all.yml

sed -e 's/^retry_files_enabled = False/retry_files_enabled = True/' -i ceph-ansible/ansible.cfg
