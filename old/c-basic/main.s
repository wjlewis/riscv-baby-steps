.section .init
_start:
    # Setup a stack.
    la sp, stack + 4096

    li a0, 5
    jal fact
spin:
    j spin

.section .bss
# Stack
stack:  .space 4096
