/* creates section containing executable code */
.section INTERRUPT_VECTOR, "x"
/* exporting the name to the linker */
.global _Reset
_Reset:
    B ResetHandler /* Reset */
    B . /* Undefined */
    B . /* SWI */
    B . /* Prefetch Abort */
    B . /* Data Abort */
    B . /* reserved */
    B . /* IRQ */
    B . /* FIQ */

/* CPU starts in 32bit mode */
ResetHandler:
	ldr sp, =stack_top
	bl kentry
	b .
