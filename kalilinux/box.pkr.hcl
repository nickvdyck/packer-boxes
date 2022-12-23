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

locals {
  version             = "2022.4"
  version_suffix      = ""
  iso_url_x86_64      = "https://cdimage.kali.org/kali-${local.version}/kali-linux-${local.version}${local.version_suffix}-installer-amd64.iso"
  iso_checksum_x86_64 = "aeb29db6cf1c049cd593351fd5c289c8e01de7e21771070853597dfc23aada28"
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
  shutdown_command = "echo 'vagrant'|sudo -S shutdown -P now"
}

source "qemu" "kalilinux" {
  iso_url            = local.iso_url_x86_64
  iso_checksum       = local.iso_checksum_x86_64
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
  format             = "qcow2"
  headless           = var.headless
  memory             = var.memory
  net_device         = "virtio-net"
  qemu_binary        = ""
  vm_name            = "kalilinux"
  output_directory   = "output-kalilinux-qemu"
}

source "virtualbox-iso" "kalilinux" {
  iso_url              = local.iso_url_x86_64
  iso_checksum         = local.iso_checksum_x86_64
  boot_command         = local.boot_command
  boot_wait            = var.boot_wait
  cpus                 = var.cpus
  memory               = var.memory
  disk_size            = var.disk_size
  headless             = var.headless
  http_directory       = "http"
  guest_os_type        = "Debian_64"
  shutdown_command     = local.shutdown_command
  ssh_username         = var.ssh_username
  ssh_password         = var.ssh_password
  ssh_timeout          = var.ssh_timeout
  guest_additions_path = "VBoxGuestAdditions_{{.Version}}.iso"
  hard_drive_interface = "sata"
  vboxmanage_post = [
    ["modifyvm", "{{.Name}}", "--memory", "2048"],
    ["modifyvm", "{{.Name}}", "--cpus", "1"]
  ]
  output_directory = "output-kalilinux-vb"
}

build {
  sources = [
    "sources.qemu.kalilinux",
    "sources.virtualbox-iso.kalilinux"
  ]

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    script          = "./scripts/setup.sh"
  }

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
      output            = "builds/kali-${local.version}.{{isotime \"20060102\"}}-x86-64.{{.Provider}}.box"
    }

    post-processor "vagrant-cloud" {
      box_tag = "nickvd/kalilinux"
      version = "${local.version}.{{isotime \"20060102\"}}"
    }
  }
}
