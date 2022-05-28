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

variable "version" {
  type = string
}

variable "mirror" {
  type = string
}

variable "architecture" {
  type = string
}

variable "checksum" {
  type = string
}

variable "qemu_overrides" {
  # type = object({
  #   binary = optional(string)
  #   args   = optional(list(list(string)))
  # })
  default = {}
}

locals {
  name       = "almalinux-${replace(var.version, ".", "-")}"
  name_short = "almalinux${split(".", var.version)[0]}"
  iso_url    = "${var.mirror}/${var.version}/isos/${var.architecture}/AlmaLinux-${var.version}-${var.architecture}-minimal.iso"
  boot_command = [
    "<tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"
  ]
  shutdown_command = "echo 'vagrant'| sudo -S /sbin/halt -h -p"
}

source "virtualbox-iso" "almalinux" {
  iso_url                 = local.iso_url
  iso_checksum            = var.checksum
  boot_command            = local.boot_command
  boot_wait               = var.boot_wait
  cpus                    = var.cpus
  memory                  = var.memory
  disk_size               = var.disk_size
  headless                = var.headless
  http_directory          = "http"
  guest_os_type           = "RedHat_64"
  shutdown_command        = local.shutdown_command
  ssh_username            = var.ssh_username
  ssh_password            = var.ssh_password
  ssh_timeout             = var.ssh_timeout
  guest_additions_path    = "VBoxGuestAdditions_{{.Version}}.iso"
  virtualbox_version_file = ".vbox_version"
  hard_drive_interface    = "sata"
  vboxmanage_post = [
    ["modifyvm", "{{.Name}}", "--memory", "${var.memory}"],
    ["modifyvm", "{{.Name}}", "--cpus", "${var.cpus}"]
  ]
  output_directory = "output-${local.name}-vb"
}

source "qemu" "almalinux" {
  iso_url            = local.iso_url
  iso_checksum       = var.checksum
  boot_command       = local.boot_command
  boot_wait          = var.boot_wait
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
  machine_type       = "q35"
  format             = "qcow2"
  headless           = var.headless
  memory             = var.memory
  net_device         = "virtio-net"
  qemu_binary        = lookup(var.qemu_overrides, "binary", "")
  vm_name            = local.name
  output_directory   = "output-${local.name}-qemu"
  qemuargs           = lookup(var.qemu_overrides, "args", [])
}

build {
  sources = [
    "sources.qemu.almalinux",
    "sources.virtualbox-iso.almalinux"
  ]

  provisioner "ansible" {
    playbook_file = "../playbooks/main.yml"

    # Required due to: https://github.com/hashicorp/packer-plugin-ansible/issues/69
    ansible_ssh_extra_args = [
      "-oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa"
    ]
  }

  post-processors {
    post-processor "vagrant" {
      compression_level = "9"
      output            = "builds/${local.name}-{{isotime \"20060102\"}}-x86-64.{{.Provider}}.box"
    }

    post-processor "vagrant-cloud" {
      box_tag = "nickvd/${local.name_short}"
      version = "${var.version}.{{isotime \"20060102\"}}"
    }
  }
}
