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

It's assumed that:

1) **192.168.100.0/24** network is available in your local machine (not used) to be created and managed by VirtualBox.
2) A HTTP Proxy is running on the host https://iaas.sig.nafiux.org/spikes/squid_proxy at 192.168.100.1:3128

Glossary: https://docs.ceph.com/docs/master/glossary/

## Stage 1 - Provisioning Virtual Machines

Deploy the virtual environment:

```Shell
vagrant up
```

At this point, **4** VirtualBox instances should be up and running, it's recommended to take a `clean` snapshot:

```Shell
./snapshots.sh save clean
```

SSH to `ceph-node1`

```Shell
vagrant ssh ceph-node1
```

Change working directory to `/vagrant/steps`

```Shell
cd /vagrant/steps
```

Execute the steps (one-by-one) listed in the directory

```Shell
sudo ./001-ssh-config.sh # passwd: vagrant for ssh users
sudo ./002-clone-ceph-ansible.sh
sudo ./003-ansible-set-hosts-node1-only.sh
sudo ./004-mkdir-ceph-ansible-keys.sh
sudo ./005-configure-all-yml.sh
sudo ./006-execute-ansible-playbook.sh
```

After the step `006-execute-ansible-playbook.sh`, you should have a healthy cluster with **1 node** up and running, validate the status of the cluster with `sudo ceph -s`

```Shell
    [vagrant@ceph-node1 steps]$ sudo ceph -s
      cluster:
        id:     6c34b5a0-3999-4193-948d-8e75eff33850
        health: HEALTH_OK
     
      services:
        mon: 1 daemons, quorum ceph-node1 (age 119s)
        mgr: ceph-node1(active, since 86s)
        osd: 3 osds: 3 up (since 52s), 3 in (since 52s)
     
      data:
        pools:   0 pools, 0 pgs
        objects: 0 objects, 0 B
        usage:   3.0 GiB used, 54 GiB / 57 GiB avail
        pgs:     
```

It's time to take another snapshot for this stage, execute the following command from the host machine (exit the virtual machine):

```Shell
./snapshots.sh save stage1-one-node-cluster
```

## Stage 2 - Scaling up the Cluster, adding 2 additional nodes

Update `/etc/ansible/hosts` file with the 3 hosts, and execute the playbook again.

```Shell
sudo ./007-ansible-set-all-hosts.sh
sudo ./006-execute-ansible-playbook.sh
```

After the step `006-execute-ansible-playbook.sh`, you should have a healthy cluster with **3 nodes** up and running, validate the status of the cluster with `sudo ceph -s`

```Shell
[vagrant@ceph-node1 steps]$ sudo ceph -s
  cluster:
    id:     6c34b5a0-3999-4193-948d-8e75eff33850
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum ceph-node1,ceph-node2,ceph-node3 (age 3m)
    mgr: ceph-node1(active, since 3h), standbys: ceph-node2, ceph-node3
    osd: 9 osds: 9 up (since 20s), 9 in (since 20s)
 
  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   9.0 GiB used, 162 GiB / 171 GiB avail
    pgs:
```

It's time to take another snapshot for this stage, execute the following command from the host machine (exit the virtual machine):

```Shell
./snapshots.sh save stage2-three-nodes-cluster
```

## Stage 3 - Ceph Block Device

At this point, the ceph cluster is ready, and it's time to configure the first client.

SSH into `client1` to check for RBD support in the kernel:

```Shell
vagrant ssh client1
cat /etc/centos-release # 1) Check OS version
uname -r                # 2) Check Kernel version
sudo modprobe rbd       # 3) Check RBD support
echo $?                 # 4) Print exit code, should be 0
```

SSH into `ceph-node1` to add `client1` as **ceph client** in `/etc/ansible/hosts` and run the playbook again:

```Shell
sudo ./008-ansible-add-client1-to-hosts.sh
sudo ./006-execute-ansible-playbook.sh
```

With the default configuration in `client1`, try to connect to ceph by executing:

