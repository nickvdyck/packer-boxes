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
  kali_version = "2021.3"
}

source "qemu" "kalilinux" {
  iso_checksum       = "22995811b68817114c2f4bcab425377702882b9a2b19a62d8d8c6e85f691262b"
  iso_url            = "https://cdimage.kali.org/kali-2021.3/kali-linux-2021.3a-installer-amd64.iso"
  shutdown_command   = "echo 'vagrant'|sudo -S shutdown -P now"
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
  vm_name            = "kalilinux"
  boot_wait          = var.boot_wait
  boot_command = [
    "<esc><wait>",
    "/install.amd/vmlinuz<wait>",
    " auto<wait>",
    " console-setup/ask_detect=false<wait>",
    " console-setup/layoutcode=us<wait>",
    " console-setup/modelcode=pc105<wait>",
    " debconf/frontend=noninteractive<wait>",
    " debian-installer=en_US<wait>",
    " fb=false<wait>",
    " initrd=/install.amd/initrd.gz<wait>",
    " kbd-chooser/method=us<wait>",
    " netcfg/choose_interface=ens4<wait>",
    " console-keymaps-at/keymap=us<wait>",
    " keyboard-configuration/xkb-keymap=us<wait>",
    " keyboard-configuration/layout=USA<wait>",
    " keyboard-configuration/variant=USA<wait>",
    " locale=en_US<wait>",
    " netcfg/get_domain=vm<wait>",
    " netcfg/get_hostname=kali<wait>",
    " grub-installer/bootdev=/dev/sda<wait>",
    " noapic<wait>",
    " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg auto=true priority=critical",
    " -- <wait>",
    "<enter><wait>"
  ]
}

build {
  sources = [
    "sources.qemu.kalilinux"
  ]

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    script          = "./scripts/setup.sh"
  }

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    script          = "./scripts/cleanup.sh"
  }

  post-processors {
    post-processor "vagrant" {
      compression_level = "9"
      output            = "builds/kali-${local.kali_version}.{{isotime \"20060102\"}}-x86-64.{{.Provider}}.box"
    }

    post-processor "vagrant-cloud" {
      box_tag = "nickvd/kalilinux"
      version = "${local.kali_version}.{{isotime \"20060102\"}}"
    }
  }
}
