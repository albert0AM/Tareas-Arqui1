.global _start

.data
f1: .float 3.1
f2: .float 1.2

.text
_start:
    ldr x1, =f1             // load values
    ldr s1, [x1]
    ldr x2, =f2
    ldr s2, [x2]

    fmax s0, s1, s2         // get max and convert
    fcvtzs x0, s0

    mov x8, #93             // exit
    svc #0
    
