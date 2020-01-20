Vagrant.require_version ">= 2.2.0"
VAGRANTFILE_API_VERSION = "2"

BOX='centos/7'

ceph_node1 = 'ceph-node1'
ceph_node1_disk2 = './ceph-node1/ceph-node1_disk2.vdi'
ceph_node1_disk3 = './ceph-node1/ceph-node1_disk3.vdi'
ceph_node1_disk4 = './ceph-node1/ceph-node1_disk4.vdi'

ceph_node2 = 'ceph-node2'
ceph_node2_disk2 = './ceph-node2/ceph-node2_disk2.vdi'
ceph_node2_disk3 = './ceph-node2/ceph-node2_disk3.vdi'
ceph_node2_disk4 = './ceph-node2/ceph-node2_disk4.vdi'

ceph_node3 = 'ceph-node3'
ceph_node3_disk2 = './ceph-node3/ceph-node3_disk2.vdi'
ceph_node3_disk3 = './ceph-node3/ceph-node3_disk3.vdi'
ceph_node3_disk4 = './ceph-node3/ceph-node3_disk4.vdi'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

        # Set proxy settings for all virtual machines, https://github.com/tmatilai/vagrant-proxyconf
        config.proxy.http = "http://192.168.100.1:3128/"
        config.proxy.https = "http://192.168.100.1:3128/"
        config.proxy.no_proxy = "localhost,127.0.0.1"

        ##### Configuration for ceph-node1 #####
        config.vm.define :"ceph-node1" do |node1|
                node1.vm.box = BOX
                node1.vm.network "private_network", ip: "192.168.100.101"
                node1.vm.hostname = ceph_node1
                node1.vm.synced_folder ".", "/vagrant", type: "nfs"
                node1.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
                node1.vm.provision "shell", path: "post-deploy.sh", run: "always"
                node1.vm.provider "virtualbox" do |v|
                        v.customize ["modifyvm", :id, "--memory", "1280"]
                        v.name = ceph_node1
                        v.gui = false

                        unless File.exist?(ceph_node1_disk2)
                        # Add SATA controller once
                        v.customize ["storagectl", :id, "--name", "SATA", "--add", "sata"]

                        v.customize ['createhd', '--filename', ceph_node1_disk2, '--size', 1 * 20480]
                        v.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', ceph_node1_disk2]
                        end

                        unless File.exist?(ceph_node1_disk3)
                        v.customize ['createhd', '--filename', ceph_node1_disk3, '--size', 1 * 20480]
                        v.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', ceph_node1_disk3]
                        end

                        unless File.exist?(ceph_node1_disk4)
                        v.customize ['createhd', '--filename', ceph_node1_disk4, '--size', 1 * 20480]
                        v.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', 3, '--device', 0, '--type', 'hdd', '--medium', ceph_node1_disk4]
                        end
                end
        end

        ##### Configuration for ceph-node2 #####
        config.vm.define :"ceph-node2" do |node2|
                node2.vm.box = BOX
                node2.vm.network "private_network", ip: "192.168.100.102"
                node2.vm.hostname = ceph_node2
                node2.vm.synced_folder ".", "/vagrant", type: "nfs"
                node2.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
                node2.vm.provision "shell", path: "post-deploy.sh", run: "always"
                node2.vm.provider "virtualbox" do |v|
                        v.customize ["modifyvm", :id, "--memory", "1024"]
                        v.name = ceph_node2
                        v.gui = false

                        unless File.exist?(ceph_node2_disk2)
                        # Add SATA controller once
                        v.customize ["storagectl", :id, "--name", "SATA", "--add", "sata"]

                        v.customize ['createhd', '--filename', ceph_node2_disk2, '--size', 1 * 20480]
                        v.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', ceph_node2_disk2]
                        end

                        unless File.exist?(ceph_node2_disk3)
                        v.customize ['createhd', '--filename', ceph_node2_disk3, '--size', 1 * 20480]
                        v.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', ceph_node2_disk3]
                        end

                        unless File.exist?(ceph_node2_disk4)
                        v.customize ['createhd', '--filename', ceph_node2_disk4, '--size', 1 * 20480]
                        v.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', 3, '--device', 0, '--type', 'hdd', '--medium', ceph_node2_disk4]
                        end
                end
        end

        ##### Configuration for ceph-node3 #####
        config.vm.define :"ceph-node3" do |node3|
                node3.vm.box = BOX
                node3.vm.network "private_network", ip: "192.168.100.103"
                node3.vm.hostname = ceph_node3
                node3.vm.synced_folder ".", "/vagrant", type: "nfs"
                node3.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
                node3.vm.provision "shell", path: "post-deploy.sh", run: "always"
                node3.vm.provider "virtualbox" do |v|
                        v.customize ["modifyvm", :id, "--memory", "1024"]
                        v.name = ceph_node3
                        v.gui = false

                        unless File.exist?(ceph_node3_disk2)
                        # Add SATA controller once
                        v.customize ["storagectl", :id, "--name", "SATA", "--add", "sata"]

                        v.customize ['createhd', '--filename', ceph_node3_disk2, '--size', 1 * 20480]
                        v.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', ceph_node3_disk2]
                        end

                        unless File.exist?(ceph_node3_disk3)
                        v.customize ['createhd', '--filename', ceph_node3_disk3, '--size', 1 * 20480]
                        v.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', ceph_node3_disk3]
                        end

                        unless File.exist?(ceph_node3_disk4)
                        v.customize ['createhd', '--filename', ceph_node3_disk4, '--size', 1 * 20480]
                        v.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', 3, '--device', 0, '--type', 'hdd', '--medium', ceph_node3_disk4]
                        end
                end
        end
end
