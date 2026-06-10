.global _start

_start:
mov x1, #0b10010
mov x2, #0b101
orr x0, x1, x2

mov x8, #93
svc #0
