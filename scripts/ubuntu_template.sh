# wget https://cloud-images.ubuntu.com/releases/22.04/release-20230107/ubuntu-22.04-server-cloudimg-amd64.img
qm create 900 --name "ubuntu-template" --memory 2048 --cores 1 --net0 virtio,bridge=vmbr0
qm importdisk 900 ubuntu-22.04-server-cloudimg-amd64.img local-lvm
qm set 900 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-900-disk-0,discard=on,iothread=on
qm set 900 --boot c --bootdisk scsi0
qm set 900 --scsi1 local-lvm:cloudinit
qm set 900 --serial0 socket --vga serial0
qm set 900 --ipconfig0 ip=dhcp
qm resize 900 scsi0 20G
qm set 900 --agent enabled=1
qm set 900 --sshkey /root/MyGithub/proxmox_terraform/secrets/id_rsa.pub --ciuser dinar --cipassword $1
qm template 900