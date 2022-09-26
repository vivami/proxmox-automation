variable "proxmox_host" {
  type = map(any)
  default = {
    pm_api_url  = "https://10.0.42.50:8006/api2/json"
    pm_user     = "root@pam"
    target_node = "pve"
  }
}

variable "vmid" {
  default     = 300
  description = "Starting ID for the CTs"
}


variable "hostnames" {
  type        = list(string)
  default     = ["prod-ct"]
  description = "Containers to be created"
}


variable "rootfs_size" {
  default     = "2G"
  description = "Root filesystem size in GB"
}

variable "ips" {
  type        = list(string)
  default     = ["10.0.42.83"]
  description = "IPs of the containers, respective to the hostname order"
}

variable "user" {
  default     = "root"
  description = "Ansible user used to provision the container"
}

variable "ssh_keys" {
  type = map(any)
  default = {
    pub  = "~/.ssh/id_ed25519-pwless.pub"
    priv = "~/.ssh/id_ed25519-pwless"
  }
}
