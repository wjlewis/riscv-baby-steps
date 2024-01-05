# Getting Started

**Goals**:

- Execute an infinite loop on an emulated RISC-V machine.
- Learn how to write a simple linkerscript.
- Learn how to examine ELF files using `readelf` and `objdump`.
- Learn some basic moves in `gdb`.

Our first step is simply to execute an infinite loop.
The assembly code for such a program is trivial:

```s
# main.S
spin:
        j spin
```

This program continually jumps to the `spin` label (i.e. going nowhere).

The real work is getting this run in `qemu`.
We can't just run assembly code in `qemu`: we need to first _assemble_ and
_link_ it.
Broadly-speaking, an assembler transforms assembly code into machine code; a
linker is used to combine multiple machine code programs into one, or rearrange
different parts of a machine code program.
(We'll only use our linker in the second capacity here since we only have a
single program.)

## Assembly

We'll use the GNU Assembler (`as`) to assemble this program:

```shell
> $TOOL_PREFIX-as -o main.o main.S
```

This should create a file named `main.o` containing the machine code equivalent
of our infinite loop.
However&mdash;and this is critical&mdash;that's not all it contains.
The freshly-created _main.o_ is an [ELF file](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format)
which contains information needed to rearrange or combine the resulting machine
code with other programs.
We can inspect the contents using `objdump`:

```shell
> $TOOL_PREFIX-objdump -D main.o

main.o:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <spin>:
   0:   0000006f                j       0 <spin>

...
```

We'll spend quite a bit of time with `objdump` in what follows.
For now it's enough to note that the "object file" _main.o_ knows about the
symbol `spin`, and it's inside a "section" named `.text`.
The `0000006f` is the machine code generated for the `j spin` instruction: the
opcode occupies the low 7 bits, which for the `j` instruction is `110_1111` in
binary.
The rest of the instruction is empty, in part because the address to jump to is
`000...000` (the number to the left of `<spin>:`).
We won't spend much time with machine code in what follows, but here it's
helpful to interpet the output of `objdump`.

## Linking

The next step is _linking_.
We typically think of linking as combining multiple object files into one (hence
the name).
However, here we have only a single object file.
In our case we're only interested in using a linker to _rearrange_ the machine
code in the object file _main.o_.

This is necessary because we need to give `qemu` extra information about how to
"load" our program.
In particular, we need to tell it where in memory it should copy different parts
of the program.
The mechanism for doing so is something we've already seen: the ELF format.
The "E" in ELF stands for "Executable" because ELF files can contain just the
kind of information we're wishing to convey here, namely where to "load"
different parts of a program.

We communicate this information to the linker using a "linkerscript":

```linkerscript
/* main.ld */
SECTIONS
{
  . = 0x1000
}
```

