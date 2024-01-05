include ../Makefile.defs

fact.o: fact.c
	$(GCC) -O1 -c -g fact.c -o fact.o

main.o: main.s
	$(AS) -g main.s -o main.o

main: main.o fact.o main.ld
	$(LD) -T main.ld -o main main.o fact.o

qemu: main
	$(QEMU) -machine virt \
			-bios none \
			-kernel main \
			-smp 1 \
			-m 1M \
			-nographic \
			-S \
			-gdb tcp::1234

gdb: main
	$(GDB) main

.PHONY: clean
clean:
	rm -f *.o main
