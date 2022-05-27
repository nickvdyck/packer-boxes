version      = "9.0"
mirror       = "https://almalinux.cu.be"
architecture = "x86_64"
checksum     = "d9c644122aafdb3aa6b635d252d59d7f719fa5de5e77ec103eff9c5fe291c1b6"

qemu_overrides = {
  args = [
    ["-cpu", "host"]
  ]
}
