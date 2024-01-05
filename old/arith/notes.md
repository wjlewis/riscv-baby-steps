Very similar to our spinning example, but now we're actually trying out some
basic RISC-V assembly instructions.

Some exercises:

- Write a subroutine that checks if a number is prime.
  Follow the RISC-V calling conventions:

  - `a0` through `a7` are used to store arguments
  - Return value is stored in `a0`

- Write a subroutine that computes n factorial recursively.
  Need to setup a stack.
