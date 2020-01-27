#!/bin/bash
. utils.sh ; check_if_root

ssh-keygen
ssh-copy-id root@ceph-node1
ssh-copy-id root@ceph-node2
ssh-copy-id root@ceph-node3
ssh-copy-id root@client1
