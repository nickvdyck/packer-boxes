.PHONY: build-kali
build-kali:
	cd kalilinux && \
		packer build -var-file=../variables.pkrvars.hcl box.pkr.hcl
