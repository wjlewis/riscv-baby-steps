include ../Makefile.defs

counter: counter.o main.ld
	$(LD) -T main.ld counter.o -o counter

counter.o: counter.S
	$(AS) -g counter.S -o counter.o

qemu: counter
	$(QEMU) -machine virt \
			-bios none \
			-kernel counter \
			-smp 1 \
			-m 1M \
			-nographic \
			-S \
			-gdb tcp::1234

gdb: counter
	$(GDB) counter

.PHONY: clean
clean:
	rm -f counter counter.o
