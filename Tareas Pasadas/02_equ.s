.global _start

.equ MAX, 100

_start:

mov x0, MAX
mov x8, #93
svc #0
