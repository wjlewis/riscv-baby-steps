include ../Makefile.defs

main: main.o main.ld
	$(LD) -T main.ld -o main main.o

main.o : main.S
	$(AS) -g -o main.o main.S

qemu: main
	$(QEMU) -machine virt \
	        -bios none \
			-kernel main \
			-nographic \
			-S \
			-gdb tcp::1234

gdb: main
	$(GDB) main

.PHONY: clean
clean:
	rm main main.o
