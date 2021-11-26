variable "disk_size" {
  type    = string
  default = "8"
}

variable "version" {
  type = string
}

variable "proxmox_url" {
  type    = string
  default = env("PVE_URL")
}

variable "proxmox_username" {
  type    = string
  default = env("PVE_USERNAME")
}

variable "proxmox_password" {
  type      = string
  default   = env("PVE_PASSWORD")
  sensitive = true
}

variable "proxmox_token" {
  type      = string
  default   = env("PVE_TOKEN")
  sensitive = true
}

variable "proxmox_node" {
  type    = string
  default = env("PVE_NODE")
}

variable "proxmox_storage_pool" {
  type    = string
  default = env("PVE_STORAGEPOOL")
}

variable "proxmox_storage_pool_type" {
  type    = string
  default = env("PVE_STORAGEPOOL_TYPE")
}

variable "proxmox_pool" {
  type    = string
  default = env("PVE_POOL")
}

variable "proxmox_bridge" {
  type    = string
  default = env("PVE_BRIDGE")
}

variable "proxmox_iso_file" {
  type        = string
  default     = env("PVE_ISOFILE")
}

source "proxmox-iso" "ubuntu-amd64" {
  sockets = 1
  cores = 4
  cpu_type = "host"
  memory = 2048
  boot_command = [
    "<tab>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "linux initrd=initrd.gz",
    " auto=true",
    " url={{.HTTPIP}}:{{.HTTPPort}}/tmp/preseed-proxmox.txt",
    " hostname=ubuntu",
    " net.ifnames=0",
    " DEBCONF_DEBUG=5",
    "<enter>",
  ]
  boot_wait           = "5s"
  insecure_skip_tls_verify = true
  proxmox_url         = var.proxmox_url
  username            = var.proxmox_username
  password            = var.proxmox_password
  vm_id               = 1001
  vm_name             = "ubuntu-${var.version}-amd64-pve"
  template_name       = "ubuntu-${var.version}-amd64-pve"
  node                = var.proxmox_node
  pool                = var.proxmox_pool
  os                  = "l26"
  http_directory      = "."
  unmount_iso         = true
  scsi_controller     = "virtio-scsi-pci"
  iso_file            = var.proxmox_iso_file
  network_adapters {
    bridge       = var.proxmox_bridge
    model        = "virtio"
  }
  disks {
    storage_pool          = var.proxmox_storage_pool
    storage_pool_type     = var.proxmox_storage_pool_type
    disk_size             = var.disk_size
    format                = "qcow2"
    type                  = "scsi"
  }
  vga {
    type               = "qxl"
  }
  cloud_init           = true
  cloud_init_storage_pool = var.proxmox_storage_pool
  ssh_username         = "vagrant"
  ssh_password         = "vagrant"
  ssh_timeout          = "1h"
}

build {
  sources = ["source.proxmox-iso.ubuntu-amd64"]

  provisioner "shell" {
    execute_command   = "echo vagrant | sudo -S bash {{ .Path }}"
    expect_disconnect = true
    scripts = [
      "provision-guest-additions.sh",
      "provision.sh",
    ]
  }
}
