SECTIONS
{
  . = 0x80000000;

  .text : { *(.text) } :text

  .data : { *(.data) } :data
}

PHDRS
{
  text PT_LOAD FLAGS(0x5);
  data PT_LOAD FLAGS(0x6);
}
