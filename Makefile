.PHONY: build.kali
build.kali:
	cd kalilinux && \
		env $$(cat ../.env | xargs) packer build -only="qemu.kalilinux" -var-file=../variables.pkrvars.hcl box.pkr.hcl
	cd kalilinux && \
		env $$(cat ../.env | xargs) packer build -only="virtualbox-iso.kalilinux" -var-file=../variables.pkrvars.hcl box.pkr.hcl

.PHONY: build.rocky
build.rocky:
	cd rockylinux8 && \
		env $$(cat ../.env | xargs) packer build -only="qemu.rockylinux8" -var-file=../variables.pkrvars.hcl box.pkr.hcl
	cd rockylinux8 && \
		env $$(cat ../.env | xargs) packer build -only="virtualbox-iso.rockylinux8" -var-file=../variables.pkrvars.hcl box.pkr.hcl

.PHONY: build.almalinux9
build.almalinux9:
	# Doesn't work at the moment, throws a kernel panic
	cd almalinux && \
		env $$(cat ../.env | xargs) packer build -only="qemu.almalinux" -var-file=../variables.pkrvars.hcl -var-file=../vars/almalinux9.pkrvars.hcl box.pkr.hcl
	cd almalinux && \
		env $$(cat ../.env | xargs) packer build -only="virtualbox-iso.almalinux" -var-file=../variables.pkrvars.hcl -var-file=../vars/almalinux9.pkrvars.hcl box.pkr.hcl

.PHONY: build.almalinux8
build.almalinux8:
	cd almalinux && \
		env $$(cat ../.env | xargs) packer build -only="qemu.almalinux" -var-file=../variables.pkrvars.hcl -var-file=../vars/almalinux8.pkrvars.hcl box.pkr.hcl
	cd almalinux && \
		env $$(cat ../.env | xargs) packer build -only="virtualbox-iso.almalinux" -var-file=../variables.pkrvars.hcl -var-file=../vars/almalinux8.pkrvars.hcl box.pkr.hcl

.PHONY: build
build:
	$(MAKE) build.kali
	$(MAKE) build.rocky
