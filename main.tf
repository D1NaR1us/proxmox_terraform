resource "proxmox_vm_qemu" "k8smaster" {
  count = 1
  name = "k8smaster" 
  desc = "k8s master host"
  vmid = "10${count.index+2}"
  target_node = "proxmox"

  agent = 1

  clone = "template-ubuntu"
  os_type = "cloud-init"
  cores = 2
  sockets = 1

  memory = 4096
  scsihw = "virtio-scsi-single"
  bootdisk = "scsi0"
  onboot = true

  disk {
    slot = 0
    size = "50G"
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

  ipconfig0 = "ip=192.168.50.2${count.index}/24,gw=192.168.50.1"
  searchdomain = "192.168.50.1"
  nameserver = "192.168.50.1"
  sshkeys = file("./secrets/id_rsa.pub")
}

resource "proxmox_vm_qemu" "k8sworker" {
  count = 2
  name = "k8sworker${count.index+1}" 
  desc = "k8s worker host"
  vmid = "10${count.index+3}"
  target_node = "proxmox"

  agent = 1

  clone = "template-ubuntu"
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  
  memory = 8192
  scsihw = "virtio-scsi-single"
  bootdisk = "scsi0"
  onboot = true

  disk {
    slot = 0
    size = "50G"
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

  ipconfig0 = "ip=192.168.50.2${count.index+1}/24,gw=192.168.50.1"
  searchdomain = "192.168.50.1"
  nameserver = "192.168.50.1"
  sshkeys = file("./secrets/id_rsa.pub")
}
