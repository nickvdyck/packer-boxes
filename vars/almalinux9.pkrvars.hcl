version      = "9.1"
mirror       = "https://almalinux.mirrors.behostings.net"
architecture = "x86_64"
checksum     = "3eebd50aabe93b9cbea3937dcf5e1d893e397a36de128ae60a8d46ff048fa0d6"

qemu_overrides = {
  args = [
    ["-cpu", "host"]
  ]
}
