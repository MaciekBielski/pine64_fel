ENTRY(_Reset)

MEMORY
{
    /* this is load_addr from u-boot */
	ram : ORIGIN = 0x41000000, LENGTH = 0x1000
}

SECTIONS
{
    /* put INTERRUPT_VECTOR and then rest of the code */
    .text : {
        startup.o (INTERRUPT_VECTOR)
        *(.text)
    } > ram
    .data : { *(.data) } > ram
    .bss : { *(.bss COMMON) } > ram
    . = ALIGN(8);
    . = . +0x1000;
    stack_top = .;
}
