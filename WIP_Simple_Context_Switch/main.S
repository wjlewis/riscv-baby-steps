.equ CLINT_BASE, 0x2000000
.equ CLINT_MTIMECMP, CLINT_BASE + 0x4000
.equ CLINT_MTIME, CLINT_BASE + 0xbff8

.equ INTERVAL, 0xa00000

.equ MSTATUS_MIE, 1 << 3
.equ MIE_MTIE, 1 << 7

.equ UART_ADDR, 0x10000000



.section .text
_start:
        jal setup_timer

        # Initialize proc_a, proc_b state.
        la a0, proc_a_state
        la a1, proc_a
        sd a1, 0(a0)

        la a0, proc_b_state
        la a1, proc_b
        sd a1, 0(a0)

        # Set active process.
        la a0, proc_a_state
        la a1, active_proc
        sd a0, 0(a1)

        # Prepare to jump to first process.
        ld a0, 0(a0)
        jr a0


spin:
        j spin


setup_timer:
        # Setup mtvec (direct interrupts).
        la a0, timervec
        csrw mtvec, a0

        # Enable machine-mode interrupts.
        csrr a0, mstatus
        ori a0, a0, MSTATUS_MIE
        csrw mstatus, a0

        # Enable machine-mode timer interrupts.
        csrr a0, mie
        ori a0, a0, MIE_MTIE
        csrw mie, a0

        # Setup first timer interrupt.
        li a0, CLINT_MTIME
        li a1, CLINT_MTIMECMP
        li a2, INTERVAL
        ld a3, 0(a0)
        ld a4, 0(a1)
        add a4, a3, a2
        sd a4, 0(a1)

        ret


proc_a:
        la a0, proc_a_msg
        jal print
        j proc_a


proc_b:
        la a0, proc_b_msg
        jal print
        j proc_b


# ...
print:
        li a1, UART_ADDR
print_loop:
        lb a2, 0(a0)
        beqz a2, print_done
        sb a2, 0(a1)
        addi a0, a0, 1
        j print_loop
print_done:
        ret


# Timer interrupt handler.
# Needs to:
# - Setup next interrupt.
# - Switch from the active process to the sleeping one.
.align 4
timervec:
        # Setup next timer interrupt.
        li t0, CLINT_MTIMECMP
        li t1, INTERVAL
        ld t2, 0(t0)
        add t2, t2, t1
        sd t2, 0(t0)

        # Switch to alt process.
        # Save current process.
        ld t0, active_proc
        csrr t1, mepc
        sd t1, 0(t0)
        sd ra, 8(t0)
        sd a0, 16(t0)
        sd a1, 24(t0)
        sd a2, 32(t0)

        la t1, proc_a_state
        bne t0, t1, quux
        la t1, proc_b_state
quux:
        # Address of new proc state in t1
        la t0, active_proc
        sd t1, 0(t0)
        ld ra, 8(t1)
        ld a0, 16(t1)
        ld a1, 24(t1)
        ld a2, 32(t1)

        ld t2, 0(t1)
        csrw mepc, t2


        mret



.section .data

# Process data.
# pc
# ra
# a0
# a1
# a2
proc_a_state:     .space 5 * 8
proc_b_state:     .space 5 * 8

# A pointer to the active process state.
active_proc:    .space 1 * 8

proc_a_msg:     .string "Process A\n"
proc_b_msg:     .string "Process B\n"
