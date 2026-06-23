.global _start

.data
float1: .float 2.5

.text
_start:
    ldr x0, =float1         // load float1 address
    ldr s0, [x0]            // load float1 value to s0
    fcvtns w0, s0           // convert s0 to int in w0

    mov x8, #93             // exit
    svc #0
    