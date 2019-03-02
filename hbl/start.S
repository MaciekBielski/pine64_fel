              .text
              ldr  x1,=0x01C28000
              ldr  x2,=message
loop:         ldrb w0, [x2]
              add  x2, x2, #1
              cmp  w0, #0
              beq  completed
              strb w0, [x1]
              b    loop
completed:    b .
              .data
message:
              .asciz "*** Hello from aarch64! ***"
              .end
