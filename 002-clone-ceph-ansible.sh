#!/bin/bash
. utils.sh ; check_if_root

git clone https://github.com/ceph/ceph-ansible.git
cd ceph-ansible
git checkout v4.0.10
git status
python3 -m pip install -r requirements.txt
