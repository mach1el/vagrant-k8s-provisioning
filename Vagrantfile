# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

VAGRANT_BOX         = "debian/bullseye64"
CPUS_MASTER_NODE    = 2
CPUS_WORKER_NODE    = 1
MEMORY_MASTER_NODE  = 2048
MEMORY_WORKER_NODE  = 1024
WORKER_NODES_COUNT  = 2


Vagrant.configure(2) do |config|

  config.vm.provision "shell", path: "bootstrap.sh"
  config.vm.define "kmaster" do |node|

    node.vm.box               = VAGRANT_BOX
    node.vm.box_check_update  = false
    node.vm.hostname          = "kmaster.demo"

    node.vm.network "private_network", ip: "10.25.1.10"

    node.vm.provider :virtualbox do |v|
      v.name    = "kmaster"
      v.memory  = MEMORY_MASTER_NODE
      v.cpus    = CPUS_MASTER_NODE
    end

    node.vm.provision "shell", path: "master_bootstrap.sh"
  
  end

  (1..WORKER_NODES_COUNT).each do |i|

    config.vm.define "kworker#{i}" do |node|

      node.vm.box               = VAGRANT_BOX
      node.vm.box_check_update  = false
      node.vm.hostname          = "kworker#{i}.demo"

      node.vm.network "private_network", ip: "10.25.1.1#{i}"

      node.vm.provider :virtualbox do |v|
        v.name    = "kworker#{i}"
        v.memory  = MEMORY_WORKER_NODE
        v.cpus    = CPUS_WORKER_NODE
      end

      node.vm.provision "shell", path: "worker_bootstrap.sh"

    end
  end
end