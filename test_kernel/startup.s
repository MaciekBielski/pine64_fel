/* creates section containing executable code */
	.section VECTORS, "x"
	.global _reset
_reset:
	B	reset_vec /* Reset */
	B	. /* Undefined */
	B	svc_handler /* svc */
	B	. /* Prefetch Abort */
	B	. /* Data Abort */
	B	. /* reserved */
	B	. /* IRQ */
	B	. /* FIQ */

	.data
	.align	3

uart0_thr:	.word	0x01C28000
uart0_lsr:	.word	0x01C28014
c_rst_ctrl:	.word	0x01700c80

pre:	.word	0x77767574, 0x64636261
txt:
	.word	0xf0f0f0f0, 0x61626364, 0x74757677 /* c0cad00d\n */
	.align	3


	.text

/* CPU starts in 32bit mode, a code here needs to reset it to aarch64 */
reset_vec:
	/* ldr	r7, =c_rst_ctrl */
	/* ldr	r7, [r7] */
	/* ldr	r8, [r7] */

	/* set the bit for aarch64 */
	/* orr	r8, r8, #0x0000 */
	/* str	r8, [r7] */
	/* isb */
	/* dsb */

	/* read the register again for a check */
	/* ldr	r8, [r7] */

	/* undefined */
	/* mrc	p15,0,r8,c1,c1,0 */

	mrs	r8, CPSR
	ldr	r9, =txt
	str	r8, [r9]

	ldr	r0, =pre
	bl	puts
	mov	r8, #3
	mcr	p15,0,r8,c12,c0,2

	b	.
	/* mrc	p15,0,r2,c1,c0,2 */
	/* mov	r2, #3 */
	/* mcr	p15,0,r2,c12,c0,2 */
	/* b	. */

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

	/* mrs	r1, CPSR */
	/* str	r1, [r3] */
	bl	puts

	b	.

