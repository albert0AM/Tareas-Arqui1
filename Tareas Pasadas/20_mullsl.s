.global _start

_start:

mov x1, #32
mov x2, #2
lslv x0, x1, x2

mov x8, #93
svc #0
