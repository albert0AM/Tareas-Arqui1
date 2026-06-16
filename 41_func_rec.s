.global _start

_start:
    mov x0, #1          // result and neutral value
    mov x1, #4          // test value
    bl fact

    mov x8, #93         
    svc #0              

fact:
    stp fp, lr, [sp, #-16]! // preserve fp and lr
    mov fp, sp              // set frame pointer
    cmp x1, #1              
    beq end                 // if (x1 == 1) branch to end
    mul x0, x0, x1          // num * (num - 1)
    sub x1, x1, #1          // counter--
    bl fact

end:
    ldp fp, lr, [sp], #16   // restore fp and lr
    ret
    