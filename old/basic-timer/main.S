.equ UART_ADDR, 0x10000000

.equ CLINT_BASE, 0x2000000
.equ CLINT_MTIMECMP, CLINT_BASE + 0x4000
.equ CLINT_MTIME, CLINT_BASE + 0xbff8

# About 1 second.
.equ INTERVAL, 0xa00000

# Machine-mode interrupt enable.
.equ MSTATUS_MIE, 1 << 3
.equ MIE_MTIE, 1 << 7



.section .text
_start:
    # Setup mscratch
    la a0, timer_scratch
    csrw mscratch, a0

    # Setup mtvec (direct interrupts)
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

spin:
    j spin


.align 4
timervec:
    # Swap mscratch into a0
    csrrw a0, mscratch, a0
    sd a1, 0(a0)
    sd a2, 8(a0)
    sd a3, 16(a0)

    # Print message to UART
    la a0, message
    li a1, UART_ADDR
print_loop:
    lb a2, 0(a0)
    beqz a2, print_done
    sb a2, 0(a1)
    addi a0, a0, 1
    j print_loop

print_done:
    # Schedule next timer interrupt by adding interval to mtimecmp.
    # a1 stores address of mtimecmp
    li a1, CLINT_MTIMECMP
    li a2, INTERVAL
    # a3 stores value of mtimecmp
    ld a3, 0(a1)
    add a3, a3, a2
    # Store incremented value
    sd a3, 0(a1)

    ld a3, 16(a0)
    ld a2, 8(a0)
    ld a1, 0(a0)
    csrrw a0, mscratch, a0

    mret



.section .data
message:    .string "Tick\n"


# How much space?
# Enough to save registers used to setup next interrupt.
timer_scratch:  .space 3 * 8
