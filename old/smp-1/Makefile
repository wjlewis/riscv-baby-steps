include ../Makefile.defs

main.o: main.s
	$(AS) -g -o main.o main.s

main: main.o main.ld
	$(LD) -T main.ld -o main main.o

qemu: main
	$(QEMU) -machine virt \
			-bios none \
			-kernel main \
			-smp 2 \
			-m 1M \
			-nographic \
			-S \
			-gdb tcp::1234

gdb: main
	$(GDB) main

.PHONY: clean
clean:
	rm -f *.o main
