.equ UART_ADDR, 0x1000000

_start:
    # Initialize timer interrupt.

# Process A: print "A" to the UART.
proc_a:
    li t0, UART_ADDR
    li t1, 'A'
proc_a_loop:
    sb t1, 0(t0)
    j proc_a

# Process B: print "B" to the UART.
proc_b:
    li t0, UART_ADDR
    li t1, 'B'
proc_b_loop:
    sb t1, 0(t0)
    j proc_a

# Perform a context switch.
# a0 contains a pointer to the current/old context.
# a1 contains a pointer to the new context.
switch:
