.PHONY: build.kali
build.kali:
	source .env && \
	cd kalilinux && \
		packer build -var-file=../variables.pkrvars.hcl box.pkr.hcl

.PHONY: build.rocky
build.rocky:
	cd rockylinux8 && \
		env $$(cat ../.env | xargs) packer build -only="virtualbox-iso.rockylinux8" -var-file=../variables.pkrvars.hcl box.pkr.hcl
	cd rockylinux8 && \
		env $$(cat ../.env | xargs) packer build -only="qemu.rockylinux8" -var-file=../variables.pkrvars.hcl box.pkr.hcl
