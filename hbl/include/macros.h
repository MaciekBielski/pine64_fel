
.macro	print, out_add, str_label, done_label
	ldr	x1, =\out_add
	ldr	x2, =\str_label
1:	ldrb	w0, [x2]
	add	x2, x2, #1
	cmp	w0, #0
	beq	\done_label
	strb	w0, [x1]
	b 1b
.endm


/* vim: set filetype=ia64: */
