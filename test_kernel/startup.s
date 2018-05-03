	/* .data */
	/* .align	3 */

/* uart0_thr:	.word	0x01C28000 */
/* uart0_lsr:	.word	0x01C28014 */
/* ctrl_reg0:	.word	0x01700C00 */

/* pre:	.word	0x77767574, 0x64636261 */
/* txt: */
/* 	.word	0xf1f0f1f0, 0x61626364, 0x74757677 /1* c0cad00d\n *1/ */
/* 	.align	3 */


	.text
	.global _reset
_reset:
	ldr	r0, =rst
	smc	#0
	b	.
rst:
	/* ldr	r1, =txt */
	/* /1* print cpsr *1/ */
	/* mrs	r0, cpsr */
	/* str	r0, [r1] */
	/* ldr	r0, =pre */
	/* bl	puts */

	/* print VBAR */
	/* mrc	p15, 0, r0, c12, c0, 0 */
	/* str	r0, [r1] */

	/* Request warm reset */
	/* ldr	r7, =rvbar1_h */
	/* ldr	r7, [r7] */
	/* mov	r8, #0x0 */
	/* str	r8, [r7] */
	ldr	r0, =0x17000a0
	ldr	r1, =0x40008000
	str	r1, [r0]
	dsb sy
	isb sy

	mrc     15, 0, r0, cr12, cr0, 2
	orr     r0, r0, #3
	mcr     15, 0, r0, cr12, cr0, 2
	isb sy

	wfi
	b	.


/* puts: */
/* 	ldr	r4, =uart0_thr */
/* 	ldr	r4, [r4] */
/* 	/1* Copy string address *1/ */
/* 	mov	r5, r0 */
/* 	mov	r6, #0 */
/* _loadc: */
/* 	/1* Load character *1/ */
/* 	ldrb	r7, [r5, r6] */
/* 	/1* Compare with NULL *1/ */
/* 	cmp	r6, #20 */
/* 	bne	_putc */
/* 	mov	pc, lr */
/* _putc: */
/* 	strb	r7, [r4] */
/* 	add	r6, r6, #1 */
/* 	b	_loadc */



/* /1* creates section containing executable code *1/ */
/* 	.align	3 */
/* 	.section VECTORS, "x" */
/* 	B	_reset /1* Reset *1/ */
/* 	B	. /1* Undefined *1/ */
/* 	B	svc_vec /1* svc *1/ */
/* 	B	. /1* Prefetch Abort *1/ */
/* 	B	. /1* Data Abort *1/ */
/* 	B	. /1* reserved *1/ */
/* 	B	. /1* IRQ *1/ */
/* 	B	. /1* FIQ *1/ */
/* /1* CPU starts in 32bit mode, a code here needs to reset it to aarch64 *1/ */


/* svc_vec: */
/* 	b	. */


