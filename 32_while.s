.global _start

_start:
    mov x0, #0         //initilization
    mov x1, #3
    mov x2, #2

while:                 //while x2!=0
    cmp x2, #0
    b.eq end
    add x0, x0, x1
    sub x2, x2, #1     //sucessive sum
    b while

end:
    mov x8, #93       //exit
    svc #0

             