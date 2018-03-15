	.arch armv8-a+crc
/* creates section containing executable code */
	.section INTERRUPT_VECTOR, "x"
/* exporting the name to the linker */
	.global _Reset
_reset:
	B	reset_handler /* Reset */
	B	. /* Undefined */
	B	. /* SWI */
	B	. /* Prefetch Abort */
	B	. /* Data Abort */
	B	. /* reserved */
	B	. /* IRQ */
	B	. /* FIQ */

	.section	.rodata
	.align	3

	.global	UART0_DR
	.type	UART0_DR, %object
	.size	UART0_DR, 8
UART0_DR:
	.xword	0x01C28000

	.global	UART0_LSR
	.type	UART0_LSR, %object
	.size	UART0_LSR, 8
UART0_LSR:
	.xword	0x01C28014

txt:
	.string	"Welcome!\n"
	.align	3


/* CPU starts in 32bit mode */
	.text
	.align	3
	.type	reset_handler, %function
reset_handler:
	ldr	sp, =stack_top
	bl	pr_uart0
	b	.
	.size	reset_handler, .-reset_handler

/* Print character to the console */
	.align	3
	.type	pr_uart0, %function
pr_uart0:
	/* TODO: print banner to the console */

	.size	pr_uart0, .-pr_uart0
