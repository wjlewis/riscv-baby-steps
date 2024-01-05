.section .text
_start:
    la a0, free
    la a1, message
    jal strcpy
spin:
    j spin

# Copy null-terminated string from src to dest.
# Dest pointer in a0, src pointer in a1.
strcpy:
    lb t0, 0(a1)
    beqz t0, strcpy_done
    sb t0, 0(a0)
    addi a0, a0, 1
    addi a1, a1, 1
    j strcpy
strcpy_done:
    sb zero, 0(a0)
    ret


.section .data
message: .string "Hello, world"

.section .bss
# 16 words of "free space" for us to play around in.
free:   .space 16
