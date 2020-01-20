#!/bin/bash
. utils.sh ; check_if_root

mkdir -p /etc/ansible
echo "
[mons]
ceph-node1

[osds]
ceph-node1
" > /etc/ansible/hosts

ansible all -m ping
