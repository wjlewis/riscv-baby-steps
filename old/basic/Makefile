include ../Makefile.defs

spin: spin.o main.ld
	$(LD) -T main.ld spin.o -o spin

spin.o: spin.S
	$(AS) -g spin.S -o spin.o

qemu: spin
	$(QEMU) -machine virt \
			-bios none \
			-kernel spin \
			-smp 1 \
			-m 1M \
			-nographic \
			-S \
			-gdb tcp::1234

gdb: spin
	$(GDB) spin

.PHONY: clean
clean:
	rm -f spin spin.o