```Shell
vagrant ssh client1
sudo ceph -s
```

You will get `[errno 13] error connecting to the cluster` which is a **Permission denied** error because authentication hasn't configured on `client1` yet.

Before configure authentication, we need to create a **pool** that will be used to store **block device** objects, since no default pools are created after [Luminous release](https://ceph.com/community/new-luminous-pool-tags/).

```Shell
# List available pools
sudo ceph osd lspools # No results should be returned.

# Create a new pool, see:
# 1) https://www.marksei.com/ceph-pools-beginners-guide/
# 2) https://docs.ceph.com/docs/nautilus/rados/operations/placement-groups/#choosing-the-number-of-placement-groups
# 3) https://www.marksei.com/rbd-images-ceph-beginner/
# PGs = (9 * 100) / 3 = 300, nearest power of 2: 512
sudo ceph osd pool create rbd 512 512

# Initialize rbd pool
sudo rbd pool init

# List available pools
sudo ceph osd lspools # 1 pool
```

Let's create a RBD client:

```Shell
vagrant ssh ceph-node1
sudo ceph auth get-or-create client.rbd mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=rbd'

# Example output:
[client.rbd]
        key = AQAiXi5eArcOKxAAFGMdBJhjvBwCz44QmGNSMg==
```

Add key to `client1` machine for `client.rbd` user:

```Shell
vagrant ssh ceph-node1
sudo ceph auth get-or-create client.rbd mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=rbd' | sudo ssh root@client1 tee /etc/ceph/ceph.client.rbd.keyring
```

Validate if `client1` can communicate with ceph:

```Shell
vagrant ssh client1
sudo ceph -s --name client.rbd
```

## Create a Ceph Block Device

```Shell
vagrant ssh client1
sudo rbd --name client.rbd create rbd1 --size 10240
sudo rbd --name client.rbd --image rbd1 info
```

## Mapping Ceph Block Device

```Shell
vagrant ssh client1
sudo rbd --name client.rbd map --image rbd1
```

TODO: I'm here.

# Common commands used by **Ceph** admins

Note: The output of these commands was captured right after the **stage 2**.

`ceph -s # or ceph status`

```Shell
[vagrant@ceph-node1 ~]$ sudo ceph -s # or ceph status
  cluster:
    id:     6c34b5a0-3999-4193-948d-8e75eff33850
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum ceph-node1,ceph-node2,ceph-node3 (age 51s)
    mgr: ceph-node1(active, since 111s), standbys: ceph-node2, ceph-node3
    osd: 9 osds: 9 up (since 55s), 9 in (since 41m)
 
  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   9.1 GiB used, 162 GiB / 171 GiB avail
    pgs:   
```

`ceph health detail`

```Shell
[vagrant@ceph-node1 ~]$ sudo ceph health detail
HEALTH_OK
```

`ceph -w`

```Shell
[vagrant@ceph-node1 ~]$ sudo ceph -w
  cluster:
    id:     6c34b5a0-3999-4193-948d-8e75eff33850
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum ceph-node1,ceph-node2,ceph-node3 (age 77s)
    mgr: ceph-node1(active, since 2m), standbys: ceph-node2, ceph-node3
    osd: 9 osds: 9 up (since 82s), 9 in (since 42m)
 
  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   9.1 GiB used, 162 GiB / 171 GiB avail
    pgs:
```

`ceph quorum_status --format json-pretty`

```Json
{
    "election_epoch": 24,
    "quorum": [
        0,
        1,
        2
    ],
    "quorum_names": [
        "ceph-node1",
        "ceph-node2",
        "ceph-node3"
    ],
    "quorum_leader_name": "ceph-node1",
    "quorum_age": 106,
    "monmap": {
        "epoch": 3,
        "fsid": "6c34b5a0-3999-4193-948d-8e75eff33850",
        "modified": "2020-01-22 07:04:45.245224",
        "created": "2020-01-22 04:01:42.550178",
        "min_mon_release": 14,
        "min_mon_release_name": "nautilus",
        "features": {
            "persistent": [
                "kraken",
                "luminous",
                "mimic",
                "osdmap-prune",
                "nautilus"
            ],
            "optional": []
        },
        "mons": [
            {
                "rank": 0,
                "name": "ceph-node1",
                "public_addrs": {
                    "addrvec": [
                        {
                            "type": "v2",
                            "addr": "192.168.100.101:3300",
                            "nonce": 0
                        },
                        {
                            "type": "v1",
                            "addr": "192.168.100.101:6789",
                            "nonce": 0
                        }
                    ]
                },
                "addr": "192.168.100.101:6789/0",
                "public_addr": "192.168.100.101:6789/0"
            },
            {
                "rank": 1,
                "name": "ceph-node2",
                "public_addrs": {
                    "addrvec": [
                        {
                            "type": "v2",
                            "addr": "192.168.100.102:3300",
                            "nonce": 0
                        },
                        {
                            "type": "v1",
                            "addr": "192.168.100.102:6789",
                            "nonce": 0
                        }
                    ]
                },
                "addr": "192.168.100.102:6789/0",
                "public_addr": "192.168.100.102:6789/0"
            },
            {
                "rank": 2,
                "name": "ceph-node3",
                "public_addrs": {
                    "addrvec": [
                        {
                            "type": "v2",
                            "addr": "192.168.100.103:3300",
                            "nonce": 0
                        },
                        {
                            "type": "v1",
                            "addr": "192.168.100.103:6789",
                            "nonce": 0
                        }
                    ]
                },
                "addr": "192.168.100.103:6789/0",
                "public_addr": "192.168.100.103:6789/0"
            }
        ]
    }
}
```

`ceph mon dump`

```Shell
[vagrant@ceph-node1 ~]$ sudo ceph mon dump
dumped monmap epoch 3
epoch 3
fsid 6c34b5a0-3999-4193-948d-8e75eff33850
last_changed 2020-01-22 07:04:45.245224
created 2020-01-22 04:01:42.550178
min_mon_release 14 (nautilus)
0: [v2:192.168.100.101:3300/0,v1:192.168.100.101:6789/0] mon.ceph-node1
1: [v2:192.168.100.102:3300/0,v1:192.168.100.102:6789/0] mon.ceph-node2
2: [v2:192.168.100.103:3300/0,v1:192.168.100.103:6789/0] mon.ceph-node3
```

`ceph df`

```Shell
[vagrant@ceph-node1 ~]$ sudo ceph df
RAW STORAGE:
    CLASS     SIZE        AVAIL       USED       RAW USED     %RAW USED 
    hdd       171 GiB     162 GiB     52 MiB      9.1 GiB          5.29 
    TOTAL     171 GiB     162 GiB     52 MiB      9.1 GiB          5.29 
 
POOLS:
    POOL     ID     STORED     OBJECTS     USED     %USED     MAX AVAIL
```

`ceph mon stat`

```Shell
[vagrant@ceph-node1 ~]$ sudo ceph mon stat
e3: 3 mons at {ceph-node1=[v2:192.168.100.101:3300/0,v1:192.168.100.101:6789/0],ceph-node2=[v2:192.168.100.102:3300/0,v1:192.168.100.102:6789/0],ceph-node3=[v2:192.168.100.103:3300/0,v1:192.168.100.103:6789/0]}, election epoch 24, leader 0 ceph-node1, quorum 0,1,2 ceph-node1,ceph-node2,ceph-node3
```

`ceph osd stat`

```Shell
[vagrant@ceph-node1 ~]$ sudo ceph osd stat
9 osds: 9 up (since 2m), 9 in (since 43m); epoch: e45
```

`ceph osd pool stats`

```Shell
[vagrant@ceph-node1 ~]$ sudo ceph osd pool stats
there are no pools!
```

`ceph pg stat`

```Shell
[vagrant@ceph-node1 ~]$ sudo ceph pg stat
0 pgs: ; 0 B data, 52 MiB used, 162 GiB / 171 GiB avail
```

`ceph pg dump`

```Shell
[vagrant@ceph-node1 ~]$ sudo ceph pg dump
dumped all
version 125
stamp 2020-01-22 07:52:48.282703
last_osdmap_epoch 0
last_pg_scan 0
PG_STAT OBJECTS MISSING_ON_PRIMARY DEGRADED MISPLACED UNFOUND BYTES OMAP_BYTES* OMAP_KEYS* LOG DISK_LOG STATE STATE_STAMP VERSION REPORTED UP UP_PRIMARY ACTING ACTING_PRIMARY LAST_SCRUB SCRUB_STAMP LAST_DEEP_SCRUB DEEP_SCRUB_STAMP SNAPTRIMQ_LEN 
           
                        
sum 0 0 0 0 0 0 0 0 0 0 
OSD_STAT USED    AVAIL   USED_RAW TOTAL   HB_PEERS          PG_SUM PRIMARY_PG_SUM 
8        5.8 MiB  18 GiB  1.0 GiB  19 GiB [0,1,2,3,4,5,6,7]      0              0 
5        5.8 MiB  18 GiB  1.0 GiB  19 GiB [0,1,2,3,4,6,7,8]      0              0 
4        5.8 MiB  18 GiB  1.0 GiB  19 GiB [0,1,2,3,5,6,7,8]      0              0 
7        5.8 MiB  18 GiB  1.0 GiB  19 GiB [0,1,2,3,4,5,6,8]      0              0 
6        5.8 MiB  18 GiB  1.0 GiB  19 GiB [0,1,2,3,4,5,7,8]      0              0 
0        5.8 MiB  18 GiB  1.0 GiB  19 GiB [1,2,3,4,5,6,7,8]      0              0 
1        5.8 MiB  18 GiB  1.0 GiB  19 GiB [0,2,3,4,5,6,7,8]      0              0 
2        5.8 MiB  18 GiB  1.0 GiB  19 GiB [0,1,3,4,5,6,7,8]      0              0 
3        5.8 MiB  18 GiB  1.0 GiB  19 GiB [0,1,2,4,5,6,7,8]      0              0 
sum       52 MiB 162 GiB  9.1 GiB 171 GiB                                         

* NOTE: Omap statistics are gathered during deep scrub and may be inaccurate soon afterwards depending on utilisation. See http://docs.ceph.com/docs/master/dev/placement-group/#omap-statistics for further details.
```

`ceph osd pool ls detail`

```Shell
[vagrant@ceph-node1 ~]$ sudo ceph osd pool ls detail

```

`ceph osd tree`

```Shell
[vagrant@ceph-node1 ~]$ sudo ceph osd tree
ID CLASS WEIGHT  TYPE NAME           STATUS REWEIGHT PRI-AFF 
-1       0.16727 root default                                
-3       0.05576     host ceph-node1                         
 0   hdd 0.01859         osd.0           up  1.00000 1.00000 
 1   hdd 0.01859         osd.1           up  1.00000 1.00000 
 2   hdd 0.01859         osd.2           up  1.00000 1.00000 
-7       0.05576     host ceph-node2                         
 3   hdd 0.01859         osd.3           up  1.00000 1.00000 
 6   hdd 0.01859         osd.6           up  1.00000 1.00000 
 7   hdd 0.01859         osd.7           up  1.00000 1.00000 
-5       0.05576     host ceph-node3                         
 4   hdd 0.01859         osd.4           up  1.00000 1.00000 
 5   hdd 0.01859         osd.5           up  1.00000 1.00000 
 8   hdd 0.01859         osd.8           up  1.00000 1.00000 
```

`ceph auth list`

```Shell
[vagrant@ceph-node1 ~]$ sudo ceph auth list
installed auth entries:

osd.0
	key: AQBaySdenXUkLBAAHPhE1d+deypH355L8PflZA==
	caps: [mgr] allow profile osd
	caps: [mon] allow profile osd
	caps: [osd] allow *
osd.1
	key: AQBeySdezF+9JRAAytoRI1MQElZ9S+qYjvgxyw==
	caps: [mgr] allow profile osd
	caps: [mon] allow profile osd
	caps: [osd] allow *
osd.2
	key: AQBiySdefSaPKRAAXCy0iNxyOpbARTIArZdrZQ==
	caps: [mgr] allow profile osd
	caps: [mon] allow profile osd
	caps: [osd] allow *
osd.3
	key: AQDx9CdefMoZOhAAY3ztbydajot8dcyonKbcPQ==
	caps: [mgr] allow profile osd
	caps: [mon] allow profile osd
	caps: [osd] allow *
osd.4
	key: AQDy9CdevI98ABAA3vTO2WMaO8ll142TsP4PjQ==
	caps: [mgr] allow profile osd
	caps: [mon] allow profile osd
	caps: [osd] allow *
osd.5
	key: AQD29CdeiOrJDRAACINvU6ZrJKSrFgXsszlt8A==
	caps: [mgr] allow profile osd
	caps: [mon] allow profile osd
	caps: [osd] allow *
osd.6
	key: AQD29CderClSDBAApc/kbqhhPu7w6h0vE33/Ew==
	caps: [mgr] allow profile osd
	caps: [mon] allow profile osd
	caps: [osd] allow *
osd.7
	key: AQD69Cde3dAJJRAAEIttKUNcPOYrBnM1i9idIQ==
	caps: [mgr] allow profile osd
	caps: [mon] allow profile osd
	caps: [osd] allow *
osd.8
	key: AQD69Cde94zpJBAAhl1oFbbDwe+9geZtVjREHQ==
	caps: [mgr] allow profile osd
	caps: [mon] allow profile osd
	caps: [osd] allow *
client.admin
	key: AQAnySdec6FGIBAAsIw2+ljVdHOOhO8c423LCA==
	caps: [mds] allow *
	caps: [mgr] allow *
	caps: [mon] allow *
	caps: [osd] allow *
client.bootstrap-mds
	key: AQAnySdei7ZGIBAADogUr/E/Z2bZGfZ4+mSoYA==
	caps: [mon] allow profile bootstrap-mds
client.bootstrap-mgr
	key: AQAnySdet8RGIBAApMg8H2+oqxiYckcIBl3Jcw==
	caps: [mon] allow profile bootstrap-mgr
client.bootstrap-osd
	key: AQAnySde09FGIBAAwhTq8HEaBak7W7DtGJj2Qw==
	caps: [mon] allow profile bootstrap-osd
client.bootstrap-rbd
	key: AQAnySden99GIBAAM3EPkn8dlTnq+yv238oyPg==
	caps: [mon] allow profile bootstrap-rbd
client.bootstrap-rbd-mirror
	key: AQAnySdeguxGIBAAc56Q5fbntWKNtoVrI+pOQQ==
	caps: [mon] allow profile bootstrap-rbd-mirror
client.bootstrap-rgw
	key: AQAnySdeMftGIBAAHSMblVgRhwpAQZNxpacaEA==
	caps: [mon] allow profile bootstrap-rgw
mgr.ceph-node1
	key: AQArySdeAAAAABAAlUtauAbKIq7h1y+EIwot0A==
	caps: [mds] allow *
	caps: [mon] allow profile mgr
	caps: [osd] allow *
mgr.ceph-node2
	key: AQAZ9CdeAAAAABAAb0Q3MNfAm6P3dZKxaKs1jA==
	caps: [mds] allow *
	caps: [mon] allow profile mgr
	caps: [osd] allow *
mgr.ceph-node3
	key: AQAZ9CdeAAAAABAAT78i/LuziE/AC+g1d25OqQ==
	caps: [mds] allow *
	caps: [mon] allow profile mgr
	caps: [osd] allow *
```

# Troubleshooting

## Debian 10 (buster)

Vagrant 2.2.6 should be manually installed due a bug (https://github.com/dotless-de/vagrant-vbguest/issues/292) in 2.2.3 provided by apt.
