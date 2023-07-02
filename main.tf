resource "proxmox_vm_qemu" "k8smaster" {
  count = 1
  name = "k8smaster" 
  desc = "k8s master host"
  vmid = "10${count.index}"
  target_node = "proxmox"

  agent = 1

  clone = "ubuntu-template"
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 4096
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  onboot = true

  disk {
    slot = 0
    size = "20G"
    type = "scsi"
    storage = "local-lvm"
    iothread = 1
  }
  
  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  ipconfig0 = "ip=192.168.5.2${count.index}/24,gw=192.168.5.1"
  searchdomain = "192.168.5.1"
  nameserver = "192.168.5.1"
  sshkeys = file("./secrets/id_rsa.pub")

}

resource "proxmox_vm_qemu" "k8sworker" {
  count = 1
  name = "k8sworker" 
  desc = "k8s worker host"
  vmid = "10${count.index+1}"
  target_node = "proxmox"

  agent = 1

  clone = "ubuntu-template"
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 8192
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  onboot = true

  disk {
    slot = 0
    size = "20G"
    type = "scsi"
    storage = "local-lvm"
    iothread = 1
  }
  
  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  ipconfig0 = "ip=192.168.5.2${count.index+1}/24,gw=192.168.5.1"
  searchdomain = "192.168.5.1"
  nameserver = "192.168.5.1"
  sshkeys = file("./secrets/id_rsa.pub")

}