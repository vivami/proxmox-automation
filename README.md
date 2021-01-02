# proxmox-automation

Automations for Proxmox using Terraform and Ansible. Can be used to setup and provision containers and virtual machines. Read [my post](https://vanmieghem.io/automating-proxmox-with-terraform-ansible/) for more information.

### Usage

1. Clone the repo and `cd proxmox-automation/tf/ct` (for a container)
2. Install `ansible` and `terraform` (on a Mac `brew install ansible terraform`)
3. Configure the variables in `var.tf` and add your public keys to `ansible/files/authorized_keys`. To provision multiple resources, add more hostnames and IP addresses to the defined list in `var.tf`.
4. `export PM_PASS='your-PVE-password'`
5. `terraform init` (this should pull in the Terraform Proxmox provider and configure the Terraform project)
6. `terraform plan -out plan`
7. `terraform apply`



### Creating a cloud-init VM template

On the pve host:

1. `apt install cloud-init`
2. Create a template VM (in this case Ubuntu 20.04):
```
wget http://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
export VM_ID="9000"
qm create 9000 --memory 2048 --net0 virtio,bridge=vmbr0 --sockets 1 --cores 2 --vcpu 2  -hotplug network,disk,cpu,memory --agent 1 --name cloud-init-focal --ostype l26
qm importdisk $VM_ID focal-server-cloudimg-amd64.img local-lvm
qm set $VM_ID --scsihw virtio-scsi-pci --virtio0 local-lvm:vm-$VM_ID-disk-0
qm set $VM_ID --ide2 local-lvm:cloudinit
qm set $VM_ID --boot c --bootdisk virtio0
qm set $VM_ID --serial0 socket
qm template $VM_ID
rm focal-server-cloudimg-amd64.img
```

