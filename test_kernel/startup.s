	.arch armv8-a+crc
/* creates section containing executable code */
	.section INTERRUPT_VECTOR, "x"
/* exporting the name to the linker */
	.global _reset
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
	ldr	x0, =stack_top
	mov	sp, x0
	ldr	x0, =txt
	bl	pr_uart0
	b	.
	.size	reset_handler, .-reset_handler

/* Print character to the console */
	.align	3
	.type	pr_uart0, %function
pr_uart0:
	sub	sp, sp, #8
	str	x0, [sp, #8]
	adr	x9, UART0_LSR
	ldr	x9, [x9]
	adr	x13, UART0_DR
	ldr	x13, [x13]
	b	_while_lsr

_put_char:
	strb	w12, [x13]
	add	x11, x11, #1
	str	x11, [sp, #8]

_while_lsr:
	/* test if device ready for input */
	ldrh	w10, [x9]
	/* w10 && 0x20  == test 5th bit */
	tbnz	w10, #5, .

	/* pointer mechanics */
	ldr	x11, [sp, #8]
	ldrb	w12, [x11]

	/* check if input is valid (not null) */
	cmp	w12, 0x0
	bne	_put_char
	ret

	add	sp, sp, #8

	.size	pr_uart0, .-pr_uart0
