Example of using `sunxi-fel` tool to boot a custom aarch64 binary on Pine64. Initially, following sunxi-wiki, I had problems with running that but the proper configuration was presented [in this post](https://stackoverflow.com/questions/50120446/allwinner-a64-switch-from-aarch32-to-aarch64-by-warm-reset#answer-50165786) and it works.

registers
-------------------------------------------------------------------------------
* `ESR_ELx`: exception status: class, instruction legth and syndrome
* `ESR_ELx`: exception link reg
* `CurrentEL`
    - [3:2] = 00, 01, 10, 11 -> EL[0-3]
* `SCTLR_ELn`: MMU enabling, cache alignment checking
* `VBAR_ELX`
    - [63:11] - exception base address
* `SCR_EL3`: secure configuration register
    - can enable/disable HVC from non-secure EL1
    - can enable/disable SMC
    - .NS indicates that EL1 and EL0 are in secure/non-secure state


u-boot
-------------------------------------------------------------------------------

* vectors in arch/arm/cpu/armv8/exceptions.S
* vector routines in arch/arm/lib/interrupts_64.c
* _start: arch/arm/cpu/armv8/start.S
