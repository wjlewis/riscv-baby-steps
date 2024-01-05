Need to setup a stack for `c`.

Why do we get an error when trying to naively create stack?

```
warning: main has a LOAD segment with RWX permissions
```

Investigation:

```
readelf --program-headers main
```

All sections (`.init`, `.text`, and `.bss`) are in same segment, which means
they'll all be loaded with the same "permissions".
We can give finer-grained privileges to these using the
[`PHDRS`](https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_node/ld_23.html)
part of a linkerscript file.

```
SECTIONS
{
  . = 0x80000000;

  .init : { *(.init) } :text

  .text : { *(.text) } :text

  .bss : { *(.bss) } :data
}

PHDRS
{
  text PT_LOAD FLAGS(0x5);
  data PT_LOAD FLAGS(0x6);
}
```

You can find the correct flags
[here](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format#Program_header).
I didn't find this documented, but it appears like you just add the flags for
individual permissions to get a "joint" permission.

**Question** Do the segment flags actually matter here?
In other words, can we just ignore the warning?

Yes!
For instance, if we make the `data` segment executable and the `text` segment
writable (only), everything still works as expected in `qemu`.
My unconfirmed suspicion is that `qemu` is just ignoring this information when
loading the ELF file (and why shouldn't it?).
