terraform {
    required_providers {
      proxmox = {
        source = "telmate/proxmox"
      }
    }
}

variable "proxmox_api_url" {
    type = string  
}

variable "proxmox_api_token_id" {
    type = string
    sensitive   = true
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive   = true  
}

provider "proxmox" {
    pm_api_url = "https://<type_proxmox's_ip>:8006/api2/json"
    pm_api_token_id = "root@pam!terraform"
    pm_api_token_secret = file("./secrets/token")
}