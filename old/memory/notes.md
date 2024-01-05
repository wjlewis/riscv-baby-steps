How do we view memory in `gdb`?
`x/nfu addr`
`x` is the command, `nfu` are optional parameters, and `addr` is the start
address.

`n` is the repeat count: how much we want to display, default is 1.
`f` is the format: `x` for hex, etc., default is `x`.
`u` is the unit size: `b`, `h`, `w`, or `g` ("giant words"), default is `w`.

Figure out where data will be loaded using `readelf`:

```
readelf -l main

Program Headers:
  ...
  LOAD           ...           0x000000008000000c
                                         ^^^^^^^^
```

Then

```
(gdb) x/13b 0x8000000c
0x8000000c:     0x48    0x65    0x6c    0x6c    0x6f    0x2c    0x20    0x77
0x80000014:     0x6f    0x72    0x6c    0x64    0x00
```

Which is `"Hello world\n"` in ASCII.

Alternatively we can get the address of the symbol in `gdb`:

```
(gdb) info address free
Symbol "free" is at 0x8000000c in a file compiled without debugging.
```

# Writing `strcpy`

```s
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
```
