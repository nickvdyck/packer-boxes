variable "ssh_username" {
  type = string
}

variable "ssh_password" {
  type      = string
  default   = "vagrant"
  sensitive = true
}

variable "ssh_timeout" {
  type = string
}

variable "cpus" {
  type = number
}

variable "memory" {
  type = number
}

variable "disk_size" {
  type = number
}

variable "headless" {
  type = bool
}

variable "boot_wait" {
  type = string
}

variable "qemu_binary" {
  type    = string
  default = ""
}

locals {
  version             = "8.5"
  iso_url_x86_64      = "https://download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-${local.version}-x86_64-minimal.iso"
  iso_checksum_x86_64 = "4eb2ae6b06876205f2209e4504110fe4115b37540c21ecfbbc0ebc11084cb779"
  boot_command = [
    "<tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"
  ]
  shutdown_command = "echo 'vagrant'| sudo -S /sbin/halt -h -p"
}

source "virtualbox-iso" "rockylinux8" {
  iso_url              = local.iso_url_x86_64
  iso_checksum         = local.iso_checksum_x86_64
  boot_command         = local.boot_command
  boot_wait            = var.boot_wait
  cpus                 = var.cpus
  memory               = var.memory
  disk_size            = var.disk_size
  headless             = var.headless
  http_directory       = "http"
  guest_os_type        = "RedHat_64"
  shutdown_command     = local.shutdown_command
  ssh_username         = var.ssh_username
  ssh_password         = var.ssh_password
  ssh_timeout          = var.ssh_timeout
  hard_drive_interface = "sata"
  vboxmanage_post = [
    ["modifyvm", "{{.Name}}", "--memory", "2048"],
    ["modifyvm", "{{.Name}}", "--cpus", "1"]
  ]
  output_directory = "output-rockylinux8-vb"
}


source "qemu" "rockylinux8" {
  iso_url            = local.iso_url_x86_64
  iso_checksum       = local.iso_checksum_x86_64
  boot_command       = local.boot_command
  shutdown_command   = local.shutdown_command
  accelerator        = "kvm"
  http_directory     = "http"
  ssh_username       = var.ssh_username
  ssh_password       = var.ssh_password
  ssh_timeout        = var.ssh_timeout
  cpus               = var.cpus
  disk_interface     = "virtio-scsi"
  disk_size          = var.disk_size
  disk_cache         = "unsafe"
  disk_discard       = "unmap"
  disk_detect_zeroes = "unmap"
  disk_compression   = true
  format             = "qcow2"
  headless           = var.headless
  memory             = var.memory
  net_device         = "virtio-net"
  qemu_binary        = var.qemu_binary
  vm_name            = "rocky-linux-8-5"
  boot_wait          = var.boot_wait
  output_directory   = "output-rockylinux8-qemu"
}

build {
  sources = [
    "sources.qemu.rockylinux8",
    "sources.virtualbox-iso.rockylinux8"
  ]

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    script          = "./scripts/cleanup.sh"
  }

  post-processors {
    post-processor "vagrant" {
      compression_level = "9"
      output            = "builds/rockylinux-${replace(local.version, ".", "-")}-{{isotime \"20060102\"}}-x86-64.{{.Provider}}.box"
    }

    post-processor "vagrant-cloud" {
      box_tag = "nickvd/rockylinux8"
      version = "${local.version}.{{isotime \"20060102\"}}"
    }
  }
}