Remember the "Disassembly of section .text" from the `objdump` output above?
The linking process gives us an opportunity to designate how those "sections"
will be loaded into memory.
The [`SECTIONS` command](https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_mono/ld.html#SEC17)
lets us tell our linker (`ld`) how to combine and rearrange the sections in the
input object file(s).
The `. = 0x1000` is saying, "skip to address `0x1000` and then do your thing".
The effect is to move the `.text` section so that it starts at address `0x1000`
instead of `000...000`.

But enough talk, lets just try it:

```shell
> $TOOL_PREFIX-ld -T main.ld -o main main.o
```

This should create a file named `main`, yet _another_ ELF file:

```shell
> file main
main: ELF 64-bit LSB executable, UCB RISC-V, version 1 (SYSV), statically linked, not stripped
```

We can confirm that the `.text` section has been moved to `0x1000` using `objdump`:

```shell
> $TOOL_PREFIX-objdump -D main

main:     file format elf64-littleriscv


Disassembly of section .text:

0000000000001000 <spin>:
    1000:       0000006f                j       1234 <spin>

...
```

The important line here is `0000000000001000 <spin>:`.

So we can control where our code gets loaded.
But where does `qemu` expect it?
In our case, `qemu` will jump to address `0x80000000` after loading our ELF
file, so that's where we should put the first instruction.
We'll look more into how this address is determined later.

Let's adjust our linkerscript accordingly:

```linkerscript
/* main.ld */
SECTIONS
{
  . = 0x80000000;
}
```

and link again:

```shell
> $TOOL_PREFIX-ld -T main.ld -o main main.o
```

Use `objdump` and `readelf` to confirm that `spin` will now be loaded at address
`0x80000000`.

## Running

We're finally ready to run our program.
To do so, we need to execute the appropriate `qemu` command, which amounts to
telling it some information about the machine we want it to emulate.
In our case we're using the [`virt` machine](https://www.qemu.org/docs/master/system/riscv/virt.html)
and keeping many default options:

```shell
> qemu-system-riscv64 -machine virt -bios none -kernel main -nographic
```

If everything is working as expected, then your shell should just hang.
Not the most glorious payoff, and we can do better.
Press CTRL-A, followed by X to kill `qemu`.

## Debugging

Without any I/O capabilities (e.g. a `print` command) we have no way of
confirming that our infinite loop is actually working as we intend.
We can "watch" our running program using a debugger (in our case, the GNU
debugger, `gdb`).
To do so, we need to make to make a small change to our assembly command:

```shell
> $TOOL_PREFIX-as -g -o main.o main
```

The `-g` flag instructs `as` to include "debugging information" used by the
debugger.
We then need to link once again:

```shell
> $TOOL_PREFIX -T main.ld -o main main.o
```

We can confirm that debugging information is included in the final _main_
executable using `objdump`:

```shell
> $TOOL_PREFIX-objdump --section-headers main

main:     file format elf64-littleriscv

Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .text         00000004  0000000080000000  0000000080000000  00001000  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .riscv.attributes 0000002e  0000000000000000  0000000000000000  00001004  2**0
                  CONTENTS, READONLY
  2 .debug_line   00000039  0000000000000000  0000000000000000  00001032  2**0
                  CONTENTS, READONLY, DEBUGGING, OCTETS
  3 .debug_info   0000002e  0000000000000000  0000000000000000  0000106b  2**0
                  CONTENTS, READONLY, DEBUGGING, OCTETS
  4 .debug_abbrev 00000014  0000000000000000  0000000000000000  00001099  2**0
                  CONTENTS, READONLY, DEBUGGING, OCTETS
  5 .debug_aranges 00000030  0000000000000000  0000000000000000  000010b0  2**4
                  CONTENTS, READONLY, DEBUGGING, OCTETS
  6 .debug_str    0000004a  0000000000000000  0000000000000000  000010e0  2**0
                  CONTENTS, READONLY, DEBUGGING, OCTETS
```

The `.debug_...` sections contain the information that `gdb` needs.

We also need to add two additional arguments to our `qemu` command:

```shell
> qemu-system-riscv64 -machine virt -bios none -kernel main -nographic -S -gdb tcp::1234
```

The `-S` option instructs `qemu` to wait before starting; we'll control it
manually from within `gdb`.
The `-gdb tcp::1234` argument tells it to listen for an incoming connection from
`gdb` on TCP port `1234`.

After running this command, your shell should hang once again.
But this time, let's start `gdb` in a separate shell:

```shell
> TOOL_PREFIX-gdb main
```

This should start a new `gdb` session.
You should see a prompt that looks something like:

```
Reading symbols from main...
(gdb)
```

If you don't, double-check that _main_ includes debugging information using
`objdump`, and try again.

We'll first tell `gdb` to connect to `qemu`:

```
(gdb) target remote :1234
```

It should respond with:

```
Remote debugging using :1234
0x0000000000001000 in ?? ()
```

Next, let's add a breakpoint at the `spin` symbol:

```
(gdb) break spin
Breakpoint 1 at 0x80000000: file main.S, line 2.
```

With the breakpoint added, we'll start the program:

```
(gdb) continue
Continuing

Breakpoint 1, spin () at main.S:2
2               j spin
```

This indicates that `qemu` executed the `j spin` instruction, and is once again
paused at the `spin` address.
We can continue stepping through this infinite loop by executing the `step`
command:

```
(gdb) step

Breakpoint 1, spin () at main.S:2
```

It's often useful (although not too illuminating in this first case) to change
`gdb`'s "layout" to show the source code while debugging:

```
(gdb) layout src
```

This should open a split-pane view showing the assembly source code (which is
just `j spin`) in addition to the prompt.

## Makefile

TODO

## Conclusion

That's enough for now.
In the next installment we'll write and debug some basic programs in RISC-V
assembly.
