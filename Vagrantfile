# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.require_version ">= 2.0"

Vagrant.configure("2") do |config|

  config.vm.define "mdx-dev" do |dev|
    dev.vm.hostname = "mdx-dev"
    dev.vm.box = "debian/bullseye64"
    ENV['LC_ALL']="C.UTF-8"
    dev.vm.network "private_network", ip: "192.168.56.10"
    dev.vm.provider "virtualbox" do |vbbe|
      vbbe.name = "dev_mdx_vm"
      vbbe.memory = "2048"
    end
    dev.vm.synced_folder ".", "/idem-mdx", type: "rsync",
      rsync__exclude: ".git/"
  end

  # Ensure that all Vagrant machines will use the same SSH key pair.
  #config.ssh.insert_key = false

  config.vm.provision "shell", inline: <<-SHELL
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get upgrade --yes
    apt-get install --yes bash-completion python3-dev python3-pip python3-setuptools python3-apt libffi-dev libssl-dev dirmngr git vim
    git config --global core.editor "vim"
    pip install --upgrade -q -r /idem-mdx/requirements.txt 
    sudo sh /idem-mdx/install_ansible.sh
  SHELL

  # Enable provisioning with ansible - need fix
  #config.vm.provision "ansible" do |ansible|
    #ansible.compatibility_mode = "2.0"
    #ansible.limit = "all, localhost"
    #ansible.playbook = "ansible/playbook-dev.yml"
    #ansible.inventory_path = "ansible/inventories/dev/inventory.ini"
    #ansible.tags = "install-docker"
  #end
end
