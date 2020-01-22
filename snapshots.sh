#!/bin/bash
case $1 in
  list)
    vagrant snapshot $1 ceph-node1
    vagrant snapshot $1 ceph-node2
    vagrant snapshot $1 ceph-node3
    ;;
  save)
    if [ -z $2 ]; then
      echo "Snapshot name should be specified as second parameter"
      exit;
    fi
    vagrant snapshot $1 ceph-node1 $2
    vagrant snapshot $1 ceph-node2 $2
    vagrant snapshot $1 ceph-node3 $2
    ;;
  restore)
    if [ -z $2 ]; then
      echo "Snapshot name should be specified as second parameter"
      exit;
    fi
    vagrant snapshot $1 ceph-node1 $2
    vagrant snapshot $1 ceph-node2 $2
    vagrant snapshot $1 ceph-node3 $2
    ;;
  *)
    echo "Options available: list, save, restore, delete"
    ;;
esac
