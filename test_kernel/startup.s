/* creates section containing executable code */
	.section VECTORS, "x"
	.global _reset
_reset:
	B	reset_vec /* Reset */
	B	. /* Undefined */
	B	. /* svc */
	B	. /* Prefetch Abort */
	B	. /* Data Abort */
	B	. /* reserved */
	B	. /* IRQ */
	B	. /* FIQ */

	.data
	.align	3

uart0_thr:	.word	0x01C28000
uart0_lsr:	.word	0x01C28014
c_ctrl_reg0:	.word	0x01700c00

pre:	.word	0x77767574, 0x64636261
txt:
	.word	0x00000000, 0x61626364, 0x74757677 /* c0cad00d\n */
	.align	3


	.text

/* CPU starts in 32bit mode, a code here needs to reset it to aarch64 */
reset_vec:
	ldr	r0, =pre
	bl	puts
	svc	0xff00
	/* mrc	p15,0,r2,c1,c0,2 */

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
	cmp	r6, #20
	bne	_putc
	mov	pc, lr
_putc:
	strb	r7, [r4]
	add	r6, r6, #1
	b	_loadc

svc_handler:
	ldr	r0, =pre
	ldr	r3, =txt

	/* ldr	r2, =c_ctrl_reg0 */
	/* ldr	r2, [r2] */
	/* ldr	r4, [r2] */
	/* orr	r4, r4, #0x51000000 */
	/* str	r4, [r2] */
	/* ldr	r1, [r2] */

	mrs	r1, CPSR
	str	r1, [r3]
	bl	puts

	b	.

