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

ResetHandler:
	mov sp,#0x42000000
	add sp,sp,#0x1000
	bl kentry
	b .
