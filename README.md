Example of using `sunxi-fel` tool to boot a custom aarch64 binary on Pine64. Initially, following sunxi-wiki, I had problems with running that but the proper configuration was presented [in this post](https://stackoverflow.com/questions/50120446/allwinner-a64-switch-from-aarch32-to-aarch64-by-warm-reset#answer-50165786) and it works.

u-boot
-------------------------------------------------------------------------------

_start: arch/arm/cpu/armv8/start.S
* boot0.h is used by different SoCs, inserted into arch/arm/lib/vectors.S
* arch/arm/lib/vectors.S contains pointers to service routine addresses,

* CurrentEL[3:2] = 00, 01, 10, 11 -> EL[0-3]
* SCTLR_ELn - MMU enabling, cache alignment checking
