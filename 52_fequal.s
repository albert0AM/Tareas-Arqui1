.global _start

.data
float1: .float 2.5
float2: .float 2.5

.text
_start:
    ldr x0, =float1         // load float1 address
    ldr x1, =float2         // load float2 address
    ldr s0, [x0]            // load float1 value to s0
    ldr s1, [x1]            // load float2 value to s1

    fcmp s0, s1             // compare s0, s1
    cset w2, eq             // t2 = (f0 == f1) ? 1 : 0

if:
    cbz w2, else            // branch to else if t2 == 0
    fcvtps w0, s0           // convert f0 to int in a0
    b end                   // jump to end

else:
    fsub s2, s0, s1         // f2 = f0 - f1
    fcvtps w0, s2           // convert f2 to int in a0

end:
    mov x8, 93              // exit
    svc #0
    
