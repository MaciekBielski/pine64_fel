              .code 32
              .text
              ldr  r1,=0x01C28000
              ldr  r2,=message
loop:         ldrb r0, [r2]
              add  r2, r2, #1
              cmp  r0, #0
              beq  completed
              strb r0, [r1]
              b    loop
completed:    b .
              .data
message:
              .asciz "*** Hello from aarch32! ***"
              .end
