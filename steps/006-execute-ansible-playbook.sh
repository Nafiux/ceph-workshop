#!/bin/bash
. utils.sh ; check_if_root

cd ceph-ansible/
cp site.yml.sample site.yml
ansible-playbook site.yml
