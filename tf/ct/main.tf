provider "proxmox" {
    pm_api_url = var.proxmox_host["pm_api_url"]
    pm_user = var.proxmox_host["pm_user"]
    pm_tls_insecure = true
}


resource "proxmox_lxc" "container" {
  count = length(var.hostnames)
  hostname = var.hostnames[count.index]
  target_node = var.proxmox_host["target_node"]
  vmid = var.vmid + count.index
  cores = 1
  memory = 2048

  ostemplate = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
  ostype = "ubuntu"
  unprivileged = "true"
  start = "true"


  rootfs {
    storage = "local-lvm"
    size = var.rootfs_size
  }
  swap = 0



  # Mountpoints don't work yet in 2.6.6 unfortunately.
/*  mountpoint {
    key = "1"
    #slot = 0
    storage = "/tank/downloads"
    mp = "/downloads"
    #size = "100G" #this is required
  }*/

  network {
    ip = format("%s/24", var.ips[count.index])
    name ="eth0"
    bridge = "vmbr0"
    # firewall = "true" # this does not work at the moment
    gw = cidrhost(format("%s/24", var.ips[count.index]), 1)
  }

  ssh_public_keys = file(var.ssh_keys["pub"])
  
  #creates ssh connection to check when the CT is ready for ansible provisioning
  connection {
    host = var.ips[count.index]
    user = var.user
    private_key = file(var.ssh_keys["priv"])
    agent = false
    timeout = "3m"
  } 

  provisioner "remote-exec" {
	  # Leave this here so we know when to start with Ansible local-exec 
    inline = [ "echo 'Cool, we are ready for provisioning'"]
  }
  
  provisioner "local-exec" {
      working_dir = "../../ansible/"
      command = "ansible-playbook -u ${var.user} --key-file ${var.ssh_keys["priv"]} -i ${var.ips[count.index]}, provision.yaml"
  }
}


