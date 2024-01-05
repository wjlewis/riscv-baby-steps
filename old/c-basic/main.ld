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
