.equ UART_ADDR, 0x10000000

.section .text
_start:
    li t1, UART_ADDR
    la t0, msg
loop:
    lb t2, 0(t0)
    beqz t2, loop_done
    sb t2, 0(t1)
    addi t0, t0, 1
    j loop
loop_done:
spin:
    j spin

.section .data
msg:    .string "Hello, world!\n"
