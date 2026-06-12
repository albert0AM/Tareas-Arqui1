.global _start

.data
pos: .asciz "The number is positive\n"
neg: .asciz "The number is negative\n"
neu: .asciz "The number is neutral\n"

.text
_start:
    mov x0, #15          // number to test

if:
    cmp x0, #0
    blt elseif           // if x0 < 0 branch elseif
    beq else             // if x0 == 0 branch else

    mov x0, #1           // positive number
    ldr x1, =pos
    mov x2, #23
    b endif

elseif:                  // negative number
    mov x0, #1
    ldr x1, =neg
    mov x2, #23
    b endif

else:                    // number is zero
    mov x0, #1
    ldr x1, =neu
    mov x2, #22

endif:
    mov x8, #64
    svc 0
    
    mov x0, #0           // exit
    mov x8, #93
    svc #0
    