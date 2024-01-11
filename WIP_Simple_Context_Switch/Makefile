include ../Makefile.defs

main: main.o main.ld
	$(LD) -T main.ld -o main main.o

main.o: main.S
	$(AS) -g -o main.o main.S

qemu: main
	$(QEMU) -machine virt \
			-kernel main \
			-bios none \
			-nographic \
			-S \
			-gdb tcp::1234

gdb: main
	$(GDB) main

.PHONY: clean
clean:
	rm main.o main
