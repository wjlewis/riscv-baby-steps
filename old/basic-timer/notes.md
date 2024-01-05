**Goal** Print a message to the UART once a second.

A little bit of work but conceptually not that complicated.

1. Setup scratch area.
2. Enable machine-mode interrupts (in general).
3. Enable machine-mode timer interrupts (needs to be done separately).
4. Setup first timer interrupt.

Difficult to find info on `qemu` clint.
Can look at `xv6` source code, or [the manual](https://static.dev.sifive.com/E31-RISCVCoreIP.pdf)
for the SiFive E31 Core Complex.

General notes:

- Watch `mstatus` (`info reg mstatus`) before and after toggling `MIE`.
- Same for `mie`
- Check `CLINT_MTIMECMP` after prepping for next interrupt:
  ```
  (gdb) x/1xg 0x2004000
  ```
- Can clear breakpoints with
  ```
  (gdb) clear timervec
  ```

## `mtvec`

> The value in the BASE field must always be aligned on a 4-byte boundary.

Hence

```s
.align 4
```

## `mstatus` and `mie`

We need to enable interrupts by toggling the `MIE` bit in the `mstatus` register.
The correct bit (`1 << 3`) can be found in the section "Machine Status Register
(`mstatus`)" in the RISC-V privileged manual.

We also need to enable timer interrupts by toggling the `MTIE` bit in the `mie`
register.
The correct bit (`1 << 7)`) can be found in section "Machine Interrupt Registers
(`mip` and `mie`)".

> There is a separate timer interrupt-enable bit, named MTIE, STIE, and UTIE for
> M-mode, S-mode, and U-mode timer interrupts respectively.

> An interrupt i will be taken if bit i is set in both mip and mie, and if
> interrupts are globally enabled.
> By default, M-mode interrupts are globally
> enabled if the hart’s current privilege mode is less than M, or if the current
> privilege mode is M and the MIE bit in the mstatus register is set.

## Scratch Space

Big concept here is `mscratch` register: it's an XLEN bit register that is
typically used to point to a scratch region of memory.
It's up to us to allocate the amount of scratch space that we need.
Within an interrupt handler, we typically swap

> The CSRRW (Atomic Read/Write CSR) instruction atomically swaps values in the
> CSRs and integer registers.
> CSRRW reads the old value of the CSR, zero-extends the value to XLEN bits,
> then writes it to integer register rd. The initial value in rs1 is written to
> the CSR.
> If rd=x0, then the instruction shall not read the CSR and shall not cause any
> of the side-effects that might occur
> on a CSR read.

So

```s
csrrw a0, mscratch, a0
```

Atomically swaps the values of `mscratch` and `a0` in a single atomic step.
