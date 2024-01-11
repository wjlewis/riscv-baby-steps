```c
/* All the data used by our (simple) processes */
struct proc {
    unsigned long a0;
    unsigned long a1;
    unsigned long a2;
    unsigned long ra;
    unsigned long pc;
}
```

When a timer interrupt occurs, we need to do two things:

1. Switch to the alternate process.
2. Setup the next timer interrupt.

```s
switch_procs:
        # Setup next interrupt
        # ...

        # Save a0.
        # Can't just use mscratch naively like this, though...
        csrw mscratch, a0
        ld a0, active_proc

        # Save registers.
        sd a1, 8(a0)
        sd a2, 16(a0)
        sd ra, 24(a0)
        csrr a1, mepc
        sd a1, 32(a0)
        csrr a1, mscratch
        sd a1, 0(a0)

        # Switch to alt proc.
        la a1, proc_a_data
        # If current proc is B, we're all set up.
        bne a0, a1, after
        # Otherwise switch from B to A.
        la a1, proc_b_data
after:
        # a1 holds address of new proc data.
        # We need to load it.
        la a0, active_proc
        # Store address of new active proc data in active_proc[0].
        sd a1, 0(a0)

        ld a0, active_proc
        ld a1, 8(a0)
        ld a2, 16(a0)
        ld ra, 24(a0)
        ld a1, 32(a0)
        csrw mepc, a1
        # Last but not least, we need to load a0.
        mv a1, a0
        sd a0, 0(a1)

        # PC of new process is in mepc.
        mret
```
