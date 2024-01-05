# ## A program that counts down from 8, then spins.
# _start:
#     # Initialize register t1 to 8.
#     li t1, 8
# 
# loop:
#     # If t1 is zero, go to `spin`.
#     beqz t1, spin
#     # Subtract 1 from t1.
#     addi t1, t1, -1
#     # Jump back to `loop` for another trip around.
#     j loop
# 
# spin:
#     j spin

_start:
    li a0, 5
    jal is_prime
spin:
    j spin

# Exercises below

# ## Check if a number is prime.
# ## Returns 1 if so, and 0 otherwise.
# is_prime:
#     # a1 will store our divisor.
#     li a1, 2
#     ble a0, a1, is_prime_false
# is_prime_loop:
#     bge a1, a0, is_prime_true
#     rem a3, a0, a1
#     beqz a3, is_prime_false
#     addi a1, a1, 1
#     j is_prime_loop
# is_prime_true:
#     li a0, 1
#     ret
# is_prime_false:
#     li a0, 0
#     ret

_start:
    jal setup_stack
    li a0, 5
    jal fact
spin:
    j spin

## Recursive factorial function.
fact:
    ret

## Setup a stack frame (there are better ways to do this).
setup_stack:
    li sp, 0x80001000
    ret
