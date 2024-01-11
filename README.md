# RISC-V Baby Steps

Curious about RISC-V but not sure where to start?
Or perhaps you've tried MIT's excellent [PDOS course](https://github.com/mit-pdos/xv6-riscv)
but (like me) got stuck halfway through and feel like you need to learn a bit
more about RISC-V itself before returning.

This repository aims to be an easy introduction to RISC-V, with an emphasis on
topics relevant to operating systems.
We'll use the RISC-V GNU toolchain, `qemu`, `gdb`, `objdump`, `readelf`, and
more.
We'll learn about the ELF format and take a deeper look at linking.

## Tools

You should have the [`riscv-gnu-toolchain`](https://github.com/riscv-collab/riscv-gnu-toolchain)
installed locally.
During the installation process, a new family of tools should have been added to
your path.

**IMPORTANT** Need to add a curses development library in order for TUI mode in `gdb` to work.
Not necessary, but useful.

On my machine they all have the prefix:

```
riscv64-unknown-linux-gnu-
```

For instance, I have a version of `gcc` suitable for generating RISC-V machine
code named:

```
riscv64-unknown-linux-gnu-gcc
```

You should be able to determine your toolchain prefix by examining the contents
of _/opt/riscv/bin_:

```
ls /opt/riscv/bin
```

(or _/<prefix>/bin_ if you used a different `--prefix` during installation).
From now on I'll use `$TOOL_PREFIX` to refer to your toolchain prefix.
That is `$TOOL_PREFIX-gcc` will stand for `riscv64-unknown-linux-gnu-gcc` on my
machine.
