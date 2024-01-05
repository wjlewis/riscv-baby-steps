We want to write characters using the UART.
Looking at device tree, it's located at `0x10000000`, and is compatible with the
["ns16550a" UART](https://en.wikipedia.org/wiki/16550_UART).

```dts
uart@10000000 {
	interrupts = <0x0a>;
	interrupt-parent = <0x03>;
	clock-frequency = <0x384000>;
	reg = <0x00 0x10000000 0x00 0x100>;
	compatible = "ns16550a";
};
```

It looks like we need to run through some initialization, but we can also just
write to the base address.

We can use general GNU `as` directives, even for RISC-V assembly.
For instance,

```s
.equ UART_ADDR, 0x10000000
```

works as expected.
See [Assembler Directives](https://ftp.gnu.org/old-gnu/Manuals/gas-2.9.1/html_node/as_65.html#SEC67),
in particular

> This chapter discusses directives that are available regardless of the target
> machine configuration for the GNU assembler.
