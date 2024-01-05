# Basic

How do we run a simple assembly program using `qemu` as a RISC-V simulator?

We can list available machines with:

```
qemu-system-riscv64 -machine help
```

which outputs:

```
Supported machines are:
none                 empty machine
sifive_e             RISC-V Board compatible with SiFive E SDK
sifive_u             RISC-V Board compatible with SiFive U SDK
spike                RISC-V Spike Board (default)
spike_v1.10          RISC-V Spike Board (Privileged ISA v1.10)
spike_v1.9.1         RISC-V Spike Board (Privileged ISA v1.9.1)
virt                 RISC-V VirtIO board
```

From the [`qemu` docs](https://www.qemu.org/docs/master/system/riscv/virt.html):

> The `virt` board is a platform which does not correspond to any real hardware;
> it is designed for use in virtual machines.
> It is the recommended board type if you simply want to run a guest such as
> Linux and do not care about reproducing the idiosyncrasies and limitations of
> a particular bit of real-world hardware.

So we know that our basic command will resemble:

```
qemu-system-riscv64 -machine virt
```

Other flags allow us to configure the `virt` machine's hart count, memory, etc.

```
qemu-system-riscv64 -machine virt -smp 1 -m 1M
```

Running this command results in a warning:

```
qemu-system-riscv64: warning: No -bios option specified. Not loading a firmware.
qemu-system-riscv64: warning: This default will change in a future QEMU release. Please use the -bios option to avoid breakages when this happens.
qemu-system-riscv64: warning: See QEMU's deprecation documentation for details.
```

which we can fix by adding `-bios none`.

We can then run an ELF file using the `-kernel <filename>` option.

## Machine Architecture

The RISC-V simulator provided by `-machine virt` is more than just a processor
(hart): it includes some RAM, a UART (for reading and writing to a console), a
CLINT (which provides timer interrupts), and more.
In order to program the machine, we need to know where all of these things are
located in the address space.
We can get this information by dumping the device tree with

```
$ qemu-system-riscv64 -machine virt,dumpdtb=machine.dtb
$ dtc machine.dtb -o machine.dts
```

Among other things, this shows us that RAM starts at `0x8000_0000`:

```dts
memory@80000000 {
  device_type = "memory";
  reg = <0x00 0x80000000 0x00 0x8000000>;
};
```

and the UART is located at `0x1000_0000`:

```dts
uart@10000000 {
  interrupts = <0x0a>;
  interrupt-parent = <0x03>;
  clock-frequency = <0x384000>;
  reg = <0x00 0x10000000 0x00 0x100>;
  compatible = "ns16550a";
};
```

In this device tree file we see only a single hart.
If we want additional harts (indicated using the `smp`—symmetrical
multi-processing—option) we'll see additional harts in the device tree.

## Debugging with `gdb`

We need to start the machine in a stopped state by using the `-S` command line
switch.
We'll also add `-gdb tcp::1234`, which asks `qemu` to wait for a connection on
port 1234.
We also need to remember to include debugging information by assembling with the
`-g` option.
Once `qemu` has started, we can start `gdb` with:

```
riscv64-unknown-link-gnu-gdb <kernel-filename>
...
(gdb) target remote localhost:1234
```

We should see:

```
Reading symbols from <kernel-filename>
(gdb)
```

If not, you probably forgot to add debugging information during
compilation/assembly.

## Finally, the Kernel File

The `-kernel` flag lets us run a plain old ELF file (no bootloader required),
but we need to make sure our code is in the right spot in the address space.

```
make qemu
```

```
make gdb
```

In `gdb`:

```
(gdb) target remote :1234
(gdb) break _start
(gdb) continue
(gdb) layout src
```

## Unorganized Ideas

- Need linkerscript to put entry point at start of RAM.
- Need to assemble with debugging information so we can use `gdb`.

How do we know where to put `_start`?

We look at the "device tree" for the machine and make sure our `_start` label
points to the very beginning of RAM.

The `-kernel` option lets us supply an _ELF_ file, which is then loaded into
memory.
This is different from a file containing only instructions: `qemu` does
something "smart" with this file, loading its segments according to how they're
specified in the ELF file.

We influence where instructions are placed using a linkerscript.

Use `objdump` to check that instructions will be loaded at the correct address:

```
$ riscv64-unknown-linux-gnu-objdump -d -j .text spin

spin:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_start>:
    80000000:   0000006f                j       80000000 <_start>
```
