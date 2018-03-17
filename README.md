## Updating kernel image

    $ make image_kernel
    $ make image_flash

## STATUS

Program starts in 32bit mode, switch to 64bit mode

    ## Starting application at 0x41000000 ...                    
    data abort                                                   
    pc : [<41000028>]          lr : [<7ff1d054>]                 
    sp : 76eb8a90  ip : 00000030     fp : 7ff1d00c               
    r10: 00000002  r9 : 76ed0ea0     r8 : 7ffb5340               
    r7 : 77f1bd58  r6 : 41000000     r5 : 00000002  r4 : 77f1bd5c
    r3 : 41000000  r2 : 77f1bd5c     r1 : 77f1bd5c  r0 : 00000001
    Flags: nZCv  IRQs on  FIQs off  Mode SVC_32                  
    Resetting CPU ...                                            

More info about this in Architecture Reference Manual, look for RMR_EL

