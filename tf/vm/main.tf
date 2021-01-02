provider "proxmox" {
    pm_api_url = var.proxmox_host["pm_api_url"]
    pm_user = var.proxmox_host["pm_user"]
    pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "prox-vm" {
  count = length(var.hostnames)
  name = var.hostnames[count.index]
  target_node = var.proxmox_host["target_node"]
  vmid = var.vmid + count.index
  full_clone = true
  clone = "cloud-init-focal"

  cores = 2
  sockets = 1
  vcpus = 2
  memory = 2048
  balloon = 2048
  boot =  "c"
  bootdisk = "virtio0"

  scsihw = "virtio-scsi-pci"

  onboot = false
  agent =  1
  cpu = "kvm64"
  numa = true
  hotplug = "network,disk,cpu,memory"
  
  network {
    bridge = "vmbr0"
    model = "virtio"
  }
  
  ipconfig0 = "ip=${var.ips[count.index]}/24,gw=${cidrhost(format("%s/24", var.ips[count.index]), 1)}"
  
  disk {
    #id = 0
    type = "virtio"
    storage = "local-lvm"
    size = "5G"
  }

  os_type = "cloud-init"
  
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
  
  provisioner "local-exec" {
      working_dir = "../../ansible/"
      command = "ansible-playbook -u ${var.user} --key-file ${var.ssh_keys["priv"]} -i ${var.ips[count.index]}, install-qemu-guest-agent.yaml"
  }
}


