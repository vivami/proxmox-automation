variable "proxmox_host" {
	type = map
     default = {
       pm_api_url = "https://10.0.42.50:8006/api2/json"
       pm_user = "root@pam"
       target_node = "pve"
     }
}

variable "vmid" {
  default     = 400
  description = "Starting ID for the VMs"
}


variable "hostnames" {
  type        = list(string)
  default     = ["prod-vm", "staging-vm", "dev-vm"]
  description = "VMs to be created"
}

variable "image_name" {
  type        = string
  default     = "cloud-init-focal"
  description = "The name of the image to be cloned."
}

variable "storage_pool_name" {
  type        = string
  default     = "local-lvm"
  description = "Name of the storage pool used to creat the VM vdisk."
}

variable "rootfs_size" {
  default = "2G"
}

variable "ips" {
  type        = list(string)
  default     = ["10.0.42.80", "10.0.42.81", "10.0.42.82"]
  description = "IPs of the VMs, respective to the hostname order"
}

variable "ssh_keys" {
  type = map(any)
  default = {
    pub  = "~/.ssh/id_ed25519-pwless.pub"
    priv = "~/.ssh/id_ed25519-pwless"
  }
}

variable "ssh_password" {}

variable "user" {
  default     = "notroot"
  description = "User used to SSH into the machine and provision it"
}
