    .code 32
    .text
    ldr    r0, =0x017000a0               @ MMIO mapped RVBAR[0] register
    ldr    r1, =AARCH64_START            @ start address, to be replaced
    str    r1, [r0]
    dsb    sy
    isb    sy
    mrc    15, 0, r0, cr12, cr0, 2       @ read RMR register
    orr    r0, r0, #3                    @ request reset in AArch64
    mcr    15, 0, r0, cr12, cr0, 2       @ write RMR register
    isb    sy
1:  wfi
    b      1b
