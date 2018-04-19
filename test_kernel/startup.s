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

	.data
	.align	3

uart0_thr:	.word	0x01C28000
uart0_lsr:	.word	0x01C28014

txt:
	.string	"Test\n"
	.align	3


	.text
puts:
	ldr	r4, =uart0_thr
	ldr	r4, [r4]
	/* Copy string address */
	mov	r5, r0
	mov	r6, #0
_loadc:
	/* Load character */
	ldrb	r7, [r5, r6]
	/* Compare with NULL */
	cmp	r7, #0
	bne	_putc
	mov	pc, lr
_putc:
	strb	r7, [r4]
	add	r6, r6, #1
	b	_loadc



/* CPU starts in 32bit mode, a code here needs to reset it to aarch64 */
reset_handler:
	ldr	r0, =txt
	bl	puts
	b	.
	/* read RMR */
	/* mrc p15,0,r0,c12,c0,2 */
