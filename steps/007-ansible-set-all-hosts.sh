#!/bin/bash
. utils.sh ; check_if_root

mkdir -p /etc/ansible
echo "
[mons]
ceph-node1
ceph-node2
ceph-node3

[osds]
ceph-node1
ceph-node2
ceph-node3
" > /etc/ansible/hosts

ansible all -m ping
